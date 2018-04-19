# Creating a new object of class Simulator
set ns [new Simulator]

# Opening a registration file for write and assigning it a 
# control variable nf
set nf [open out1_0.nam w]
# It indicates the simulator to record all the data on the 
# dynamics of the model in this file
$ns namtrace-all $nf

# Procedure 'finish', which closes the trace file and runs the  # utility nam
proc finish {} {
	global ns nf
# Transfers the data from the buffers to the appropriate trace # file
	$ns flush-trace
	close $nf
	exec nam out1_0.nam
	exit 0
}

set s1 [$ns node]
set r1 [$ns node]

# Creating a new bidirectional communication channel between 
# nodes s1 and r1. DropTail~FIFO - First-In-First-Out
$ns duplex-link $s1 $r1 2Mb 5ms DropTail

# Agent/CBR - constans bit rate - sender
set cbr1 [new Agent/CBR]
#attach-agent - The method that assigns the agent to the node
$ns attach-agent $s1 $cbr1
$cbr1 set packetSize_ 200
$cbr1 set interval_ 0.005

# Creation of the simplest agent-receiver and its attachment
# to the node r1
set null1 [new Agent/Null]
$ns attach-agent $r1 $null1

# Connect the source and destination of the traffic
$ns connect $cbr1 $null1

$ns at 0.5 "$cbr1 start"
$ns at 4.5 "$cbr1 stop"

$ns at 5.0 "finish"

# Run Simulator
$ns run

