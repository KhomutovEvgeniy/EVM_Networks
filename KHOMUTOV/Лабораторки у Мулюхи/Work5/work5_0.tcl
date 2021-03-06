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

set s1 [$ns node]
set s2 [$ns node]
set r1 [$ns node]
set r2 [$ns node]

$ns duplex-link $s1 $r1 1Mb 50ms DropTail
$ns duplex-link $s2 $r1 1Mb 50ms DropTail
$ns duplex-link $r1 $r2 64kb 100ms DropTail

$ns duplex-link-op $s1 $r1 orient right-down
$ns duplex-link-op $s2 $r1 orient right-up
$ns duplex-link-op $r1 $r2 orient right

$ns queue-limit $r1 $r2 5
$ns duplex-link-op $r1 $r2 queuePos 0.5

exec rm -f out.tr
set fout [open out.tr w]
$ns trace-queue $r1 $r2 $fout
exec rm -f out2.tr
set fout2 [open out2.tr w]
$ns trace-queue $r2 $r1 $fout2

set snk1 [new Agent/TCPSink]
$ns attach-agent $r2 $snk1

set snk2 [new Agent/TCPSink]
$ns attach-agent $r2 $snk2

set tcp1 [new Agent/TCP]
$tcp1 set maxcwnd_ 12
$tcp1 set packetSize_ 100
$ns attach-agent $s1 $tcp1
$ns connect $tcp1 $snk1
$tcp1 set fid_ 1
set ftp1 [$tcp1 attach-source FTP]

set tcp2 [new Agent/TCP]
$tcp2 set maxcwnd_ 12
$tcp2 set packetSize_ 100
$ns attach-agent $s2 $tcp2
$ns connect $tcp2 $snk2
$tcp2 set fid_ 2
set tln1 [$tcp2 attach-source Telnet]
$tln1 set interval_ 0.02s

$ns at 0.1 "$ftp1 produce 200"
$ns at 0.5 "$tln1 start"

$ns at 1.5 "$tln1 stop"

$ns at 6.0 "ns flush-trace; \
 close $fout; close $fout2; \
 finish $label $mod"
$ns run