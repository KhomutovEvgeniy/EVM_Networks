set ns [new Simulator]

$ns color 1 Red
$ns color 2 Green

set nf [open out2_3.nam w]
$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out2_3.nam
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

$ns duplex-link $s1 $r1 128kb 10ms DropTail
$ns duplex-link $s2 $r1 128kb 10ms DropTail
$ns duplex-link $s3 $r1 128kb 10ms DropTail
$ns duplex-link $r1 $r2 128kb 10ms DropTail
$ns duplex-link $r1 $r4 128kb 10ms DropTail
$ns duplex-link $r2 $r3 128kb 10ms DropTail
$ns duplex-link $r3 $k1 128kb 10ms DropTail
$ns duplex-link $r4 $r5 128kb 10ms DropTail
$ns duplex-link $r3 $r5 128kb 10ms DropTail
$ns duplex-link $r5 $k2 128kb 10ms DropTail
$ns duplex-link $r5 $k3 128kb 10ms DropTail

$ns duplex-link-op $r1 $s1 orient left-up
$ns duplex-link-op $r1 $s2 orient left
$ns duplex-link-op $r1 $s3 orient left-down
$ns duplex-link-op $r1 $r2 orient right-up
$ns duplex-link-op $r1 $r4 orient right-down
$ns duplex-link-op $r2 $r3 orient right
$ns duplex-link-op $r3 $k1 orient right
$ns duplex-link-op $r4 $r5 orient right
$ns duplex-link-op $r3 $r5 orient down
$ns duplex-link-op $r5 $k2 orient right
$ns duplex-link-op $r5 $k3 orient down

$ns queue-limit $r1 $r2 10
$ns duplex-link-op $r1 $r2 queuePos 0.5

set snk1 [new Agent/TCPSink]
$ns attach-agent $k1 $snk1

set tcp1 [new Agent/TCP]
$tcp1 set maxcwnd_ 50
$tcp1 set packetSize_ 100
$ns attach-agent $s1 $tcp1
$ns connect $tcp1 $snk1
$tcp1 set fid_ 1
set ftp1 [$tcp1 attach-source FTP]

set tfile [new Tracefile]
$tfile filename trace.dat
set src1 [new Agent/CBR/UDP]
$ns attach-agent $s2 $src1

set null1 [new Agent/Null]
$ns attach-agent $k2 $null1

$ns connect $src1 $null1
set trace [new Traffic/Trace]
$trace attach-tracefile $tfile

$src1 attach-traffic $trace

$src1 set fid_ 2

$ns at 0.1 "$ftp1 produce 100"
$ns at 0.1 "$src1 start"
$ns at 3.0 "$src1 stop"

$ns at 8.0 "finish"

$ns run

