set ns [new Simulator]

proc finish { file mod } {
exec rm -f temp.rands
set f [open temp.rands w]
puts $f "TitleText: $file"
puts $f "Device: Postscript"

exec rm -f temp.p
exec touch temp.p

exec awk {
{
if (($1 == "+" || $1 == "-" ) && \
 ($5 == "tcp" || $5 == "ack"))\
print $2, ($8-1)*(mod+10) + ($11 % mod)
}
} mod=$mod out.tr > temp.p

exec rm -f temp.d
exec touch temp.d

exec awk {
	{
if ($1 == "d")
		print $2, ($8-1)*(mod+10) + ($11 % mod) 
	}
} mod=$mod out.tr > temp.d

exec rm -f temp.p2
exec touch temp.p2
exec awk {
 {
 	if (($1 == "-" ) && \
 		($5 == "tcp" || $5 == "ack"))\
 				print $2, ($8-1)*(mod+10) + ($11 % mod)
 }
 } mod=$mod out2.tr > temp.p2

puts $f \"packets
#flush $f
exec cat temp.p >@ $f
#flush $f
puts $f \n\"acks
#flush $f
exec cat temp.p2 >@ $f

puts $f [format "\n\"skip-1\n0 1\n\n"]

puts $f \"drops
#flush $f
#exec head -1 temp.d >@ $f
exec cat temp.d >@ $f
close $f
set tx "time (sec)"
set ty "packet number (mod $mod)"

exec xgraph -bb -tk -nl -m -zg 0 -x $tx -y $ty temp.rands &
exit 0
}

set label "tcp/ftp+telnet"
set mod 80

$ns color 1 Blue
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

$ns duplex-link $s(1) $r(1) 2Mb 10ms DropTail
$ns duplex-link $s(2) $r(1) 2Mb 10ms DropTail
$ns duplex-link $s(3) $r(1) 2Mb 10ms DropTail
$ns duplex-link $r(1) $r(2) 256Kb 200ms DropTail
$ns duplex-link $r(1) $r(4) 2Mb 10ms DropTail
$ns duplex-link $r(2) $r(3) 2Mb 10ms DropTail
$ns duplex-link $r(3) $k(1) 2Mb 10ms DropTail
$ns duplex-link $r(4) $r(5) 2Mb 10ms DropTail
$ns duplex-link $r(3) $r(5) 2Mb 10ms DropTail
$ns duplex-link $r(5) $k(3) 2Mb 10ms DropTail
$ns duplex-link $r(5) $k(2) 2Mb 10ms DropTail

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

$ns queue-limit $r(1) $r(2) 6
$ns duplex-link-op $r(1) $r(2) queuePos 0.5

exec rm -f out.tr
set fout [open out.tr w]
$ns trace-queue $r(1) $r(2) $fout
exec rm -f out2.tr
set fout2 [open out2.tr w]
$ns trace-queue $r(2) $r(1) $fout2

set snk1 [new Agent/TCPSink]
$ns attach-agent $k(1) $snk1

set tcp1 [new Agent/TCP]
$tcp1 set maxcwnd_ 15
$tcp1 set packetSize_ 100
$ns attach-agent $s(1) $tcp1
$ns connect $tcp1 $snk1
$tcp1 set fid_ 1
set ftp1 [$tcp1 attach-source FTP]

$ns at 0.1 "$ftp1 produce 200"

$ns at 6.0 "ns flush-trace; \
 close $fout; close $fout2; \
 finish $label $mod"
$ns run