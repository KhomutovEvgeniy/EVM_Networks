set ns [new Simulator]
set nf [open out.nam w]
$ns namtrace-all $nf

set f(0) [open out0.tr w]
set f(1) [open out1.tr w]
set f(2) [open out2.tr w]

$ns color 1 Green
$ns color 2 Red

for {set index 1} {$index <= 3} {incr index} {
	set s($index) [$ns node]
}
for {set index 1} {$index <= 5} {incr index} {
	set r($index) [$ns node]
}
for {set index 1} {$index <= 3} {incr index} {
	set k($index) [$ns node]
}
#set s1 [$ns node]
#set s2 [$ns node]
#set s3 [$ns node]
#set r1 [$ns node]
#set r2 [$ns node]
#set r3 [$ns node]
#set r4 [$ns node]
#set r5 [$ns node]
#set k1 [$ns node]
#set k2 [$ns node]
#set k3 [$ns node]

set udp(1) [new Agent/CBR/UDP]
$ns attach-agent $s(1) $udp(1)
$udp(1) set fid_ 1
set traffic [new Traffic/Expoo]
$traffic set packet-size 300
$traffic set burst-time 0.1s
$traffic set idle-time 0.1s
$traffic set rate 150k
$udp(1) attach-traffic $traffic
set null(1) [new Agent/Null]
$ns attach-agent $k(1) $null(1)
$ns connect $udp(1) $null(1)

set udp(2) [new Agent/CBR/UDP]
$ns attach-agent $s(2) $udp(2)
$udp(2) set fid_ 2
set traffic [new Traffic/Expoo]
$traffic set packet-size 300
$traffic set burst-time 0.1s
$traffic set idle-time 0.1s
$traffic set rate 250k
$udp(2) attach-traffic $traffic
set null(2) [new Agent/Null]
$ns attach-agent $k(2) $null(2)
$ns connect $udp(2) $null(1)

$ns duplex-link $s(1) $r(1) 128Kb 20ms DropTail
$ns duplex-link $s(2) $r(1) 128Kb 20ms DropTail
$ns duplex-link $s(3) $r(1) 1Mb 100ms DropTail
$ns duplex-link $r(1) $r(2) 128Kb 20ms DropTail
$ns duplex-link $r(1) $r(4) 1Mb 100ms DropTail
$ns duplex-link $r(2) $r(3) 1Mb 100ms DropTail
$ns duplex-link $r(3) $k(1) 1Mb 100ms DropTail
$ns duplex-link $r(4) $r(5) 1Mb 100ms DropTail
$ns duplex-link $r(3) $r(5) 1Mb 100ms DropTail
$ns duplex-link $r(5) $k(3) 1Mb 100ms DropTail
$ns duplex-link $r(5) $k(2) 1Mb 100ms DropTail

$ns duplex-link-op $r(1) $s(1) orient left-up
$ns duplex-link-op $r(1) $s(2) orient left
$ns duplex-link-op $r(1) $r(2) orient right-up
$ns duplex-link-op $r(1) $s(3) orient left-down
$ns duplex-link-op $r(1) $r(4) orient right-down
$ns duplex-link-op $r(2) $r(3) orient right
$ns duplex-link-op $r(3) $k(1) orient right
$ns duplex-link-op $r(4) $r(5) orient right
$ns duplex-link-op $r(3) $r(5) orient down
$ns duplex-link-op $r(5) $k(2) orient right
$ns duplex-link-op $r(5) $k(3) orient down

$ns duplex-link-op $r(1) $r(2) queuePos 0.5
$ns queue-limit $r(1) $r(2) 30
set qm [$ns monitor-queue $r(1) $r(2) [$ns get-ns-traceall]]

proc trqueue {} {
	global qm f
	set ns [Simulator instance]
	set time 0.1
	set q(0) [$qm set pkts_]
	set q(1) [$qm set parrivals_]
	set q(2) [$qm set pdrops_]
	set now [$ns now]
	puts $f(0) "$now $q(0)"
puts $f(1) "$now $q(1)"
puts $f(2) "$now $q(2)"
	$qm reset
	$ns at [expr $now+$time] "trqueue"
}

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
set tt "Work4-2"
set tx "time(sec)"
set ty "quantityPackets"
	exec xgraph -geometry 800x600 -t $tt -x $tx -y $ty 	out0.tr out1.tr out2.tr &
	exit 0
}

$ns at 0.0 "trqueue"
$ns at 0.1 "$udp(1) start"
$ns at 0.1 "$udp(2) start"
$ns at 5.0 "$udp(1) stop"
$ns at 5.0 "$udp(2) stop"
$ns at 6.0 "finish"
$ns run
