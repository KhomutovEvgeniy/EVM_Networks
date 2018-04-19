proc finish {label mod} {
	exec rm -f temp.rands
	set f [open temp.rands w]
	puts $f "TitleText: $label"
	puts $f "Device: Postscript"

	exec rm -f temp.p
	exec touch temp.p
	exec awk {
	{
		if (($1 == "+" || $1 == "-") && ($5 == "exp")) \
			print $2, ($8-1) * (mod + 10) + ($11 % mod)
		}
	} mod=$mod out0.tr > temp.p

	exec rm -f temp.d
	exec touch temp.d
	exec awk {
	{
		if ($1 == "d") \
			print $2, ($8-1) * (mod + 10) + ($11 % mod)
		}
	} mod=$mod out0.tr > temp.d

	puts $f \"enque/deque
	exec cat temp.p >@ $f
	puts $f \n\"drops
	exec cat temp.d >@ $f
	close $f

	set tx "time (sec)"
	set ty "packet number (mod $mod)"

	exec xgraph -geometry 800x600 -bb -tk -nl -m -zg 0 \
-x $tx -y $ty temp.rands &
	exit 0
}

proc attach-expoo-traffic { node sink size burst idle rate } {
	set ns [Simulator instance]
	set source [new Agent/CBR/UDP]
	$ns attach-agent $node $source
	set traffic [new Traffic/Expoo]
	$traffic set packet-size $size
	$traffic set burst-time $burst
	$traffic set idle-time $idle
	$traffic set rate $rate
	$source attach-traffic $traffic
	$ns connect $source $sink
	return $source
}

set ns [new Simulator]
set label "Expoo_Traffic"
set mod 50

exec rm -f out0.tr
set fout [open out0.tr w]

$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green

for {set index 1} {$index <= 3} {incr index} {
	set s($index) [$ns node]
}
for {set index 1} {$index <= 5} {incr index} {
	set r($index) [$ns node]
}
for {set index 1} {$index <= 3} {incr index} {
	set k($index) [$ns node]
}

set sink(1) [new Agent/Null]
set sink(2) [new Agent/Null]
set sink(3) [new Agent/Null]

$ns attach-agent $k(1) $sink(1)
$ns attach-agent $k(1) $sink(2)
$ns attach-agent $k(1) $sink(3)


set source(1) [attach-expoo-traffic $s(1) $sink(1) 500 0.1s 0.1s 150k]
set source(2) [attach-expoo-traffic $s(2) $sink(1) 500 0.1s 0.1s 250k]
set source(3) [attach-expoo-traffic $s(3) $sink(1) 1000 0.1s 0.1s 100k]

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

$ns queue-limit $r(1) $r(2) 15
$ns trace-queue $r(1) $r(2) $fout

$source(1) set fid_ 3
$source(2) set fid_ 1
$source(3) set fid_ 5

$ns at 0.1 "$source(1) start"
$ns at 0.1 "$source(2) start"
$ns at 0.1 "$source(3) start"
$ns at 2.5 "$source(1) stop"
$ns at 2.5 "$source(2) stop"
$ns at 2.5 "$source(3) stop"

$ns at 3.0 "ns flush-trace; close $fout; finish $label $mod"

$ns run