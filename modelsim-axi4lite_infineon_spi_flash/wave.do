onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SCK
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SIIn
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SIOut
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SOIn
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SOut
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/CSNeg
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/HOLDNegIn
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/HOLDNegOut
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/WPNegIn
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/WPNegOut
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/WByte
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/WOTPByte
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/current_state
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/next_state
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/Instruct
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SOut_zd
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SIOut_zd
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/HOLDNegOut_zd
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/WPNegOut_zd
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SOut_z
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SIOut_z
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/PoweredUp
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/Status_reg_in
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/Sec_conf_reg_in
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/write
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/cfg_write
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/read_out
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/fast_rd
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/rd
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/dual
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/rd_jid
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/change_addr
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/change_BP
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/PDONE
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/PSTART
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/WDONE
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/WSTART
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/ESTART
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/EDONE
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/INITIAL_CONFIG
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SA
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/Byte_number
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/Address
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/Viol
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/TBPROT
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/BPNV
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/TBPARM
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/QUAD
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/FREEZE
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/SRWD
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/P_ERR
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/E_ERR
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/BP2
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/BP1
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/BP0
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/WEL
add wave -noupdate /tb_top_axi4lite/i_s25fl129p00/Behavior/WIP
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {324490521 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {6261228 ps}
