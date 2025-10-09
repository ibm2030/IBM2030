// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.1 (win64) Build 6140274 Thu May 22 00:12:29 MDT 2025
// Date        : Mon Oct  6 14:19:02 2025
// Host        : lznb204 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/lwilkinson/Xilinx/IBM2030/IBM2030.gen/sources_1/ip/blk_mem_2k_9/blk_mem_2k_9_sim_netlist.v
// Design      : blk_mem_2k_9
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_2k_9,blk_mem_gen_v8_4_11,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_11,Vivado 2025.1" *) 
(* NotValidForBitStream *)
module blk_mem_2k_9
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta,
    clkb,
    enb,
    web,
    addrb,
    dinb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_mode = "slave BRAM_PORTA" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [10:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [8:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [8:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_mode = "slave BRAM_PORTB" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_ADDRESS_MODE BYTE_ADDRESS, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [3:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [8:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [35:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [35:0]doutb;

  wire [10:0]addra;
  wire [8:0]addrb;
  wire clka;
  wire clkb;
  wire [8:0]dina;
  wire [35:0]dinb;
  wire [8:0]douta;
  wire [35:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
  wire [3:0]web;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [8:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [8:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [35:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "11" *) 
  (* C_ADDRB_WIDTH = "9" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "0" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     5.585449 mW" *) 
  (* C_FAMILY = "zynq" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "blk_mem_2k_9.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "2" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "2048" *) 
  (* C_READ_DEPTH_B = "512" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "9" *) 
  (* C_READ_WIDTH_B = "36" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "1" *) 
  (* C_USE_BYTE_WEB = "1" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "4" *) 
  (* C_WRITE_DEPTH_A = "2048" *) 
  (* C_WRITE_DEPTH_B = "512" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "9" *) 
  (* C_WRITE_WIDTH_B = "36" *) 
  (* C_XDEVICEFAMILY = "zynq" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  blk_mem_2k_9_blk_mem_gen_v8_4_11 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[8:0]),
        .regcea(1'b1),
        .regceb(1'b1),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[8:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[35:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(web));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2025.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
gydSV72FvW4hnoyUt6yZFJHfJqjRQWPUfYIuDKP0fpjrPOkLRbJGBr4Z9msYTvoIHRlYtXJ2YMY0
d1TIQb+FK4gKsTRru9wr397OxuFBsTRf4e+ZjpYZEdsnqYWcgMSzhN4yhPvO06GyZO15y/LKBxa8
3OKwxVlOLYXhv+sxdXg=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
WHB6Zbfa5Qi47krP9T4L8UnPOlr881dWx7UcYaZfNGIQQM0gadcoXbhucIpRaUuyOKxv6yhKveRN
h0l+N9+KX6rbZ6+TRhP9JAMuPhlpI7T42QtRv5zx9+m3ct5S0NMszbFaK8zeTAYra5BGP7BHmtkr
MpKfLK5sFyaTE/A7ACtAace9MwFTHDZdl9uUs4aY6KJlm6GaypKduiqkNugukJp5vlFPX/ZapJqG
KMtMhI6grhcuYb1FJrwRZ4jW7hs9HxddSdGLzsZ0HsBcO/qaCPTst+ZA0YIQfd5ULlFmPqq39FfO
p1P+2hEH2n+LycbMj5cn4Dxfqv2R8eucM78R3w==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
SmAzQA1VEuJXtJi5vXa2Jg7YvRqAJs6PX9HTZ1YqrJw4VfonBW3726gJ81BjlizpMkcf/Uk5sFIK
aPedVhEs4xCIZylz7gXYDshtytOA/pXUID2qV9nXr8qfI+FydSADUF3ScYDZmlkclFqlZrGq6DQ7
da3lJAzt2h/iR+cczrA=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
iAph5JWb/chMQpLPX1UoLjQDxN5l2I8McM/k2xN5wRht7HXoE6F5yV8luDjn3zkI6vnfUYo7BaI1
mogRRx+R3XcwxvhHr+lngh4+/YLVex1TFncl+kiUMAsu3M/FjFSiqGMVMdKTNLDqr35DuZJVyuiF
lTwXob/KkbQDJiJjBEoxbt+968rKRKRyJGcqIjm4mqRBdqMcgo3HOJFG74SFsWAQrxvXfBhdLSG3
OfoLfls9XDojBjp7G83k0h82g1eeWgBfydm/OcX9o48Pst93NvI4ua8WShZL8MCvRWYqWZrrjrWi
cfUjXAF5SDACjq1/OU6arz/Idz6/a7AP/jmexw==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
BY49GZBxBT/gjZDPyaSWlti/sctckoR7jK6NuWdhnF9tiyNfVU7BqjjwxSnyMi0Uucv1BKHXC18h
8hQbFWnNtrq71ilURotXux7sssHlVJ2i1CsJWU18DOcBWxm2ai89uwvxDJh3TJkBJixB5KPvsDhL
lWOjTvZWPoR+Ixy+Tzo+U5Vx7z7SOakRwTrn3u7+c3vmCEBphE+HKeJExhBAoOEd0SXK5iwXaByW
D7Wb7zq6NNUmnCyaJ2BG9kGxLVsf+md7SlocuaFsYyaRZhwPyTucxIlz1tLYwcytKzx0ovoax3no
nYgzlzP/F0/PDWk9BqXgr/tuclc4EZYX0cf4ng==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2025.1-2029.x", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qGnCvL35qO7cbUEKCL50yDv1UvezcqBz601zctKop1954QlcjemzZWZHg1zJ00nJaToNdH2S8AKX
n8hNJvbQ+x5HEGL5DoSU9m5qjXd8xxocnZ0yzuZX/dGCT8kDn3gWJR2Gz13pT+w2LQUno1fX+MsC
ehgwvjBBT6GeYjdxHi+aybQUP9AblSxX/z3vh857SGCPohEWvghOgORCHAe45YD+ZWnL62FLxMM2
c+Ozq/Au/Q4q1Yzlzcfv8Mnsvg7OqOeEamQHbuYOfdkJUuYqOwsskEWW348u7FXtsf8m7P3pZyyz
IWyTDAW4igGguMPLHfbtK/twZx8ScJQmOKzglg==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Hz+6K8+wh5/fukU4ZWNDXGsq6hreSVCSPP67nA6kUz9Vpjy4TtTnOrrl1BWY0ivEC7Ldyw8VI60A
VO/WPlt409LdAZdMZGsEZ1JuTZ0m9LPcgu9CPCyoMECctmd8LHE+otY6etTmYABB9syY61rk2hrv
RgbcyT/HCK9TzWxSm+XMqvx2nvagCLkMDPh/JZv51fj2zcKaBPnxsz8rnDipaeo0fEyVRC3Y1F/V
U3RmXojBjIumPHSJkQ537dENJEIA0Ra65u8EM/+ItUn1bcryLcIbKy1xGadrHmHdHRUoRcAodO2C
B48bNVeL0VnGg8P9ACIB04lMNzn5p6A1tPOb4Q==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
YDpb+UeT0rJ543Q8wCo2xSS3gpVAT+JoStgBlV5IMjJoUOWkiOPn691FGChmDi3BTq5NxC73KHHR
1galACCjeTGq6cv+0Zc2Ocm1oobdrnSPHp7TMDr5Zle8FX6WywJCiGdoWBODggZSlbOASIK/PVfY
cZM2z60M6RSvzsi3TnYHiKYHpju8THVoSgRd6r31GcbiSy9TjjARERXan0OVc79jGuAg90mmDEEq
91eqmn6NZ9yLI2fgBjFUZbtFCpmJ8WGxOL1h39niWnRK3ZXnk8jcpnZUlxLbYTPO0Z3vVr1zrvcn
RVQloU0OLqg7M95zSs7NtX5Vzvb6jGbMehWV+WMMyxWmxL2XOwsAwPSeX2dI2r77pioY7X6VzH7f
/JxMAnq9udra3WGPsUkD1G0CvPkCC3zdxjpVaflY37ztX9UONhKtzMQa8lJc1IL8GhXRY3R9Lg2c
HIeXSGkpNNuFDqKT6Khe/6Casq+SjFJq+IH9IUtz6RUZTkbFb0Xhgm2P

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Q+63zFEYw/LeMgxa7g8g79GGvSyIKDKD8RvvC4DHDQuGObf6n9OGZX4e17v/E/+EDEwUhsWQHFDI
Lp/aH+6fNRmhu9BEWVjxq2WRrQSl4eQjfIaSOXu2dlYh3JjRJwiUp4LteVh8RFAf5t5sRQO4dRIK
x+h28yliSgibaWEAv5FaJQ1EFbNwmgedAaSYjgf2A3afBUcBh5Uy9VHbW/zRzdhhJdsVNBjZYcFy
CVLOcf1toCRp8J4U5FlnFMOzFegUbdXFQhq2VmIhPRxWjrfTk6iR4BcMEN9UMij/5IHRAeBdksyD
CqEKsyFxosbI5KVMRZ1Ln75Zipn0JdsGekHkxg==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
DPUa5DLPYRWvbPnX0U412yoWvvvHyuq43DrYmDJGTK0cR5U4U6th8icYgizC1/hUAEzt19kM/hVa
zZh7bXSWACYLpcfhPY8dRTVGDZVjpbkraw0ceBryLP7jc6Jt5JdNw88tZtZpprCB7nQ25lUL82Hf
WTwL1ZqgGIvtfHhxO0JF5L5ES5giedwQ6u5ffXG3UB6ELcpQD1NvpW5lAz4mfXyvVDCAPZN581TF
tlAy79iKbPKlJ2zFn1BS2cuRIHHe2JRxwPo+0n5VD5CXVgg+lCYxTnCxI8CdyFaTumbs4IfAKwVI
wSN/btbwDUhW9hAHWHIRo+BpdJ4qeGcTDPKtsA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
mf5hcf6JE6yLm0jNCQnHMVmogjLlPz6re0FwG67yvOJ3FuEorru0emIeAKEwgOoxjUYNWvcM7QAH
/UEeB2EIdjLl6glPAUda0HjtaCU2rdncVdM8k6DSMBggc4yo18Qx5F+1TD/RoBgoo0jNkMdDy6wJ
JHjqlN+R01z3yYIMQ9f2z6ZaYncbBYEp4+YAb7g1D7CSMxP5cFRpQznRpYp0JwqJfT9CHzlKgdab
8B288NxeLM66iYodiTS+GSRGLGtDWXpz9yeiuiPe6kJxae2GJyHIMSfluO/0Slc3m24DQNdbojf8
jdc0G2UnrDe5mCUTfYiDmpOWTUJOdYo0FK0N2g==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 28704)
`pragma protect data_block
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
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
