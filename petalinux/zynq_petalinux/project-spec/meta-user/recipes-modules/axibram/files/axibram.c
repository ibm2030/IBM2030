// SPDX-License-Identifier: GPL-2.0
/*
 * axibram - expose AXI BRAM Controller windows as character devices.
 *
 * Each "xlnx,axi-bram-ctrl-4.1" node with a device-tree alias "axiN" becomes
 * /dev/axiN, e.g.
 *
 *     aliases { axi1 = &axi_bram_ctrl_0; axi2 = &axi_bram_ctrl_1; };
 *
 * Supported file operations:
 *   read/write/lseek  byte-addressed access to the window, bounded by its size
 *   mmap              uncached mapping of the window (offset must be 0).
 *                     Windows smaller than a page still map a whole page;
 *                     accesses past the window size will fault on the bus.
 */

#include <linux/fs.h>
#include <linux/io.h>
#include <linux/miscdevice.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/platform_device.h>
#include <linux/slab.h>
#include <linux/uaccess.h>

#define AXIBRAM_CHUNK	PAGE_SIZE

struct axibram {
	struct miscdevice misc;
	void __iomem *base;
	resource_size_t phys;
	resource_size_t size;
	char name[16];
};

static struct axibram *to_axibram(struct file *file)
{
	/* misc_open() stores the struct miscdevice pointer in private_data */
	return container_of(file->private_data, struct axibram, misc);
}

static loff_t axibram_llseek(struct file *file, loff_t off, int whence)
{
	return fixed_size_llseek(file, off, whence, to_axibram(file)->size);
}

static ssize_t axibram_read(struct file *file, char __user *buf,
			    size_t count, loff_t *ppos)
{
	struct axibram *b = to_axibram(file);
	loff_t pos = *ppos;
	size_t done = 0;
	void *kbuf;

	if (pos < 0)
		return -EINVAL;
	if (pos >= b->size)
		return 0;
	count = min_t(size_t, count, b->size - pos);

	kbuf = kmalloc(AXIBRAM_CHUNK, GFP_KERNEL);
	if (!kbuf)
		return -ENOMEM;

	while (done < count) {
		size_t n = min_t(size_t, count - done, AXIBRAM_CHUNK);

		memcpy_fromio(kbuf, b->base + pos + done, n);
		if (copy_to_user(buf + done, kbuf, n)) {
			kfree(kbuf);
			return done ? done : -EFAULT;
		}
		done += n;
	}

	kfree(kbuf);
	*ppos = pos + done;
	return done;
}

static ssize_t axibram_write(struct file *file, const char __user *buf,
			     size_t count, loff_t *ppos)
{
	struct axibram *b = to_axibram(file);
	loff_t pos = *ppos;
	size_t done = 0;
	void *kbuf;

	if (pos < 0)
		return -EINVAL;
	if (pos >= b->size)
		return count ? -ENOSPC : 0;
	count = min_t(size_t, count, b->size - pos);

	kbuf = kmalloc(AXIBRAM_CHUNK, GFP_KERNEL);
	if (!kbuf)
		return -ENOMEM;

	while (done < count) {
		size_t n = min_t(size_t, count - done, AXIBRAM_CHUNK);

		if (copy_from_user(kbuf, buf + done, n)) {
			kfree(kbuf);
			return done ? done : -EFAULT;
		}
		memcpy_toio(b->base + pos + done, kbuf, n);
		done += n;
	}

	kfree(kbuf);
	*ppos = pos + done;
	return done;
}

static int axibram_mmap(struct file *file, struct vm_area_struct *vma)
{
	struct axibram *b = to_axibram(file);

	if (vma->vm_pgoff)
		return -EINVAL;

	vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
	/* Checks the requested length against the window (rounded up to a page) */
	return vm_iomap_memory(vma, b->phys, b->size);
}

static const struct file_operations axibram_fops = {
	.owner		= THIS_MODULE,
	.llseek		= axibram_llseek,
	.read		= axibram_read,
	.write		= axibram_write,
	.mmap		= axibram_mmap,
};

static int axibram_probe(struct platform_device *pdev)
{
	struct device *dev = &pdev->dev;
	struct axibram *b;
	struct resource *res;
	int id, ret;

	id = of_alias_get_id(dev->of_node, "axi");
	if (id < 0) {
		dev_err(dev, "no \"axiN\" alias in /aliases for this node\n");
		return id;
	}

	b = devm_kzalloc(dev, sizeof(*b), GFP_KERNEL);
	if (!b)
		return -ENOMEM;

	b->base = devm_platform_get_and_ioremap_resource(pdev, 0, &res);
	if (IS_ERR(b->base))
		return PTR_ERR(b->base);
	b->phys = res->start;
	b->size = resource_size(res);

	snprintf(b->name, sizeof(b->name), "axi%d", id);
	b->misc.minor = MISC_DYNAMIC_MINOR;
	b->misc.name = b->name;
	b->misc.fops = &axibram_fops;
	b->misc.parent = dev;
	b->misc.mode = 0666;

	platform_set_drvdata(pdev, b);

	ret = misc_register(&b->misc);
	if (ret) {
		dev_err(dev, "misc_register(%s) failed: %d\n", b->name, ret);
		return ret;
	}

	dev_info(dev, "/dev/%s -> %pa (%pa bytes)\n", b->name, &b->phys, &b->size);
	return 0;
}

static void axibram_remove(struct platform_device *pdev)
{
	struct axibram *b = platform_get_drvdata(pdev);

	misc_deregister(&b->misc);
}

static const struct of_device_id axibram_of_match[] = {
	{ .compatible = "xlnx,axi-bram-ctrl-4.1" },
	{ }
};
MODULE_DEVICE_TABLE(of, axibram_of_match);

static struct platform_driver axibram_driver = {
	.probe	= axibram_probe,
	.remove	= axibram_remove,
	.driver	= {
		.name		= "axibram",
		.of_match_table	= axibram_of_match,
	},
};
module_platform_driver(axibram_driver);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Lawrence Wilkinson");
MODULE_DESCRIPTION("AXI BRAM Controller windows as /dev/axiN character devices");
