set ns [new Simulator]
set nf [open out.nam w]
$ns namtrace-all $nf

set f [open out0.tr w]

$ns color 1 Blue
$ns color 2 Red

#============================================================

#==================================================
#     Nodes
#==================================================
for {set index 1} {$index <= 3} {incr index} {
	set s($index) [$ns node]
}
for {set index 1} {$index <= 5} {incr index} {
	set r($index) [$ns node]
}
for {set index 1} {$index <= 3} {incr index} {
	set k($index) [$ns node]
}


#==================================================
#     Senders / Receivers
#==================================================
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
$ns connect $udp(2) $null(2)

#==================================================
#     Scheme
#==================================================
$ns duplex-link $s(1) $r(1) 128kb 20ms DropTail
$ns duplex-link $r(1) $s(2) 128kb 20ms DropTail
$ns duplex-link $r(1) $s(3) 1Mb 100ms DropTail
$ns duplex-link $r(1) $r(2) 128kb 20ms DropTail
$ns duplex-link $r(2) $r(3) 1Mb 100ms DropTail
$ns duplex-link $r(2) $r(4) 1Mb 100ms DropTail
$ns duplex-link $r(3) $k(1) 1Mb 100ms DropTail
$ns duplex-link $r(3) $r(5) 1Mb 100ms DropTail
$ns duplex-link $r(4) $r(5) 1Mb 100ms DropTail
$ns duplex-link $r(5) $k(2) 1Mb 100ms DropTail
$ns duplex-link $r(5) $k(3) 1Mb 100ms DropTail

$ns duplex-link-op $s(1) $r(1) orient down
$ns duplex-link-op $r(1) $s(2) orient left
$ns duplex-link-op $r(1) $s(3) orient down
$ns duplex-link-op $r(1) $r(2) orient right
$ns duplex-link-op $r(2) $r(3) orient right
$ns duplex-link-op $r(2) $r(4) orient right-down
$ns duplex-link-op $r(3) $k(1) orient right-up
$ns duplex-link-op $r(3) $r(5) orient right-down
$ns duplex-link-op $r(4) $r(5) orient right
$ns duplex-link-op $r(5) $k(2) orient right-up
$ns duplex-link-op $r(5) $k(3) orient right

#==================================================
#     Queue
#==================================================
$ns duplex-link-op $r(1) $r(2) queuePos 0.5
$ns queue-limit $r(1) $r(2) 30
set qm [$ns monitor-queue $r(1) $r(2) [$ns get-ns-traceall]]

#==================================================
#     Timings
#==================================================
$ns at 0.0 "trqueue"
$ns at 0.1 "$udp(1) start"
$ns at 0.1 "$udp(2) start"
$ns at 5.0 "$udp(1) stop"
$ns at 5.0 "$udp(2) stop"
$ns at 6.0 "finish"

#============================================================

proc trqueue {} {
	global qm f
	set ns [Simulator instance]
	set time 0.1
	set ql [$qm set pkts_]
	set now [$ns now]
	puts $f "$now $ql"
	$qm reset
	$ns at [expr $now+$time] "trqueue"
}

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
#	exec nam out.nam &
	exec xgraph out0.tr -geometry 800x600 &
	exit 0
}

$ns run