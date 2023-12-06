onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_top_avalon/simdone
add wave -noupdate /tb_top_avalon/Clk
add wave -noupdate /tb_top_avalon/Rst
add wave -noupdate /tb_top_avalon/TimeoutAck_Detected
add wave -noupdate /tb_top_avalon/TimeoutAck_Rec_Clear
add wave -noupdate -color Magenta -itemcolor Magenta /tb_top_avalon/executing_line
add wave -noupdate -color Magenta -itemcolor Magenta /tb_top_avalon/executing_file
add wave -noupdate -color Magenta -itemcolor Magenta /tb_top_avalon/marker
add wave -noupdate /tb_top_avalon/signals_in
add wave -noupdate /tb_top_avalon/signals_out
add wave -noupdate /tb_top_avalon/bus_down
add wave -noupdate /tb_top_avalon/bus_up
add wave -noupdate -childformat {{/tb_top_avalon/SpiControllerIfcAvalonDown.Address -radix hexadecimal} {/tb_top_avalon/SpiControllerIfcAvalonDown.ByteEnable -radix hexadecimal} {/tb_top_avalon/SpiControllerIfcAvalonDown.WriteData -radix hexadecimal}} -expand -subitemconfig {/tb_top_avalon/SpiControllerIfcAvalonDown.Address {-height 26 -radix hexadecimal} /tb_top_avalon/SpiControllerIfcAvalonDown.ByteEnable {-height 26 -radix hexadecimal} /tb_top_avalon/SpiControllerIfcAvalonDown.WriteData {-height 26 -radix hexadecimal}} /tb_top_avalon/SpiControllerIfcAvalonDown
add wave -noupdate -childformat {{/tb_top_avalon/SpiControllerIfcAvalonUp.ReadData -radix hexadecimal}} -expand -subitemconfig {/tb_top_avalon/SpiControllerIfcAvalonUp.ReadData {-height 26 -radix hexadecimal}} /tb_top_avalon/SpiControllerIfcAvalonUp
add wave -noupdate /tb_top_avalon/SpiControllerIfcTrace
add wave -noupdate /tb_top_avalon/SClk
add wave -noupdate /tb_top_avalon/MiSo
add wave -noupdate /tb_top_avalon/MoSi
add wave -noupdate /tb_top_avalon/nCs
add wave -noupdate /tb_top_avalon/WPn
add wave -noupdate /tb_top_avalon/HOLDn
add wave -noupdate /tb_top_avalon/tb_FileIo_i/clk
add wave -noupdate /tb_top_avalon/tb_FileIo_i/rst
add wave -noupdate /tb_top_avalon/tb_FileIo_i/simdone
add wave -noupdate /tb_top_avalon/tb_FileIo_i/executing_line
add wave -noupdate /tb_top_avalon/tb_FileIo_i/executing_file
add wave -noupdate /tb_top_avalon/tb_FileIo_i/marker
add wave -noupdate /tb_top_avalon/tb_FileIo_i/signals_out
add wave -noupdate /tb_top_avalon/tb_FileIo_i/signals_in
add wave -noupdate /tb_top_avalon/tb_FileIo_i/bus_down
add wave -noupdate /tb_top_avalon/tb_FileIo_i/bus_up
add wave -noupdate /tb_top_avalon/tb_FileIo_i/rstneg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/Clk
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/Rst
add wave -noupdate -childformat {{/tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcAvalonDown.Address -radix hexadecimal} {/tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcAvalonDown.ByteEnable -radix hexadecimal} {/tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcAvalonDown.WriteData -radix hexadecimal}} -expand -subitemconfig {/tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcAvalonDown.Address {-height 26 -radix hexadecimal} /tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcAvalonDown.ByteEnable {-height 26 -radix hexadecimal} /tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcAvalonDown.WriteData {-height 26 -radix hexadecimal}} /tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcAvalonDown
add wave -noupdate -childformat {{/tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcAvalonUp.ReadData -radix hexadecimal}} -expand -subitemconfig {/tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcAvalonUp.ReadData {-height 26 -radix hexadecimal}} /tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcAvalonUp
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerIfcTrace
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/SClk
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/MiSo
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/MoSi
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/nCs
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerBlkDown
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/SpiControllerBlkUp
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/SelectedBufferNumberOwnedBySw
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/SwBufferWriteEnable
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/HwBufferWriteEnable
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/HwBufferAddress
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/HwBufferWriteData
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/HwBufferReadData
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/DoTransceivePulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/ReleaseTxDataPulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/StoreRxDataPulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/TxByte
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/RxByte
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/CPol
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/CPha
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/SClkPeriodInNs
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/WaitRequestSwBuffer
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/Clk
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/Rst
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/AvalonDown
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/AvalonUp
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/Trace
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/SpiControllerBlkDown
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/SpiControllerBlkUp
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/BlockMatch
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/UnoccupiedAck
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/TimeoutAck
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/PreAvalonUp
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/SpiControllerBlkReadData
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/SpiControllerBlkWaitRequest
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/SpiControllerBlkMatch
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/Clk
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/Rst
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/Read
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/Write
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/Match
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/UnoccupiedAck
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/TimeoutAck
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/BusAccessDelay
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/BusAccess
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/PreUnoccupiedAck
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/PreTimeoutAck
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerIfcBusMonitor/TimeoutCounter
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/Clk
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/Rst
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/Address
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/ByteEnable
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/Read
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/ReadData
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/Write
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/WriteData
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/WaitRequest
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/Match
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/Activation
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/SwBuffer
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/WTransPulseControlReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/Operation
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/HwBuffer
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/CellBufferAddress
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/CellBufferByteEnable
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/CellBufferRead
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/CellBufferReadData
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/CellBufferWrite
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/CellBufferWriteData
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/CellBufferWaitRequest
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreReadData
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreReadDataControlReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreReadAckControlReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreWriteAckControlReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreMatchReadControlReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreMatchWriteControlReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/WriteDiffControlReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/ReadDiffControlReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/WRegActivation
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreReadDataStatusReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreReadAckStatusReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreWriteAckStatusReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreMatchReadStatusReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreMatchWriteStatusReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/WriteDiffStatusReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/ReadDiffStatusReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreReadDataCellBuffer
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreAckCellBuffer
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreMatchReadCellBuffer
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_SpiControllerIfcAvalon/i_SpiControllerBlk_SpiControllerIfc/PreMatchWriteCellBuffer
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/Clk
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/Rst
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/SClk
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/MiSo
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/MoSi
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/DoTransceivePulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/ReleaseTxDataPulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/StoreRxDataPulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/TxByte
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/RxByte
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/CPol
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/CPha
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/SClkPeriodInNs
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/TranceiveCount
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/StretchCount
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/TxShiftReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_Phy/RxShiftReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/Clk
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/Rst
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/Activation
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/SwBufferPrepared
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/WTransPulseControlReg
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/Operation
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/HwBufferAvailable
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/SelectedBufferNumberOwnedBySw
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/HwBufferAddress
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/HwBufferWriteEnable
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/HwBufferWriteData
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/HwBufferReadData
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/CPol
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/CPha
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/SClkPeriodInNs
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/DoTransceivePulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/ReleaseTxDataPulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/StoreRxDataPulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/TxByte
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/RxByte
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/nCs
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/State
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/CmdId
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/ReadHwBufferAddressPointer
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/ReadHwBufferRepeatAddressPointer
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/WriteHwBufferAddressPointer
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/ReceiveFrameStartAddress
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/PacketMultiplier
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/PacketLength
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/PacketCount
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/ByteCount
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/ReceiveByteCount
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/StoreReceiveByte
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/ResetReceiveByteCount
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/WaitNs
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/StartTimerPulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/TimerCount
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/TimerExpired
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/CmdGotoAddressToGoto
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/ForLoopCount
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/LoopCount
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/CmdEndAddressToGoto
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/AutoRestart
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/SwBuffersPending
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/HwBufferProcessedPulse
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_CmdProcessor/Tranceive
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/Clk
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/Rst
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/SelectedBufferNumberOwnedBySw
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/HwBufferWriteEnable
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/HwBufferAddress
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/HwBufferWriteData
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/HwBufferReadData
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/SwBufferWriteEnable
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/SwBufferAddress
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/SwBufferWriteData
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/SwBufferReadData
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/BufferWriteEnable0
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/BufferAddress0
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/BufferWriteData0
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/BufferReadData0
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/BufferWriteEnable1
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/BufferAddress1
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/BufferWriteData1
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/BufferReadData1
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i0_Ram/Clk
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i0_Ram/WriteEnable
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i0_Ram/Address
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i0_Ram/WriteData
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i0_Ram/ReadData
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i0_Ram/ReadAddress
add wave -noupdate /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i1_Ram/Clk
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i1_Ram/WriteEnable
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i1_Ram/Address
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i1_Ram/WriteData
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i1_Ram/ReadData
add wave -noupdate -radix hexadecimal /tb_top_avalon/i_SpiControllerWithAvalonBus/i_DoubleBuffer/i1_Ram/ReadAddress
add wave -noupdate /tb_top_avalon/i_W25Q128JVxIM/CSn
add wave -noupdate /tb_top_avalon/i_W25Q128JVxIM/CLK
add wave -noupdate /tb_top_avalon/i_W25Q128JVxIM/DIO
add wave -noupdate /tb_top_avalon/i_W25Q128JVxIM/WPn
add wave -noupdate /tb_top_avalon/i_W25Q128JVxIM/HOLDn
add wave -noupdate /tb_top_avalon/i_W25Q128JVxIM/DO
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {8085216 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 1091
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
WaveRestoreZoom {8012928 ps} {8400640 ps}
