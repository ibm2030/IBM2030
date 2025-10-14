# LJW2030 V2.0 by Lawrence Wilkinson, 2020/06/09

## This file is a general .xdc for the Zybo Z7 Rev. B
## It is compatible with the Zybo Z7-20 and Zybo Z7-10
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

##Clock signal
set_property -dict {PACKAGE_PIN K17 IOSTANDARD LVCMOS33} [get_ports sysclk]
create_clock -period 8.000 -name sys_clk_pin -waveform {0.000 4.000} -add [get_ports sysclk]


##Switches
set_property -dict {PACKAGE_PIN G15 IOSTANDARD LVCMOS33} [get_ports {sw[0]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {sw[1]}]
set_property -dict {PACKAGE_PIN W13 IOSTANDARD LVCMOS33} [get_ports {sw[2]}]
set_property -dict {PACKAGE_PIN T16 IOSTANDARD LVCMOS33} [get_ports {sw[3]}]


##Buttons
set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {pb[0]}]
set_property -dict {PACKAGE_PIN P16 IOSTANDARD LVCMOS33} [get_ports {pb[1]}]
set_property -dict {PACKAGE_PIN K19 IOSTANDARD LVCMOS33} [get_ports {pb[2]}]
set_property -dict {PACKAGE_PIN Y16 IOSTANDARD LVCMOS33} [get_ports {pb[3]}]


##LEDs
set_property -dict {PACKAGE_PIN M14 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN M15 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN G14 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN D18 IOSTANDARD LVCMOS33} [get_ports {led[3]}]


##RGB LED 5 (Zybo Z7-20 only)
#set_property -dict { PACKAGE_PIN Y11   IOSTANDARD LVCMOS33 } [get_ports { led5_r }]; #IO_L18N_T2_13 Sch=led5_r
#set_property -dict { PACKAGE_PIN T5    IOSTANDARD LVCMOS33 } [get_ports { led5_g }]; #IO_L19P_T3_13 Sch=led5_g
#set_property -dict { PACKAGE_PIN Y12   IOSTANDARD LVCMOS33 } [get_ports { led5_b }]; #IO_L20P_T3_13 Sch=led5_b

##RGB LED 6
#set_property -dict { PACKAGE_PIN V16   IOSTANDARD LVCMOS33 } [get_ports { led6_r }]; #IO_L18P_T2_34 Sch=led6_r
#set_property -dict { PACKAGE_PIN F17   IOSTANDARD LVCMOS33 } [get_ports { led6_g }]; #IO_L6N_T0_VREF_35 Sch=led6_g
#set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { led6_b }]; #IO_L8P_T1_AD10P_35 Sch=led6_b


##Audio Codec
#set_property -dict { PACKAGE_PIN R19   IOSTANDARD LVCMOS33 } [get_ports { ac_bclk }]; #IO_0_34 Sch=ac_bclk
#set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { ac_mclk }]; #IO_L19N_T3_VREF_34 Sch=ac_mclk
#set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { ac_muten }]; #IO_L23N_T3_34 Sch=ac_muten
#set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { ac_pbdat }]; #IO_L20N_T3_34 Sch=ac_pbdat
#set_property -dict { PACKAGE_PIN T19   IOSTANDARD LVCMOS33 } [get_ports { ac_pblrc }]; #IO_25_34 Sch=ac_pblrc
#set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { ac_recdat }]; #IO_L19P_T3_34 Sch=ac_recdat
#set_property -dict { PACKAGE_PIN Y18   IOSTANDARD LVCMOS33 } [get_ports { ac_reclrc }]; #IO_L17P_T2_34 Sch=ac_reclrc
#set_property -dict { PACKAGE_PIN N18   IOSTANDARD LVCMOS33 } [get_ports { ac_scl }]; #IO_L13P_T2_MRCC_34 Sch=ac_scl
#set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { ac_sda }]; #IO_L23P_T3_34 Sch=ac_sda


##Additional Ethernet signals
#set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33  PULLUP true    } [get_ports { eth_int_pu_b }]; #IO_L6P_T0_35 Sch=eth_int_pu_b
#set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { eth_rst_b }]; #IO_L3P_T0_DQS_AD1P_35 Sch=eth_rst_b


##USB-OTG over-current detect pin
#set_property -dict { PACKAGE_PIN U13   IOSTANDARD LVCMOS33 } [get_ports { otg_oc }]; #IO_L3P_T0_DQS_PUDC_B_34 Sch=otg_oc


##Fan (Zybo Z7-20 only)
#set_property -dict { PACKAGE_PIN Y13   IOSTANDARD LVCMOS33  PULLUP true    } [get_ports { fan_fb_pu }]; #IO_L20N_T3_13 Sch=fan_fb_pu


##HDMI RX
#set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_hpd }]; #IO_L22N_T3_34 Sch=hdmi_rx_hpd
#set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_scl }]; #IO_L22P_T3_34 Sch=hdmi_rx_scl
#set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_sda }]; #IO_L17N_T2_34 Sch=hdmi_rx_sda
#set_property -dict { PACKAGE_PIN U19   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_clk_n }]; #IO_L12N_T1_MRCC_34 Sch=hdmi_rx_clk_n
#set_property -dict { PACKAGE_PIN U18   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_clk_p }]; #IO_L12P_T1_MRCC_34 Sch=hdmi_rx_clk_p
#set_property -dict { PACKAGE_PIN W20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_n[0] }]; #IO_L16N_T2_34 Sch=hdmi_rx_n[0]
#set_property -dict { PACKAGE_PIN V20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_p[0] }]; #IO_L16P_T2_34 Sch=hdmi_rx_p[0]
#set_property -dict { PACKAGE_PIN U20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_n[1] }]; #IO_L15N_T2_DQS_34 Sch=hdmi_rx_n[1]
#set_property -dict { PACKAGE_PIN T20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_p[1] }]; #IO_L15P_T2_DQS_34 Sch=hdmi_rx_p[1]
#set_property -dict { PACKAGE_PIN P20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_n[2] }]; #IO_L14N_T2_SRCC_34 Sch=hdmi_rx_n[2]
#set_property -dict { PACKAGE_PIN N20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_p[2] }]; #IO_L14P_T2_SRCC_34 Sch=hdmi_rx_p[2]

##HDMI RX CEC (Zybo Z7-20 only)
#set_property -dict { PACKAGE_PIN Y8    IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_cec }]; #IO_L14N_T2_SRCC_13 Sch=hdmi_rx_cec


##HDMI TX
#set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_hpd }]; #IO_L5P_T0_AD9P_35 Sch=hdmi_tx_hpd
#set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_scl }]; #IO_L16P_T2_35 Sch=hdmi_tx_scl
#set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_sda }]; #IO_L16N_T2_35 Sch=hdmi_tx_sda
set_property -dict {PACKAGE_PIN H17 IOSTANDARD TMDS_33} [get_ports hdmi_tx_clk_n]
set_property -dict {PACKAGE_PIN H16 IOSTANDARD TMDS_33} [get_ports hdmi_tx_clk_p]
set_property -dict {PACKAGE_PIN D20 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_data_n[0]}]
set_property -dict {PACKAGE_PIN D19 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_data_p[0]}]
set_property -dict {PACKAGE_PIN B20 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_data_n[1]}]
set_property -dict {PACKAGE_PIN C20 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_data_p[1]}]
set_property -dict {PACKAGE_PIN A20 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_data_n[2]}]
set_property -dict {PACKAGE_PIN B19 IOSTANDARD TMDS_33} [get_ports {hdmi_tx_data_p[2]}]

##HDMI TX CEC
#set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_cec }]; #IO_L5N_T0_AD9N_35 Sch=hdmi_tx_cec


##Pmod Header JA (XADC)
#set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { ja[0] }]; #IO_L21P_T3_DQS_AD14P_35 Sch=JA1_R_p
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { ja[1] }]; #IO_L22P_T3_AD7P_35 Sch=JA2_R_P
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports serialTx]
set_property -dict {PACKAGE_PIN K14 IOSTANDARD LVCMOS33} [get_ports serialRx]
#set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { ja[4] }]; #IO_L21N_T3_DQS_AD14N_35 Sch=JA1_R_N
#set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { ja[5] }]; #IO_L22N_T3_AD7N_35 Sch=JA2_R_N
#set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { ja[6] }]; #IO_L24N_T3_AD15N_35 Sch=JA3_R_N
#set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { ja[7] }]; #IO_L20N_T3_AD6N_35 Sch=JA4_R_N


##Pmod Header JB (Zybo Z7-20 only) MAX7291 (FS Panel)
set_property -dict {PACKAGE_PIN V8 IOSTANDARD LVCMOS33} [get_ports MAX7219_CLK]
set_property -dict {PACKAGE_PIN W8 IOSTANDARD LVCMOS33} [get_ports MAX7219_LOAD]
set_property -dict {PACKAGE_PIN U7 IOSTANDARD LVCMOS33} [get_ports MAX7219_DIN]
#set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33     } [get_ports { jb[3] }]; #IO_L11N_T1_SRCC_13 Sch=jb_n[2]
#set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33     } [get_ports { jb[4] }]; #IO_L13P_T2_MRCC_13 Sch=jb_p[3]
#set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33     } [get_ports { jb[5] }]; #IO_L13N_T2_MRCC_13 Sch=jb_n[3]
#set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33     } [get_ports { jb[6] }]; #IO_L22P_T3_13 Sch=jb_p[4]
#set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33     } [get_ports { jb[7] }]; #IO_L22N_T3_13 Sch=jb_n[4]


##Pmod Header JC VGA J1 (R + B)
set_property -dict {PACKAGE_PIN V15 IOSTANDARD LVCMOS33} [get_ports {vga_r[0]}]
set_property -dict {PACKAGE_PIN W15 IOSTANDARD LVCMOS33} [get_ports {vga_r[1]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {vga_r[2]}]
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {vga_r[3]}]
set_property -dict {PACKAGE_PIN W14 IOSTANDARD LVCMOS33} [get_ports {vga_b[0]}]
set_property -dict {PACKAGE_PIN Y14 IOSTANDARD LVCMOS33} [get_ports {vga_b[1]}]
set_property -dict {PACKAGE_PIN T12 IOSTANDARD LVCMOS33} [get_ports {vga_b[2]}]
set_property -dict {PACKAGE_PIN U12 IOSTANDARD LVCMOS33} [get_ports {vga_b[3]}]


##Pmod Header JD (VGA J2) (G + sync)
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {vga_g[0]}]
set_property -dict {PACKAGE_PIN T15 IOSTANDARD LVCMOS33} [get_ports {vga_g[1]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {vga_g[2]}]
set_property -dict {PACKAGE_PIN R14 IOSTANDARD LVCMOS33} [get_ports {vga_g[3]}]
set_property -dict {PACKAGE_PIN U14 IOSTANDARD LVCMOS33} [get_ports vga_hs]
set_property -dict {PACKAGE_PIN U15 IOSTANDARD LVCMOS33} [get_ports vga_vs]
#set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33     } [get_ports { jd[6] }]; #IO_L21P_T3_DQS_34 Sch=jd_p[4]
#set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33     } [get_ports { jd[7] }]; #IO_L21N_T3_DQS_34 Sch=jd_n[4]


##Pmod Header JE (MAX6951 LEDs + MAX7318 Switches)
set_property -dict {PACKAGE_PIN V12 IOSTANDARD LVCMOS33} [get_ports MAX7318_SCL]
set_property -dict {PACKAGE_PIN W16 IOSTANDARD LVCMOS33} [get_ports MAX7318_SDA]
set_property -dict {PACKAGE_PIN J15 IOSTANDARD LVCMOS33} [get_ports MAX6951_CLK]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports MAX6951_DIN]
set_property -dict {PACKAGE_PIN V13 IOSTANDARD LVCMOS33} [get_ports MAX6951_CS0]
set_property -dict {PACKAGE_PIN U17 IOSTANDARD LVCMOS33} [get_ports MAX6951_CS1]
set_property -dict {PACKAGE_PIN T17 IOSTANDARD LVCMOS33} [get_ports MAX6951_CS2]
set_property -dict {PACKAGE_PIN Y17 IOSTANDARD LVCMOS33} [get_ports MAX6951_CS3]


##Pcam MIPI CSI-2 Connector
## This configuration expects the sensor to use 672Mbps/lane = 336 MHz HS_Clk
#create_clock -period 2.976 -name dphy_hs_clock_clk_p -waveform {0.000 1.488} [get_ports dphy_hs_clock_clk_p]
#set_property INTERNAL_VREF 0.6 [get_iobanks 35]
#set_property -dict { PACKAGE_PIN J19   IOSTANDARD HSUL_12     } [get_ports { dphy_clk_lp_n }]; #IO_L10N_T1_AD11N_35 Sch=lp_clk_n
#set_property -dict { PACKAGE_PIN H20   IOSTANDARD HSUL_12     } [get_ports { dphy_clk_lp_p }]; #IO_L17N_T2_AD5N_35 Sch=lp_clk_p
#set_property -dict { PACKAGE_PIN M18   IOSTANDARD HSUL_12     } [get_ports { dphy_data_lp_n[0] }]; #IO_L8N_T1_AD10N_35 Sch=lp_lane_n[0]
#set_property -dict { PACKAGE_PIN L19   IOSTANDARD HSUL_12     } [get_ports { dphy_data_lp_p[0] }]; #IO_L9P_T1_DQS_AD3P_35 Sch=lp_lane_p[0]
#set_property -dict { PACKAGE_PIN L20   IOSTANDARD HSUL_12     } [get_ports { dphy_data_lp_n[1] }]; #IO_L9N_T1_DQS_AD3N_35 Sch=lp_lane_n[1]
#set_property -dict { PACKAGE_PIN J20   IOSTANDARD HSUL_12     } [get_ports { dphy_data_lp_p[1] }]; #IO_L17P_T2_AD5P_35 Sch=lp_lane_p[1]
#set_property -dict { PACKAGE_PIN H18   IOSTANDARD LVDS_25     } [get_ports { dphy_hs_clock_clk_n }]; #IO_L14N_T2_AD4N_SRCC_35 Sch=mipi_clk_n
#set_property -dict { PACKAGE_PIN J18   IOSTANDARD LVDS_25     } [get_ports { dphy_hs_clock_clk_p }]; #IO_L14P_T2_AD4P_SRCC_35 Sch=mipi_clk_p
#set_property -dict { PACKAGE_PIN M20   IOSTANDARD LVDS_25     } [get_ports { dphy_data_hs_n[0] }]; #IO_L7N_T1_AD2N_35 Sch=mipi_lane_n[0]
#set_property -dict { PACKAGE_PIN M19   IOSTANDARD LVDS_25     } [get_ports { dphy_data_hs_p[0] }]; #IO_L7P_T1_AD2P_35 Sch=mipi_lane_p[0]
#set_property -dict { PACKAGE_PIN L17   IOSTANDARD LVDS_25     } [get_ports { dphy_data_hs_n[1] }]; #IO_L11N_T1_SRCC_35 Sch=mipi_lane_n[1]
#set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVDS_25     } [get_ports { dphy_data_hs_p[1] }]; #IO_L11P_T1_SRCC_35 Sch=mipi_lane_p[1]
#set_property -dict { PACKAGE_PIN G19   IOSTANDARD LVCMOS33 } [get_ports { cam_clk }]; #IO_L18P_T2_AD13P_35 Sch=cam_clk
#set_property -dict { PACKAGE_PIN G20   IOSTANDARD LVCMOS33 	PULLUP true} [get_ports { cam_gpio }]; #IO_L18N_T2_AD13N_35 Sch=cam_gpio
#set_property -dict { PACKAGE_PIN F20   IOSTANDARD LVCMOS33 } [get_ports { cam_scl }]; #IO_L15N_T2_DQS_AD12N_35 Sch=cam_scl
#set_property -dict { PACKAGE_PIN F19   IOSTANDARD LVCMOS33 } [get_ports { cam_sda }]; #IO_L15P_T2_DQS_AD12P_35 Sch=cam_sda


##Unloaded Crypto Chip SWI (for future use)
#set_property -dict { PACKAGE_PIN P19   IOSTANDARD LVCMOS33 } [get_ports { crypto_sda }]; #IO_L13N_T2_MRCC_34 Sch=crypto_sda


##Unconnected Pins (Zybo Z7-20 only)
#set_property PACKAGE_PIN T9 [get_ports {netic19_t9}]; #IO_L12P_T1_MRCC_13
#set_property PACKAGE_PIN U10 [get_ports {netic19_u10}]; #IO_L12N_T1_MRCC_13
#set_property PACKAGE_PIN U5 [get_ports {netic19_u5}]; #IO_L19N_T3_VREF_13
#set_property PACKAGE_PIN U8 [get_ports {netic19_u8}]; #IO_L17N_T2_13
#set_property PACKAGE_PIN U9 [get_ports {netic19_u9}]; #IO_L17P_T2_13
#set_property PACKAGE_PIN V10 [get_ports {netic19_v10}]; #IO_L21N_T3_DQS_13
#set_property PACKAGE_PIN V11 [get_ports {netic19_v11}]; #IO_L21P_T3_DQS_13
#set_property PACKAGE_PIN V5 [get_ports {netic19_v5}]; #IO_L6N_T0_VREF_13
#set_property PACKAGE_PIN W10 [get_ports {netic19_w10}]; #IO_L16P_T2_13
#set_property PACKAGE_PIN W11 [get_ports {netic19_w11}]; #IO_L18P_T2_13
#set_property PACKAGE_PIN W9 [get_ports {netic19_w9}]; #IO_L16N_T2_13
#set_property PACKAGE_PIN Y9 [get_ports {netic19_y9}]; #IO_L14P_T2_SRCC_13


# Zybo Z7 7020, Digilent
# pin locations
# LJW2030 V2.0 by Lawrence Wilkinson, 2020/06/09
#
# Remove the comment symbols (#) in front of the desired lines.
# The names of the ports must match exactly between this file and the design.

# clock
#NET "clk" LOC = "T9"; # 50 MHz

# LEDs
#NET "led<7>" LOC = "P11";
#NET "led<6>" LOC = "P12";
#NET "led<5>" LOC = "N12";
#NET "led<4>" LOC = "P13";
#NET "led<3>" LOC = "N14";
#NET "led<2>" LOC = "L12";
#NET "led<1>" LOC = "P14";
#NET "led<0>" LOC = "K12";

# slide switches
#NET "sw<7>" LOC = "K13";
#NET "sw<6>" LOC = "K14";
#NET "sw<5>" LOC = "J13";
#NET "sw<4>" LOC = "J14";
#NET "sw<3>" LOC = "H13";
#NET "sw<2>" LOC = "H14";
#NET "sw<1>" LOC = "G12";
#NET "sw<0>" LOC = "F12";

# push buttons
#NET "pb<3>" LOC = "L14";
#NET "pb<2>" LOC = "L13";
#NET "pb<1>" LOC = "M14";
#NET "pb<0>" LOC = "M13";

# seven segment display - shared segments
#NET "ssd<7>" LOC = "P16";
#NET "ssd<6>" LOC = "N16";
#NET "ssd<5>" LOC = "F13";
#NET "ssd<4>" LOC = "R16";
#NET "ssd<3>" LOC = "P15";
#NET "ssd<2>" LOC = "N15";
#NET "ssd<1>" LOC = "G13";
#NET "ssd<0>" LOC = "E14";

# seven segment display - anodes
#NET "ssdan<3>" LOC = "E13";
#NET "ssdan<2>" LOC = "F14";
#NET "ssdan<1>" LOC = "G14";
#NET "ssdan<0>" LOC = "D14";

# VGA port
#NET "vga_r" LOC = "R12";
#NET "vga_g" LOC = "T12";
#NET "vga_b" LOC = "R11";
#NET "vga_hs" LOC = "R9";
#NET "vga_vs" LOC = "T10";

# PS/2 port
#NET "ps2_clk" LOC="M16";
#NET "ps2_data" LOC="M15";

# Expansion ports
#A1
#A2
# 1 Gnd
# 2 VU (+5V)
# 3 Vcco (+3.3V)
#NET "pa_io1" LOC="E6"; # HexSw Bit0
#NET "pa_io1" PULLDOWN;
#NET "pa_io2" LOC="D5"; # HexSw Bit1
#NET "pa_io2" PULLDOWN;
#NET "pa_io3" LOC="C5"; # HexSw Bit2
#NET "pa_io3" PULLDOWN;
#NET "pa_io4" LOC="D6"; # HexSw Bit3
#NET "pa_io4" PULLDOWN;
#NET "pa_io5" LOC="C6";   # HexSwA
#NET "pa_io6" LOC="E7";   # HexSwB
# 10:
#NET "pa_io7" LOC="C7";   # HexSwC
#NET "pa_io8" LOC="D7";   # HexSwD
#NET "pa_io9" LOC="C8";   # HexSwE
#NET "pa_io10" LOC="D8";  # HexSwF
#NET "pa_io11" LOC="C9";  # HexSwG
#NET "pa_io12" LOC="D10"; # HexSwH
#NET "pa_io13" LOC="A3";  # HexSwJ
#NET "pa_io14" LOC="B4";  # HexSwAdrComp
#NET "pa_io15" LOC="A4"; # SwE Inner
#NET "pa_io15" PULLDOWN;
#NET "pa_io16" LOC="B5"; # SwE Outer
#NET "pa_io16" PULLDOWN;
# 20:
#NET "pa_io17" LOC="A5"; # ROS Ctl INH_CF_STOP
#NET "pa_io17" PULLDOWN;
#NET "pa_io18" LOC="B6";  # ROS Ctl SCAN
#NET "pa_io18" PULLDOWN;
#NET "ma2_db0" LOC="B7";  # Rate INST_STEP
#NET "ma2_db0" PULLDOWN;
#NET "ma2_db1" LOC="A7";  # Rate SINGLE_CYCLE
#NET "ma2_db1" PULLDOWN;
#NET "ma2_db2" LOC="B8"; # Chk Ctk DIAGNOSTIC
#NET "ma2_db2" PULLDOWN;
#NET "ma2_db3" LOC="A8"; # Chk Ctl DISABLE
#NET "ma2_db3" PULLDOWN;
#NET "ma2_db4" LOC="A9"; # Chk Ctl STOP
#NET "ma2_db4" PULLDOWN;
#NET "ma2_db5" LOC="B10"; # Chk Ctl RESTART
#NET "ma2_db5" PULLDOWN;
#NET "ma2_db6" LOC="A10"; # Sys Reset
#NET "ma2_db6" PULLDOWN;
#NET "ma2_db7" LOC="B11"; # ROAR Reset
#NET "ma2_db7" PULLDOWN;
# 30:
#NET "ma2_astb" LOC="B12"; # Start
#NET "ma2_astb" PULLDOWN;
#NET "ma2_dstb" LOC="A12"; # Stop
#NET "ma2_dstb" PULLDOWN;
#NET "ma2_write" LOC="B13"; # Display
#NET "ma2_write" PULLDOWN;
#NET "ma2_wait" LOC="A13"; # Store
#NET "ma2_wait" PULLDOWN;
#NET "ma2_reset" LOC="B14"; # Set IC
#NET "ma2_reset" PULLDOWN;
#NET "ma2_int" LOC="D9"; # Check Reset
#NET "ma2_int" PULLDOWN;

#A3

# For the other peripherals and ports listed here,
# consult the Xilinx documentation.
# RS-232 port
#NET "serialRx" LOC="T13";
#NET "serialTx" LOC="R13";

# expansion connectors
#
# B1
# 1 Gnd
# 2 VU (+5V)
# 3 Vcco (+3.3V)
#NET "MAX7219_CLK" LOC="C10";  # B1- 4
#NET "MAX7219_LOAD" LOC="T3";  # B1- 5
#NET "MAX7219_DIN" LOC="E10"; # B1- 6
#NET "MAX7318_SCL" LOC="N11"; # B1- 7
#NET "MAX7318_SDA" LOC="C11"; # B1- 8
#NET "MAX7318_SDA" PULLUP;
#NET "B1-09" LOC="P10"; # B1- 9
#NET "MAX6951_CLK" LOC="D11";  # B1-10
#NET "MAX6951_CS0" LOC="R10";  # B1-11
#NET "MAX6951_CS1" LOC="C12";  # B1-12
#NET "MAX6951_CS2" LOC="T7";   # B1-13
#NET "MAX6951_CS3" LOC="D12";  # B1-14
#NET "MAX6951_DIN" LOC="R7";   # B1-15
#NET "B1-16" LOC="E11";
#NET "B1-17" LOC="N6";
#NET "B1-18" LOC="B16";
#NET "B1-19" LOC="M6";
#NET "B1-20" LOC="R3";
#NET "B1-21" LOC="C15";
#NET "B1-22" LOC="C16";
#NET "B1-23" LOC="D15";
#NET "B1-24" LOC="D16";
#NET "B1-25" LOC="E15";
#NET "B1-26" LOC="E16";
#NET "B1-27" LOC="F15";
#NET "B1-28" LOC="G15";
#NET "B1-29" LOC="G16";
#NET "B1-30" LOC="H15";
#NET "B1-31" LOC="H16";
#NET "B1-32" LOC="J16";
#NET "B1-33" LOC="K16";
#NET "B1-34" LOC="K15";
#NET "B1-35" LOC="L15";
#NET "B1-36" LOC="B3";
#NET "B1-37" LOC="R14";
#NET "B1-38" LOC="N9";
#NET "B1-39" LOC="T15";
#NET "B1-40" LOC="M11";

#
# XCF04S Serial PROM connections
#
#NET "din" LOC = "M11";
#NET "reset_prom" LOC = "N9";
#NET "rclk" LOC = "A14";
#NET "progb" LOC="B3";
#NET "fpgadone" LOC="R14";
#NET "fpgacclk" LOC="T15";


connect_debug_port dbg_hub/clk [get_nets clk]

connect_debug_port u_ila_1/probe1 [get_nets [list zybo2030_i/ibm2030_0/U0/frontPanel_switches/RawSw_Start]]

connect_debug_port u_ila_0/probe0 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[0]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[1]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[2]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[3]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[4]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[5]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[6]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[7]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[8]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[9]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[10]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[11]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[12]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[13]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[14]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[15]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[16]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[17]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[18]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[19]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[20]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[21]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[22]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[23]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[24]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[25]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[26]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[27]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[28]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[29]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[30]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[31]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[32]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[33]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[34]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[35]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[36]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[37]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[38]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[39]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[40]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[41]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[42]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[43]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[44]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[45]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[46]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[47]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[48]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[49]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[50]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[51]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[52]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[53]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[54]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[55]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[56]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[57]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[58]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[59]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[60]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[61]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[62]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[63]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[64]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[65]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[66]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[67]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[68]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[69]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[70]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[71]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[72]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[73]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[74]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[75]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[76]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[77]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[78]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[79]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[80]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[81]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[82]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[83]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[84]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[85]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[86]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[87]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[88]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[89]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[90]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[91]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[92]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[93]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[94]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[95]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[96]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[97]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[98]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[99]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[100]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[101]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[102]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[103]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[104]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[105]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[106]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[107]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[108]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[109]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[110]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[111]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[112]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[113]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[114]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[115]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[116]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[117]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[118]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[119]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[120]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[121]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[122]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[123]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[124]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[125]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[126]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[127]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[128]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[129]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[130]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[131]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[132]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[133]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[134]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[135]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[136]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[137]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[138]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[139]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[140]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[141]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[142]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[143]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[144]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[145]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[146]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[147]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[148]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[149]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[150]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[151]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[152]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[153]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[154]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[155]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[156]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[157]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[158]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[159]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[160]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[161]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[162]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[163]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[164]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[165]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[166]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[167]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[168]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[169]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[170]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[171]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[172]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[173]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[174]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[175]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[176]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[177]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[178]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[179]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[180]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[181]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[182]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[183]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[184]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[185]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[186]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[187]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[188]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[189]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[190]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[191]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[192]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[193]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[194]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[195]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[196]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[197]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[198]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[199]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[200]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[201]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[202]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[203]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[204]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[205]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[206]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[207]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[208]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[209]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[210]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[211]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[212]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[213]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[214]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[215]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[216]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[217]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[218]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[219]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[220]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[221]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[222]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[223]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[224]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[225]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[226]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[227]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[228]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[229]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[230]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[231]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[232]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[233]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[234]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[235]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[236]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[237]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[238]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[239]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[240]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[241]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[242]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[243]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[244]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[245]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[246]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[247]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[248]} {zybo2030_i/ibm2030_0/U0/frontPanel/p_1_in[249]}]]
connect_debug_port u_ila_1/probe0 [get_nets [list {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[0]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[1]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[2]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[3]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[4]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[5]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[6]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[7]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[8]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[9]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[10]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[11]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[12]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[13]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[14]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[15]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[16]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[17]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[18]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[19]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[20]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[21]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[22]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[23]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[24]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[25]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[26]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[27]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[28]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[29]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[30]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[31]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[32]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[33]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[34]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[35]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[36]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[37]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[38]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[39]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[40]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[41]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[42]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[43]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[44]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[45]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[46]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[47]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[48]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[49]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[50]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[51]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[52]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[53]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[54]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[55]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[56]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[57]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[58]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[59]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[60]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[61]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[62]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_1[63]}]]
connect_debug_port u_ila_1/probe1 [get_nets [list {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[0]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[1]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[2]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[3]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[4]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[5]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[6]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[7]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[8]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[9]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[10]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[11]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[12]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[13]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[14]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[15]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[16]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[17]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[18]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[19]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[20]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[21]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[22]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[23]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[24]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[25]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[26]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[27]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[28]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[29]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[30]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[31]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[32]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[33]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[34]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[35]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[36]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[37]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[38]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[39]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[40]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[41]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[42]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[43]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[44]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[45]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[46]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[47]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[48]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[49]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[50]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[51]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[52]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[53]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[55]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[56]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[57]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[58]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[59]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[60]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[61]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[62]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_3[63]}]]
connect_debug_port u_ila_1/probe2 [get_nets [list {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[0]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[1]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[2]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[3]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[4]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[5]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[6]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[7]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[8]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[9]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[10]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[11]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[12]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[13]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[14]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[15]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[16]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[17]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[18]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[19]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[20]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[21]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[22]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[23]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[24]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[25]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[26]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[27]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[28]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[29]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[30]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[31]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[32]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[33]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[34]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[35]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[36]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[37]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[38]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[39]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[40]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[41]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[42]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[43]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[44]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[45]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[46]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[47]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[48]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[49]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[50]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[51]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[52]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[53]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[54]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[55]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[56]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[57]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[58]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[59]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[60]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[61]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[62]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_0[63]}]]
connect_debug_port u_ila_1/probe3 [get_nets [list {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[0]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[1]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[2]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[3]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[4]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[5]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[6]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[7]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[8]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[9]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[10]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[11]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[12]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[13]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[14]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[15]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[16]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[17]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[18]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[19]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[20]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[21]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[22]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[23]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[24]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[25]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[26]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[27]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[28]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[29]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[30]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[31]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[32]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[33]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[34]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[35]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[36]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[37]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[38]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[39]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[40]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[41]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[42]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[43]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[44]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[45]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[46]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[47]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[48]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[49]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[50]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[51]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[52]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[53]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[54]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[55]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[56]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[57]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[58]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[59]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[60]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[61]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[62]} {zybo2030_i/ibm2030_0/U0/cpu/INDICATORS_2[63]}]]

create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list zybo2030_i/clk_wiz_0/inst/clk_out2]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 256 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[255]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[254]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[253]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[252]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[251]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[250]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[249]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[248]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[247]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[246]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[245]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[244]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[243]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[242]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[241]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[240]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[239]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[238]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[237]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[236]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[235]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[234]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[233]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[232]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[231]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[230]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[229]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[228]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[227]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[226]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[225]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[224]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[223]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[222]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[221]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[220]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[219]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[218]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[217]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[216]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[215]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[214]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[213]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[212]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[211]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[210]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[209]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[208]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[207]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[206]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[205]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[204]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[203]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[202]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[201]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[200]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[199]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[198]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[197]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[196]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[195]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[194]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[193]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[192]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[191]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[190]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[189]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[188]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[187]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[186]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[185]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[184]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[183]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[182]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[181]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[180]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[179]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[178]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[177]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[176]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[175]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[174]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[173]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[172]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[171]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[170]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[169]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[168]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[167]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[166]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[165]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[164]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[163]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[162]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[161]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[160]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[159]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[158]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[157]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[156]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[155]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[154]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[153]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[152]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[151]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[150]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[149]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[148]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[147]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[146]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[145]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[144]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[143]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[142]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[141]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[140]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[139]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[138]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[137]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[136]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[135]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[134]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[133]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[132]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[131]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[130]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[129]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[128]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[127]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[126]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[125]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[124]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[123]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[122]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[121]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[120]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[119]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[118]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[117]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[116]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[115]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[114]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[113]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[112]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[111]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[110]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[109]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[108]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[107]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[106]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[105]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[104]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[103]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[102]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[101]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[100]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[99]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[98]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[97]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[96]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[95]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[94]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[93]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[92]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[91]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[90]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[89]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[88]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[87]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[86]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[85]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[84]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[83]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[82]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[81]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[80]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[79]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[78]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[77]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[76]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[75]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[74]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[73]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[72]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[71]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[70]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[69]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[68]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[67]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[66]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[65]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[64]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[63]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[62]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[61]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[60]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[59]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[58]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[57]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[56]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[55]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[54]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[53]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[52]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[51]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[50]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[49]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[48]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[47]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[46]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[45]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[44]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[43]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[42]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[41]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[40]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[39]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[38]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[37]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[36]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[35]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[34]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[33]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[32]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[31]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[30]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[29]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[28]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[27]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[26]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[25]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[24]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[23]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[22]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[21]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[20]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[19]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[18]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[17]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[16]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[15]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[14]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[13]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[12]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[11]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[10]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[9]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[8]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[7]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[6]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[5]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[4]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[3]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[2]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[1]} {zybo2030_i/ibm2030_0/U0/frontPanel/Indicators[0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 4 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwH[0]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwH[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwH[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwH[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 4 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE_combined[0]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE_combined[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE_combined[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE_combined[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 4 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwC[0]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwC[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwC[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwC[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 4 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwG[0]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwG[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwG[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwG[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 4 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/debounceLampTest[3]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/debounceLampTest[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/debounceLampTest[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/debounceLampTest[0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 4 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwB[0]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwB[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwB[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwB[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 4 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwF[0]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwF[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwF[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwF[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 4 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwD[0]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwD[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwD[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwD[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 4 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwJ[0]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwJ[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwJ[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwJ[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 4 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwA[0]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwA[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwA[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwA[3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 4 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/debounceStart[3]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/debounceStart[2]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/debounceStart[1]} {zybo2030_i/ibm2030_0/U0/frontPanel_switches/debounceStart[0]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list zybo2030_i/ibm2030_0/U0/frontPanel_switches/Sw_CheckReset]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list zybo2030_i/ibm2030_0/U0/frontPanel_switches/Sw_Display]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list zybo2030_i/ibm2030_0/U0/frontPanel_switches/Sw_Interrupt]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list zybo2030_i/ibm2030_0/U0/frontPanel_switches/Sw_LampTest]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list zybo2030_i/ibm2030_0/U0/frontPanel_switches/Sw_Load]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list zybo2030_i/ibm2030_0/U0/frontPanel_switches/Sw_Start]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list zybo2030_i/ibm2030_0/U0/frontPanel_switches/Sw_Stop]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list zybo2030_i/ibm2030_0/U0/frontPanel_switches/Sw_Store]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[C_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[D_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[E_SEL_SW_GS]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[E_SEL_SW_GT]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[E_SEL_SW_GUV_GCD]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[E_SEL_SW_HS]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[E_SEL_SW_HT]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe27]
set_property port_width 1 [get_debug_ports u_ila_0/probe27]
connect_debug_port u_ila_0/probe27 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[E_SEL_SW_HUV_HCD]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe28]
set_property port_width 1 [get_debug_ports u_ila_0/probe28]
connect_debug_port u_ila_0/probe28 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[F_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe29]
set_property port_width 1 [get_debug_ports u_ila_0/probe29]
connect_debug_port u_ila_0/probe29 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[FI_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe30]
set_property port_width 1 [get_debug_ports u_ila_0/probe30]
connect_debug_port u_ila_0/probe30 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[FT_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe31]
set_property port_width 1 [get_debug_ports u_ila_0/probe31]
connect_debug_port u_ila_0/probe31 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[G_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe32]
set_property port_width 1 [get_debug_ports u_ila_0/probe32]
connect_debug_port u_ila_0/probe32 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[H_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe33]
set_property port_width 1 [get_debug_ports u_ila_0/probe33]
connect_debug_port u_ila_0/probe33 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[I_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe34]
set_property port_width 1 [get_debug_ports u_ila_0/probe34]
connect_debug_port u_ila_0/probe34 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[J_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe35]
set_property port_width 1 [get_debug_ports u_ila_0/probe35]
connect_debug_port u_ila_0/probe35 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[JI_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe36]
set_property port_width 1 [get_debug_ports u_ila_0/probe36]
connect_debug_port u_ila_0/probe36 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[L_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe37]
set_property port_width 1 [get_debug_ports u_ila_0/probe37]
connect_debug_port u_ila_0/probe37 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[LS_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe38]
set_property port_width 1 [get_debug_ports u_ila_0/probe38]
connect_debug_port u_ila_0/probe38 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[MS_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe39]
set_property port_width 1 [get_debug_ports u_ila_0/probe39]
connect_debug_port u_ila_0/probe39 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[Q_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe40]
set_property port_width 1 [get_debug_ports u_ila_0/probe40]
connect_debug_port u_ila_0/probe40 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[R_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe41]
set_property port_width 1 [get_debug_ports u_ila_0/probe41]
connect_debug_port u_ila_0/probe41 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[S_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe42]
set_property port_width 1 [get_debug_ports u_ila_0/probe42]
connect_debug_port u_ila_0/probe42 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[T_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe43]
set_property port_width 1 [get_debug_ports u_ila_0/probe43]
connect_debug_port u_ila_0/probe43 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[TI_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe44]
set_property port_width 1 [get_debug_ports u_ila_0/probe44]
connect_debug_port u_ila_0/probe44 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[TT_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe45]
set_property port_width 1 [get_debug_ports u_ila_0/probe45]
connect_debug_port u_ila_0/probe45 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[U_SEL]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe46]
set_property port_width 1 [get_debug_ports u_ila_0/probe46]
connect_debug_port u_ila_0/probe46 [get_nets [list {zybo2030_i/ibm2030_0/U0/frontPanel_switches/SwE[V_SEL]}]]
create_debug_core u_ila_1 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_1]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_1]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_1]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_1]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_1]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_1]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_1]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_1]
set_property port_width 1 [get_debug_ports u_ila_1/clk]
connect_debug_port u_ila_1/clk [get_nets [list zybo2030_i/clk_wiz_0/inst/clk_out1]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_1/probe0]
set_property port_width 1 [get_debug_ports u_ila_1/probe0]
connect_debug_port u_ila_1/probe0 [get_nets [list zybo2030_i/ibm2030_0/U0/frontPanel_switches/RawSw_LampTest]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets u_ila_1_clk_out1]
