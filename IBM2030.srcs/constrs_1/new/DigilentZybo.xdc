# LJW2030 V2.0 by Lawrence Wilkinson, 2020/06/09

## This file is a general .xdc for the Zybo Z7 Rev. B
## It is compatible with the Zybo Z7-20 and Zybo Z7-10
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

##Clock signal
#set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { sysclk }]; #IO_L12P_T1_MRCC_35 Sch=sysclk
#create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sysclk }];


##Switches
set_property -dict { PACKAGE_PIN G15   IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]; #IO_L19N_T3_VREF_35 Sch=sw[0]
set_property -dict { PACKAGE_PIN P15   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]; #IO_L24P_T3_34 Sch=sw[1]
set_property -dict { PACKAGE_PIN W13   IOSTANDARD LVCMOS33 } [get_ports { sw[2] }]; #IO_L4N_T0_34 Sch=sw[2]
set_property -dict { PACKAGE_PIN T16   IOSTANDARD LVCMOS33 } [get_ports { sw[3] }]; #IO_L9P_T1_DQS_34 Sch=sw[3]


##Buttons
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { pb[0] }]; #IO_L12N_T1_MRCC_35 Sch=btn[0]
set_property -dict { PACKAGE_PIN P16   IOSTANDARD LVCMOS33 } [get_ports { pb[1] }]; #IO_L24N_T3_34 Sch=btn[1]
set_property -dict { PACKAGE_PIN K19   IOSTANDARD LVCMOS33 } [get_ports { pb[2] }]; #IO_L10P_T1_AD11P_35 Sch=btn[2]
set_property -dict { PACKAGE_PIN Y16   IOSTANDARD LVCMOS33 } [get_ports { pb[3] }]; #IO_L7P_T1_34 Sch=btn[3]


##LEDs
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; #IO_L23P_T3_35 Sch=led[0]
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; #IO_L23N_T3_35 Sch=led[1]
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { led[2] }]; #IO_0_35 Sch=led[2]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]; #IO_L3N_T0_DQS_AD1N_35 Sch=led[3]


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
#set_property -dict { PACKAGE_PIN H17   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_clk_n }]; #IO_L13N_T2_MRCC_35 Sch=hdmi_tx_clk_n
#set_property -dict { PACKAGE_PIN H16   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_clk_p }]; #IO_L13P_T2_MRCC_35 Sch=hdmi_tx_clk_p
#set_property -dict { PACKAGE_PIN D20   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_n[0] }]; #IO_L4N_T0_35 Sch=hdmi_tx_n[0]
#set_property -dict { PACKAGE_PIN D19   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_p[0] }]; #IO_L4P_T0_35 Sch=hdmi_tx_p[0]
#set_property -dict { PACKAGE_PIN B20   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_n[1] }]; #IO_L1N_T0_AD0N_35 Sch=hdmi_tx_n[1]
#set_property -dict { PACKAGE_PIN C20   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_p[1] }]; #IO_L1P_T0_AD0P_35 Sch=hdmi_tx_p[1]
#set_property -dict { PACKAGE_PIN A20   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_n[2] }]; #IO_L2N_T0_AD8N_35 Sch=hdmi_tx_n[2]
#set_property -dict { PACKAGE_PIN B19   IOSTANDARD TMDS_33     } [get_ports { hdmi_tx_p[2] }]; #IO_L2P_T0_AD8P_35 Sch=hdmi_tx_p[2]

##HDMI TX CEC 
#set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_tx_cec }]; #IO_L5N_T0_AD9N_35 Sch=hdmi_tx_cec
 

##Pmod Header JA (XADC)
#set_property -dict { PACKAGE_PIN N15   IOSTANDARD LVCMOS33 } [get_ports { ja[0] }]; #IO_L21P_T3_DQS_AD14P_35 Sch=JA1_R_p		   
#set_property -dict { PACKAGE_PIN L14   IOSTANDARD LVCMOS33 } [get_ports { ja[1] }]; #IO_L22P_T3_AD7P_35 Sch=JA2_R_P             
#set_property -dict { PACKAGE_PIN K16   IOSTANDARD LVCMOS33 } [get_ports { ja[2] }]; #IO_L24P_T3_AD15P_35 Sch=JA3_R_P            
#set_property -dict { PACKAGE_PIN K14   IOSTANDARD LVCMOS33 } [get_ports { ja[3] }]; #IO_L20P_T3_AD6P_35 Sch=JA4_R_P             
#set_property -dict { PACKAGE_PIN N16   IOSTANDARD LVCMOS33 } [get_ports { ja[4] }]; #IO_L21N_T3_DQS_AD14N_35 Sch=JA1_R_N        
#set_property -dict { PACKAGE_PIN L15   IOSTANDARD LVCMOS33 } [get_ports { ja[5] }]; #IO_L22N_T3_AD7N_35 Sch=JA2_R_N             
#set_property -dict { PACKAGE_PIN J16   IOSTANDARD LVCMOS33 } [get_ports { ja[6] }]; #IO_L24N_T3_AD15N_35 Sch=JA3_R_N            
#set_property -dict { PACKAGE_PIN J14   IOSTANDARD LVCMOS33 } [get_ports { ja[7] }]; #IO_L20N_T3_AD6N_35 Sch=JA4_R_N             
 

##Pmod Header JB (Zybo Z7-20 only) VGA J1 (R+B)
#set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33     } [get_ports { jb[0] }]; #IO_L15P_T2_DQS_13 Sch=jb_p[1]		 
#set_property -dict { PACKAGE_PIN W8    IOSTANDARD LVCMOS33     } [get_ports { jb[1] }]; #IO_L15N_T2_DQS_13 Sch=jb_n[1]         
#set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33     } [get_ports { jb[2] }]; #IO_L11P_T1_SRCC_13 Sch=jb_p[2]        
#set_property -dict { PACKAGE_PIN V7    IOSTANDARD LVCMOS33     } [get_ports { jb[3] }]; #IO_L11N_T1_SRCC_13 Sch=jb_n[2]        
#set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33     } [get_ports { jb[4] }]; #IO_L13P_T2_MRCC_13 Sch=jb_p[3]        
#set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33     } [get_ports { jb[5] }]; #IO_L13N_T2_MRCC_13 Sch=jb_n[3]        
#set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33     } [get_ports { jb[6] }]; #IO_L22P_T3_13 Sch=jb_p[4]             
#set_property -dict { PACKAGE_PIN W6    IOSTANDARD LVCMOS33     } [get_ports { jb[7] }]; #IO_L22N_T3_13 Sch=jb_n[4]             
                                                                                                                                 
                                                                                                                                 
##Pmod Header JC VGA J2 (G+sync)                                                                                                                   
#set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33     } [get_ports { jc[0] }]; #IO_L10P_T1_34 Sch=jc_p[1]   			 
#set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33     } [get_ports { jc[1] }]; #IO_L10N_T1_34 Sch=jc_n[1]		     
#set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33     } [get_ports { jc[2] }]; #IO_L1P_T0_34 Sch=jc_p[2]              
#set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33     } [get_ports { jc[3] }]; #IO_L1N_T0_34 Sch=jc_n[2]              
#set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33     } [get_ports { jc[4] }]; #IO_L8P_T1_34 Sch=jc_p[3]              
#set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33     } [get_ports { jc[5] }]; #IO_L8N_T1_34 Sch=jc_n[3]              
#set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33     } [get_ports { jc[6] }]; #IO_L2P_T0_34 Sch=jc_p[4]              
#set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33     } [get_ports { jc[7] }]; #IO_L2N_T0_34 Sch=jc_n[4]              
                                                                                                                                 
                                                                                                                                 
##Pmod Header JD (SD)                                                                                                                  
#set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33     } [get_ports { jd[0] }]; #IO_L5P_T0_34 Sch=jd_p[1]                  
#set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33     } [get_ports { jd[1] }]; #IO_L5N_T0_34 Sch=jd_n[1]				 
#set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33     } [get_ports { jd[2] }]; #IO_L6P_T0_34 Sch=jd_p[2]                  
#set_property -dict { PACKAGE_PIN R14   IOSTANDARD LVCMOS33     } [get_ports { jd[3] }]; #IO_L6N_T0_VREF_34 Sch=jd_n[2]             
#set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33     } [get_ports { jd[4] }]; #IO_L11P_T1_SRCC_34 Sch=jd_p[3]            
#set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33     } [get_ports { jd[5] }]; #IO_L11N_T1_SRCC_34 Sch=jd_n[3]            
#set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33     } [get_ports { jd[6] }]; #IO_L21P_T3_DQS_34 Sch=jd_p[4]             
#set_property -dict { PACKAGE_PIN V18   IOSTANDARD LVCMOS33     } [get_ports { jd[7] }]; #IO_L21N_T3_DQS_34 Sch=jd_n[4]             
                                                                                                                                 
                                                                                                                                 
##Pmod Header JE (RS232)                                                                                                                  
#set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { je[0] }]; #IO_L4P_T0_34 Sch=je[1]						 
#set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { je[1] }]; #IO_L18N_T2_34 Sch=je[2]                     
#set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { je[2] }]; #IO_25_35 Sch=je[3]                          
#set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { je[3] }]; #IO_L19P_T3_35 Sch=je[4]                     
#set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { je[4] }]; #IO_L3N_T0_DQS_34 Sch=je[7]                  
#set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { je[5] }]; #IO_L9N_T1_DQS_34 Sch=je[8]                  
#set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { je[6] }]; #IO_L20P_T3_34 Sch=je[9]                     
#set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { je[7] }]; #IO_L7N_T1_34 Sch=je[10]                    


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
NET "clk" LOC = "T9"; # 50 MHz

# LEDs
NET "led<7>" LOC = "P11"; 
NET "led<6>" LOC = "P12";
NET "led<5>" LOC = "N12";
NET "led<4>" LOC = "P13";
#NET "led<3>" LOC = "N14";
#NET "led<2>" LOC = "L12";
#NET "led<1>" LOC = "P14";
#NET "led<0>" LOC = "K12";

# slide switches
NET "sw<7>" LOC = "K13"; 
NET "sw<6>" LOC = "K14";
NET "sw<5>" LOC = "J13";
NET "sw<4>" LOC = "J14";
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
NET "ssd<7>" LOC = "P16"; 
NET "ssd<6>" LOC = "N16";
NET "ssd<5>" LOC = "F13";
NET "ssd<4>" LOC = "R16";
NET "ssd<3>" LOC = "P15";
NET "ssd<2>" LOC = "N15";
NET "ssd<1>" LOC = "G13";
NET "ssd<0>" LOC = "E14";

# seven segment display - anodes
NET "ssdan<3>" LOC = "E13";
NET "ssdan<2>" LOC = "F14";
NET "ssdan<1>" LOC = "G14";
NET "ssdan<0>" LOC = "D14";

# VGA port
NET "vga_r" LOC = "R12";
NET "vga_g" LOC = "T12";
NET "vga_b" LOC = "R11";
NET "vga_hs" LOC = "R9";
NET "vga_vs" LOC = "T10";

# PS/2 port
#NET "ps2_clk" LOC="M16";
#NET "ps2_data" LOC="M15";

# Expansion ports
#A1
#A2
# 1 Gnd
# 2 VU (+5V)
# 3 Vcco (+3.3V)
NET "pa_io1" LOC="E6"; # HexSw Bit0
NET "pa_io1" PULLDOWN;
NET "pa_io2" LOC="D5"; # HexSw Bit1
NET "pa_io2" PULLDOWN;
NET "pa_io3" LOC="C5"; # HexSw Bit2
NET "pa_io3" PULLDOWN;
NET "pa_io4" LOC="D6"; # HexSw Bit3
NET "pa_io4" PULLDOWN;
NET "pa_io5" LOC="C6";   # HexSwA
NET "pa_io6" LOC="E7";   # HexSwB
# 10:
NET "pa_io7" LOC="C7";   # HexSwC
NET "pa_io8" LOC="D7";   # HexSwD
NET "pa_io9" LOC="C8";   # HexSwE
NET "pa_io10" LOC="D8";  # HexSwF 
NET "pa_io11" LOC="C9";  # HexSwG
NET "pa_io12" LOC="D10"; # HexSwH
NET "pa_io13" LOC="A3";  # HexSwJ
NET "pa_io14" LOC="B4";  # HexSwAdrComp
NET "pa_io15" LOC="A4"; # SwE Inner
NET "pa_io15" PULLDOWN;
NET "pa_io16" LOC="B5"; # SwE Outer
NET "pa_io16" PULLDOWN;
# 20:
NET "pa_io17" LOC="A5"; # ROS Ctl INH_CF_STOP
NET "pa_io17" PULLDOWN;
NET "pa_io18" LOC="B6";  # ROS Ctl SCAN
NET "pa_io18" PULLDOWN;
NET "ma2_db0" LOC="B7";  # Rate INST_STEP
NET "ma2_db0" PULLDOWN;
NET "ma2_db1" LOC="A7";  # Rate SINGLE_CYCLE
NET "ma2_db1" PULLDOWN;
NET "ma2_db2" LOC="B8"; # Chk Ctk DIAGNOSTIC
NET "ma2_db2" PULLDOWN;
NET "ma2_db3" LOC="A8"; # Chk Ctl DISABLE
NET "ma2_db3" PULLDOWN;
NET "ma2_db4" LOC="A9"; # Chk Ctl STOP
NET "ma2_db4" PULLDOWN;
NET "ma2_db5" LOC="B10"; # Chk Ctl RESTART
NET "ma2_db5" PULLDOWN;
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

# SRAM
NET "sramaddr<17>" LOC="L3";
NET "sramaddr<16>" LOC="K5";
NET "sramaddr<15>" LOC="K3";
NET "sramaddr<14>" LOC="J3";
NET "sramaddr<13>" LOC="J4";
NET "sramaddr<12>" LOC="H4";
NET "sramaddr<11>" LOC="H3";
NET "sramaddr<10>" LOC="G5";
NET "sramaddr<9>" LOC="E4";
NET "sramaddr<8>" LOC="E3";
NET "sramaddr<7>" LOC="F4";
NET "sramaddr<6>" LOC="F3";
NET "sramaddr<5>" LOC="G4";
NET "sramaddr<4>" LOC="L4";
NET "sramaddr<3>" LOC="M3";
NET "sramaddr<2>" LOC="M4";
NET "sramaddr<1>" LOC="N3";
NET "sramaddr<0>" LOC="L5";
#NET "srama<15>" LOC="R1";
#NET "srama<15>" PULLDOWN;
#NET "srama<14>" LOC="P1";
#NET "srama<14>" PULLDOWN;
#NET "srama<13>" LOC="L2";
#NET "srama<13>" PULLDOWN;
#NET "srama<12>" LOC="J2";
#NET "srama<12>" PULLDOWN;
#NET "srama<11>" LOC="H1";
#NET "srama<11>" PULLDOWN;
#NET "srama<10>" LOC="F2";
#NET "srama<10>" PULLDOWN;
#NET "srama<9>" LOC="P8";
#NET "srama<9>" PULLDOWN;
NET "srama<8>" LOC="D3";
NET "srama<7>" LOC="B1";
NET "srama<6>" LOC="C1";
NET "srama<5>" LOC="C2";
NET "srama<4>" LOC="R5";
NET "srama<3>" LOC="T5";
NET "srama<2>" LOC="R6";
NET "srama<1>" LOC="T8";
NET "srama<0>" LOC="N7";
NET "sramace" LOC="P7";
NET "sramaub" LOC="T4";
NET "sramalb" LOC="P6";
# NET "sramb<15>" LOC="N1";
# NET "sramb<14>" LOC="M1";
# NET "sramb<13>" LOC="K2";
# NET "sramb<12>" LOC="C3";
# NET "sramb<11>" LOC="F5";
# NET "sramb<10>" LOC="G1";
# NET "sramb<09>" LOC="E2";
# NET "sramb<08>" LOC="D2";
# NET "sramb<07>" LOC="D1";
# NET "sramb<06>" LOC="E1";
# NET "sramb<05>" LOC="G2";
# NET "sramb<04>" LOC="J1";
# NET "sramb<03>" LOC="K1";
# NET "sramb<02>" LOC="M2";
# NET "sramb<01>" LOC="N2";
# NET "sramb<00>" LOC="P2";
# NET "srambce" LOC="N5";
# NET "srambub" LOC="R4";
# NET "sramblb" LOC="P5";
NET "sramwe" LOC="G3";
NET "sramoe" LOC="K4";

# For the other peripherals and ports listed here,
# consult the Xilinx documentation.
# RS-232 port
NET "serialRx" LOC="T13";
NET "serialTx" LOC="R13";

# expansion connectors
#
# B1
# 1 Gnd
# 2 VU (+5V)
# 3 Vcco (+3.3V)
NET "MAX7219_CLK" LOC="C10";  # B1- 4
NET "MAX7219_LOAD" LOC="T3";  # B1- 5
NET "MAX7219_DIN" LOC="E10"; # B1- 6
NET "MAX7318_SCL" LOC="N11"; # B1- 7
NET "MAX7318_SDA" LOC="C11"; # B1- 8
NET "MAX7318_SDA" PULLUP;
#NET "B1-09" LOC="P10"; # B1- 9
NET "MAX6951_CLK" LOC="D11";  # B1-10
NET "MAX6951_CS0" LOC="R10";  # B1-11
NET "MAX6951_CS1" LOC="C12";  # B1-12
NET "MAX6951_CS2" LOC="T7";   # B1-13
NET "MAX6951_CS3" LOC="D12";  # B1-14
NET "MAX6951_DIN" LOC="R7";   # B1-15
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
NET "din" LOC = "M11";
NET "reset_prom" LOC = "N9";
NET "rclk" LOC = "A14";
#NET "progb" LOC="B3";
#NET "fpgadone" LOC="R14";
#NET "fpgacclk" LOC="T15";

