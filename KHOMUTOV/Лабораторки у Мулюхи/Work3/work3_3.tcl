set ns [new Simulator]

$ns rtproto Session

set nf [open out3_3.nam w]
$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out3_3.nam
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

$ns duplex-link $s1 $r1 256kb 20ms DropTail
$ns duplex-link-op $r1 $s1 orient left-up

$ns duplex-link $s2 $r1 256kb 20ms DropTail
$ns duplex-link-op $r1 $s2 orient left

$ns duplex-link $s3 $r1 256kb 20ms DropTail
$ns duplex-link-op $r1 $s3 orient left-down

$ns duplex-link $r1 $r2 256kb 20ms DropTail
$ns duplex-link-op $r1 $r2 orient right-up
$ns cost $r1 $r2 5
$ns cost $r2 $r1 5

$ns duplex-link $r1 $r4 256kb 20ms DropTail
$ns duplex-link-op $r1 $r4 orient right-down

$ns duplex-link $r2 $r3 256kb 20ms DropTail
$ns duplex-link-op $r2 $r3 orient right

$ns duplex-link $r3 $k1 256kb 20ms DropTail
$ns duplex-link-op $r3 $k1 orient right

$ns duplex-link $r4 $r5 256kb 20ms DropTail
$ns duplex-link-op $r4 $r5 orient right

$ns duplex-link $r3 $r5 256kb 20ms DropTail
$ns duplex-link-op $r3 $r5 orient down

$ns duplex-link $r5 $k2 256kb 20ms DropTail
$ns duplex-link-op $r5 $k2 orient right

$ns duplex-link $r5 $k3 256kb 20ms DropTail
$ns duplex-link-op $r5 $k3 orient down

set snk1 [new Agent/TCPSink]
$ns attach-agent $k1 $snk1

set tcp1 [new Agent/TCP]
$tcp1 set maxcwnd_ 50
$tcp1 set packetSize_ 300
$ns attach-agent $s1 $tcp1
$ns connect $tcp1 $snk1
$tcp1 set fid_ 1
set ftp1 [$tcp1 attach-source FTP]

$ns at 0.5 "$ftp1 produce 300"

$ns rtmodel-at 2.0 down $r1 $r2

$ns rtmodel-at 3.0 up $r1 $r2

$ns at 6.0 "finish"

$ns run

