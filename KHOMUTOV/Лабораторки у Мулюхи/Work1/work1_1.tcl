set ns [new Simulator]

set nf [open out1_1.nam w]
$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out1_1.nam
	exit 0
}

set s1 [$ns node]
set s2 [$ns node]
set s3 [$ns node]
set r1 [$ns node]
set r2 [$ns node]
set r3 [$ns node]
set r4 [$ns node]
set r5 [$ns node]
set k1 [$ns node]
set k2 [$ns node]
set k3 [$ns node]

$ns duplex-link $s1 $r1 2Mb 5ms DropTail
$ns duplex-link-op $r1 $s1 orient left-up

$ns duplex-link $s2 $r1 2Mb 5ms DropTail
$ns duplex-link-op $r1 $s2 orient left

$ns duplex-link $s3 $r1 2Mb 5ms DropTail
$ns duplex-link-op $r1 $s3 orient left-down

$ns duplex-link $r1 $r2 1Mb 5ms DropTail
$ns duplex-link-op $r1 $r2 orient right-up

$ns duplex-link $r1 $r4 2Mb 5ms DropTail
$ns duplex-link-op $r1 $r4 orient right-down

$ns duplex-link $r2 $r3 2Mb 5ms DropTail
$ns duplex-link-op $r2 $r3 orient right

$ns duplex-link $r3 $k1 2Mb 5ms DropTail
$ns duplex-link-op $r3 $k1 orient right

$ns duplex-link $r4 $r5 2Mb 5ms DropTail
$ns duplex-link-op $r4 $r5 orient right

$ns duplex-link $r3 $r5 2Mb 5ms DropTail
$ns duplex-link-op $r3 $r5 orient down

$ns duplex-link $r5 $k2 2Mb 5ms DropTail
$ns duplex-link-op $r5 $k2 orient right

$ns duplex-link $r5 $k3 2Mb 5ms DropTail
$ns duplex-link-op $r5 $k3 orient down

set cbr1 [new Agent/CBR]
$ns attach-agent $s1 $cbr1
$cbr1 set packetSize_ 300
$cbr1 set interval_ 0.005

set null1 [new Agent/Null]
$ns attach-agent $k1 $null1

$ns connect $cbr1 $null1

$ns at 0.1 "$cbr1 start"
$ns at 5 "$cbr1 stop"

$ns at 8.0 "finish"

$ns run

