set ns [new Simulator]

$ns color 1 Blue
$ns color 2 Red

set nf [open out2_0.nam w]
$ns namtrace-all $nf

proc finish {} {
 global ns nf
 $ns flush-trace
 close $nf
 exec nam out2_0.nam
 exit 0}

set s1 [$ns node]
set s2 [$ns node]
set r1 [$ns node]
set r2 [$ns node]

$ns duplex-link $s1 $r1 128kb 100ms DropTail
$ns duplex-link $s2 $r1 128kb 100ms DropTail
$ns duplex-link $r1 $r2 128kb 100ms DropTail

$ns duplex-link-op $s1 $r1 orient right-down
$ns duplex-link-op $s2 $r1 orient right-up
$ns duplex-link-op $r1 $r2 orient right

$ns queue-limit $r1 $r2 10
$ns duplex-link-op $r1 $r2 queuePos 0.5

set snk1 [new Agent/TCPSink]
$ns attach-agent $r2 $snk1

set snk2 [new Agent/TCPSink]
$ns attach-agent $r2 $snk2

set tcp1 [new Agent/TCP]
$tcp1 set maxcwnd_ 50
$tcp1 set packetSize_ 100
$ns attach-agent $s1 $tcp1
$ns connect $tcp1 $snk1
$tcp1 set fid_ 1
set ftp1 [$tcp1 attach-source FTP]

set tcp2 [new Agent/TCP]
$tcp2 set maxcwnd_ 50
$tcp2 set packetSize_ 100
$ns attach-agent $s2 $tcp2
$ns connect $tcp2 $snk2
$tcp2 set fid_ 2
set tln1 [$tcp2 attach-source Telnet]
$tln1 set interval_ 0.03s

$ns at 0.1 "$ftp1 produce 175"
$ns at 0.5 "$tln1 start"
$ns at 1.5 "$tln1 stop"
$ns at 6.0 "finish"
$ns run