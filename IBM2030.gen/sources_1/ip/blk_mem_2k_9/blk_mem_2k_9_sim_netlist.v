// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// Copyright 2022-2025 Advanced Micro Devices, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2025.2 (lin64) Build 6299465 Fri Nov 14 12:34:56 MST 2025
// Date        : Tue Nov 25 21:37:52 2025
// Host        : synergy running 64-bit Linux Mint 22.2
// Command     : write_verilog -force -mode funcsim
//               /home/ljw/Documents/IBM/IBM2030/IBM2030.gen/sources_1/ip/blk_mem_2k_9/blk_mem_2k_9_sim_netlist.v
// Design      : blk_mem_2k_9
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "blk_mem_2k_9,blk_mem_gen_v8_4_12,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_12,Vivado 2025.2" *) 
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
  (* C_DEFAULT_DATA = "001" *) 
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
  (* C_USE_DEFAULT_DATA = "1" *) 
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
  blk_mem_2k_9_blk_mem_gen_v8_4_12 U0
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
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2025.2"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
YqH9kwIC39+qbZg4PSfFsXuB9k9wnuxNryS/CfnEri6Ci9fSC6fsrQ/T/hnt3u/yolbJ8DJa1Qu6
Qnm24A9jLbA+fu3Nsmm6/rM6a4vU6OfVl/gTFd/CiWDutv6Dhn6Lim4uUNPahoOR/A2Yc4Zo2tdI
kMLO9gn9WlH2l3O2oXs=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XJYO2VHd/cnMxQd3i7/2qRhl57dl+doEKuhAunQyv3vpGRG/jlNxj8PqrgLoF0HMdqE3qJUVE/oq
kBSapqjVjLDMOrNGQ+Tc6VGsKMZH8FE/TXHQJ/IM5Iuiu2eozEwwVUomF+7cfqn+9OsVsqCONQ1M
g0oRlangiqasJDhhMfnlGGqwAwmgWRGQA6dmhTuua1s8zdvIv540zY6p5au8cAKVhqyyKK7wbxEE
SGuFqX+NYoyRV+rfWCcWM+hJEmnWS8LNAKkd13YE2+17sPYzUdZ23DmTxXK6KlAxKFW27CBySUfg
qdNXp2DSs2KAQYih27pBNMuHfGbM/ATFPWFvxg==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
lYoEi/e8HsDTz6N11EDe/B/iitERmeYndlCklmCluwgb0N4W80JUGVlkd7NlRZHRNhxaNBJPkcjC
n61nO0tb17NwsMwjbY5TF8JWRYTNw1JXCFacvQYrdKv4/7QNQEtwVGiCLxFhOA8aHlWMZIrc2fri
VRMVWaEBcPwCGorlVIM=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
QEw9fEsWFbdX0OQLvYs/gl+zyEOW3ak9TdQVaq+0AXXOT3LIqF7wDxJ6ZBnlf9mNbdsUVH5tAz1o
H8u7ihJl1L3THEvugW+TS8hkvVbEA9rKO2vV15KAj4Lla7UdFT/xDfe79RFarlLI7yGrubjgdoRi
QWy//UKsffG7IWNwmoSuppWiWB4ZHJtkunNyIkm70JPGyZF62VxJg1MTT+5LUbZG5vZjjuHZud9w
xJaKv1tFP/x8RVqLU5gPOqGqTW7/nKO2S+450Vo4D9vAmBVVcXpaL1EbSmCvQ+qJmcQKtf9qYFRV
Zko08hbpHjPxstqvTDro01jRzB8592m4xU2TWA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
TC7q853CWBPPJgbRfgDV1lmjUwSAtliljShAyNFg8sfRfwDzchthzoSPH1UCHV++E2JXacEKq1lB
UWsNP92U4Xh0/Gu+6esOI0pJb8I+TRTxyBN1I4cRQEfQHcwfhbSdeH3yX9OV3opLEqYmT37hWU+J
zCawYnxVESI0FtRzEXve9gdEWlrKKckrT/hp4mvxxOjvOkOSQBvy0elgUOqh6mEOZl+JnUbsR+Wm
CoZLE1eefMZy3FnVmyDNPv3JPXi88aLXMyimal0MYFkTiS4XJiGT3eAIMIbksehXY+eYi/KFpZWQ
GHpX+lG3UmiWWLwyPakFwKEHbrBc70AlJ2eV9g==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2025.1-2029.x", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
j9nmCKgjPWNChPbpSW6EWLrMA6oCG2JGPoum8px09v0PEAh0DRXZi0J8HPzXUsZgOEMcKpA7X54u
YFcDDCLAQ+urha/eSPbQYHQh4yGCursxAQ1C6LEyNQ2wJ0eLlO2bJeAl/gof06zqsYVM2lLJVNv5
wao1k2bmgPdfpfY3c9vPD0fSMuZPS41EoRS0cQhO5GTZnKdjxm6tEUL3GnTjB8ynSCIbCJUsMtAX
4FRHNa52gudx5B5fagR+lXgFhE7e++rWTJELr7SYB+r5Es8qZLTpCH8TrQxEkV0rY/+e4sAjNE2D
gHw8GD7VcUtc15B8y1BbVmh29qc8Nd3V2i/miA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
UkCD6I/Vye4qNoNoa3hIexBXG3xyKUJPAHAjIo7UcNVCDXpMQiYEtPDqExZMfiPlJn2nswCYIfIJ
FYWqMCloKSQyyI/7yZ2EtbyWEklb/P5IyZyvGi6hhFUo/JFTb12b4bK0gZPr+bCDdlVQKTx5GVHz
wptdUJO2omSj8axVMPbLRRtVzlJIZ29dTJ2ATXVXAcBxPnFfHRAMnYYKLeeLExX61vQvpqrkLQHm
XG7hpVzJi56gYKAzxa2BLq072OCVpVS70bfWlhlSTVcSlCrUf+EcarEk4FD8+Ih2NCvrqremG6yn
TtcBn8Xr8M/6zhOYvLi6AD6eArDMKA8n+Ccv8A==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
A5y5QVZU8yjPexRVPioSiAGohCHD5DX5FVobuMyhcgQRExLUhPvnnS8HOtxTj/2IapEcz68gFMGG
Hpi+m725u85/om/Vze9pGIW9Mn328Kz2FIg3W5EvGstfGwY+48LiAGAmTR269JS4lJGVYWYOz7Xk
S8cEsFd2m7j8iyKtARJzD90+UdXq/cIIh725jC9i8nbgxB364zddvm1Z/DF3JRw1qFp6GGcuRai1
KNcJ1j8c9wtIgktpsteU3e5+bxHEw8NT3gWXUFYjm00NDq97Jals8Jjktmum2nQxoF7ivPacfEey
gnSF6jRMkTsZObzc30hAhs0CEtc33hZLhPLHSn8pQ0WyvKJLHdd5s2yckgTZtqxC1Sbwe7WEgNXe
ZMX3pIkz+aoXsAL7GBLyVBMVQcyMoF0w8QGAaTe8sqatABwPqXidYRqNROTf62IYcMpV89XYgaTv
EwIn/oni9KOFd2BFVxRZbFGGC4IjvigsTBUijI+Dk6kVnDh240clGcc4

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Omtp+lCaqUx7Z4qdFj2zrN8LpCkit2eX4hlMtig+ielGm/x4FSZkpjoFmiqdKFPi2eg0pg09MSai
XyGH68UzAR7Xrj8f1jlIoUmMKp4GcxfdqfTeuu7kWGOJEP6cvgTjSJFj2gawDv7f4yZcltnK2x0L
e4GW/rBTmGvZtKWb2ahjINLxPuh3dDaSaWdb+zVgbtyrI5FrjxBkq+aOxSjyNsqnCx1L0uWbxnkl
88NbXN3dTaECXHNm/fsleayM5hKis7kTv9BFajJMGy+BhQlmIYpE+F5zchnTTFUFJZCz1sX9Fc8e
HcY7irB8mR3ajdzjUZLBQEMktp096Nheq3U75A==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
hpeBLwN9x2ZFDwroYLlUe5GjjDepHik2l0c2s3/6S7JPCRkzQSyt2V1Ad/JewAs/QNp5SXSbYYB4
rQl0My1LDMF3xw43r0g2IbcyHVpPhGp0W5msuQdF67afnsRv90iJYWLMI3QkYGCTWAzl4HrLxFSg
3z8XZRK670IcxznOrlvgHmIKsvubZrBkuc1EynrVb9Nw16QnIx2rc4WgcEXeFf+4i1RoYLDd3gXK
NFCNMdtaRYUThunFP6Z4ViZ5UnDmKq+IMhd31jTaqIlWOBDxPI1+v5RJYxIyTbn4rxlKR2fNbl5/
z4OUjBTd+1GH3I2OXlqmAOvIhpe2Z2HH7nZu/A==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Mt2RhTSUwEIEWeNARbyL+EdfS1UF6nPaL/fKl/7oO2gina93egwCWDLl1fbBtkfaPco0cu4MJ9K3
OraAsyHRlY+MNShmJ1LzAIA1LjZx4y55lu9dlQqSUXR7AW7wVbkg1864mK+hM/1XygU0jvebKNW9
B7xSER+asLO6pxi0mt7uC2PHxLPAYEszFhmnap82TtbDGdQ2qtyekY+ngs+N2fAdsblxVwJruiMl
e6XJ127M8N1mYwhWU2HtRpBOSnnKoHgD9fG51XK/rhk8DxT66QnX9uLPB+H25eDupBJGi1Y5o6x8
hOwZiSUVlBLh7brfzevh7+eRn+7es6wBas0+3w==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 28752)
`pragma protect data_block
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
3HZ7SuO7g3Ijl1F8KtVqkVGnEol51LzK
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
