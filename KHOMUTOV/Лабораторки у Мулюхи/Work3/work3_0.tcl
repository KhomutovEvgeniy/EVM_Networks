set ns [new Simulator]
$ns color 1 Blue
set nf [open out3_0.nam w]
$ns namtrace-all $nf
proc finish {} {
 global ns nf
 $ns flush-trace
 close $nf
 exec nam out3_0.nam
 exit 0}
set s1 [$ns node]
set r1 [$ns node]
set r2 [$ns node]
$ns duplex-link $s1 $r2 256kb 150ms DropTail
$ns duplex-link $s1 $r1 256kb 150ms DropTail
$ns duplex-link $r1 $r2 256kb 150ms DropTail
$ns duplex-link-op $s1 $r2 orient right
$ns duplex-link-op $s1 $r1 orient right-up
$ns duplex-link-op $r1 $r2 orient right-down
$ns queue-limit $s1 $r2 10
set snk1 [new Agent/TCPSink]
$ns attach-agent $r2 $snk1
set tcp1 [new Agent/TCP]
$tcp1 set maxcwnd_ 50
$tcp1 set packetSize_ 200
$ns attach-agent $s1 $tcp1
$ns connect $tcp1 $snk1
$tcp1 set fid_ 1
set ftp1 [$tcp1 attach-source FTP]
$ns at 0.1 "$ftp1 produce 70"

$ns rtmodel-at 2.0 down $s1 $r2

$ns rtmodel-at 3.0 up $s1 $r2
$ns at 6.0 "finish"
$ns run