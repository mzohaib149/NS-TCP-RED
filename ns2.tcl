#!/usr/local/bin/tclsh

set ns [new Simulator]
set nf [open out.nam w]
$ns trace-all $nf
$ns namtrace-all $nf
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green
set prev1 0
set prev2 0
set prev3 0
proc finish {} {
	global ns nf filename f1 f2 f3 f4 f5 f6 name1 name2 name3 name4 name5 name6 scenario_no queue_mechanism
	$ns flush-trace 
	close $nf
	close $filename
	close $f1
	close $f2
	close $f4
	close $f5
	if {$scenario_no == 2} {
		close $f3
		close $f6
	}
	if {$scenario_no == 1} {
		exec xgraph $name1 $name2 &
		exec xgraph $name4 $name5 &
	} elseif {$scenario_no == 2} {
		exec xgraph $name1 $name2 $name3 &
		exec xgraph $name4 $name5 $name6 &
	}
	exec nam out.nam &
	
	exit 0
}

proc record {} {
	global tcpsink1 tcpsink2 udpsink1 ns filename f1 f2 f3 f4 f5 f6 initial_bytes1 initial_bytes2 initial_bytes3 prev1 prev2 prev3 scenario_no
	set time 1
	set bytes1 [$tcpsink1 set bytes_]
	set bytes2 [$tcpsink2 set bytes_]
	if { $scenario_no == 2 } {
           set bytes3 [$udpsink1 set bytes_]
	}
	set now [$ns now]
	if {$now == 30} {
 		set initial_bytes1 [expr $bytes1]
		
		set prev1 [expr $bytes1]
		set initial_bytes2 [expr $bytes2]
		set prev2 [expr $bytes2]
		if {$scenario_no == 2} {
			set initial_bytes3 [expr $bytes3]
			set prev3 [expr $bytes3]
		}
	} 
	if {$now == 180} {
		set final_bytes1 [expr $bytes1]
		set final_bytes2 [expr $bytes2]
		if {$scenario_no == 2} {
			set final_bytes3 [expr $bytes3]
		}
		set diff1 [expr ($final_bytes1-$initial_bytes1)] 
		set diff2 [expr ($final_bytes2-$initial_bytes2)]
		if {$scenario_no == 2} {
			set diff3 [expr ($final_bytes3-$initial_bytes3)]
		}
		set bw1 [expr {double($diff1)/double(1000)/double(150)*double(8)}]
		set bw2 [expr {double($diff2)/double(1000)/double(150)*double(8)}]
		if {$scenario_no == 2} {
			set bw3 [expr {double($diff3)/double(1000)/double(150)*double(8)}]
		}
		
		puts $filename "Time for calculation: [expr $time] sec"
		puts $filename "Now: [expr $now]"
		puts $filename "Number of bytes received at sink1: [expr $diff1]"
		puts $filename "Throughput at sink1: [expr $bw1] kbps"
		puts $filename "Number of bytes received at sink2: [expr $diff2]"
		
		puts $filename "Throughput at sink2: [expr $bw2] kbps"	
		puts "Throughput at sink1: [expr $bw1] kbps"
		puts "Throughput at sink2: [expr $bw2] kbps"	
		if {$scenario_no == 2} {
			puts $filename "Number of bytes received at sink3: [expr $diff3]"
			puts $filename "Throughput at sink3: [expr $bw3] kbps"	
			puts "Throughput at sink3: [expr $bw3] kbps"
		}
	}
	
	if {$now > 30} {

		puts $f1 "$now [expr {double(($bytes1-$initial_bytes1))*double(8)/double((1000*($now-30)))}]"
		puts $f2 "$now [expr {double(($bytes2-$initial_bytes2))*double(8)/double((1000*($now-30)))}]"	
		if {$scenario_no == 2} {
			puts $f3 "$now [expr {double(($bytes3-$initial_bytes3))*double(8)/double((1000*($now-30)))}]"
		}
		puts $f4 "$now [expr {double(($bytes1-$prev1))/double(1000)/double(1)*double(8)}]"
		set prev1 $bytes1
		puts $f5 "$now [expr {double(($bytes2-$prev2))/double(1000)/double(1)*double(8)}]"
		set prev2 $bytes2
		if {$scenario_no == 2} {
			
			puts $f6 "$now [expr {double(($bytes3-$prev3))/double(1000)/double(1)*double(8)}]"
			set prev3 $bytes3
		}  
			
	}	
	$ns at [expr $now+$time] "record"
}



set queue_mechanism [lindex $argv 0]
set scenario_no [lindex $argv 1]

set H1 [$ns node]
set H2 [$ns node]
set R1 [$ns node]
set R2 [$ns node]
set H3 [$ns node]
set H4 [$ns node]

if {$scenario_no == 2} {
	set H5 [$ns node]
	set H6 [$ns node]
}

$H1 color blue
$H2 color red
$R1 shape box
$R1 color black
$R2 shape box
$R2 color black
$H3 color blue
$H4 color red

if { $scenario_no == 2 } {
	$H5 color green
	$H6 color green

}


set str1 "output"
set str2 "_"
set average_str1 "average_sink1.tr"
set average_str2 "average_sink2.tr"
set average_str3 "average_sink3.tr"
set instantaneous_str1 "instantaneous_sink1.tr"
set instantaneous_str2 "instantaneous_sink2.tr"
set instantaneous_str3 "instantaneous_sink3.tr"

set name $str1$str2$queue_mechanism$str2$scenario_no
set filename [open $name w]
set name1 $queue_mechanism$str2$scenario_no$str2$average_str1
set name2 $queue_mechanism$str2$scenario_no$str2$average_str2
set name3 $queue_mechanism$str2$scenario_no$str2$average_str3
set name4 $queue_mechanism$str2$scenario_no$str2$instantaneous_str1
set name5 $queue_mechanism$str2$scenario_no$str2$instantaneous_str2
set name6 $queue_mechanism$str2$scenario_no$str2$instantaneous_str3
set f1 [open $name1 w]
set f2 [open $name2 w]
if { $scenario_no == 2 } {
	set f3 [open $name3 w]
}
set f4 [open $name4 w]
set f5 [open $name5 w]
if { $scenario_no == 2 } {
	set f6 [open $name6 w]
}	

if { $scenario_no == 1 } {
   $ns duplex-link $H1 $R1 10Mb 1ms DropTail
   $ns duplex-link $H2 $R1 10Mb 1ms DropTail
   if { $queue_mechanism == "DROPTAIL" } {
      $ns duplex-link $R1 $R2 1Mb 10ms DropTail	
      $ns queue-limit $R1 $R2 20
   } elseif { $queue_mechanism == "RED" } {
      
      Queue/RED thres_ 10
      Queue/RED maxthres_ 15
      Queue/RED linterm_ 50	
      $ns duplex-link $R1 $R2 1Mb 10ms RED
      $ns queue-limit $R1 $R2 20
      
   }
   $ns duplex-link $R2 $H3 10Mb 1ms DropTail
   $ns duplex-link $R2 $H4 10Mb 1ms DropTail

   $ns duplex-link-op $H1 $R1 orient right-down
   $ns duplex-link-op $H2 $R1 orient right-up
   $ns duplex-link-op $R1 $R2 orient right
   $ns duplex-link-op $R2 $H3 orient right-up
   $ns duplex-link-op $R2 $H4 orient right-down	
	
   $ns duplex-link-op $H1 $R1 color blue
   $ns duplex-link-op $H2 $R1 color red
   $ns duplex-link-op $R1 $R2 color black
   $ns duplex-link-op $R2 $H3 color blue
   $ns duplex-link-op $R2 $H4 color red

   $ns duplex-link-op $R1 $R2 queuePos 0.5
   set tcp1 [new Agent/TCP/Reno]
   set tcp2 [new Agent/TCP/Reno]
   $ns attach-agent $H1 $tcp1
   set ftp1 [new Application/FTP]
   $ftp1 attach-agent $tcp1
	

   $ns attach-agent $H2 $tcp2
   set ftp2 [new Application/FTP]
   $ftp2 attach-agent $tcp2


   set tcpsink1 [new Agent/TCPSink]
   $ns attach-agent $H3 $tcpsink1

   set tcpsink2 [new Agent/TCPSink]
   $ns attach-agent $H4 $tcpsink2

   $ns connect $tcp1 $tcpsink1
   $ns connect $tcp2 $tcpsink2

   $tcp1 set fid_ 1
   $tcp2 set fid_ 2

	
} elseif { $scenario_no == 2 } {
	 $ns duplex-link $H1 $R1 10Mb 1ms DropTail
         $ns duplex-link $H2 $R1 10Mb 1ms DropTail
       	 $ns duplex-link $H5 $R1 10Mb 1ms DropTail
	 if { $queue_mechanism == "DROPTAIL" } {
	    $ns duplex-link $R1 $R2 1Mb 10ms DropTail	
            $ns queue-limit $R1 $R2 20
	 } elseif { $queue_mechanism == "RED" } {
		  Queue/RED thres_ 10
      		  Queue/RED maxthres_ 15
      	          Queue/RED linterm_ 50	
                  $ns duplex-link $R1 $R2 1Mb 10ms RED
                  $ns queue-limit $R1 $R2 20
	 }
	 $ns duplex-link $R2 $H3 10Mb 1ms DropTail
	 $ns duplex-link $R2 $H4 10Mb 1ms DropTail
	 $ns duplex-link $R2 $H6 10Mb 1ms DropTail

	 $ns duplex-link-op $H1 $R1 orient right-down
	 $ns duplex-link-op $H2 $R1 orient right-center
	 $ns duplex-link-op $H5 $R1 orient right-up
	 $ns duplex-link-op $R1 $R2 orient right
	 $ns duplex-link-op $R2 $H3 orient right-up
	 $ns duplex-link-op $R2 $H4 orient right-center
	 $ns duplex-link-op $R2 $H6 orient right-down

	 $ns duplex-link-op $H1 $R1 color blue
	 $ns duplex-link-op $H2 $R1 color red
	 $ns duplex-link-op $H5 $R1 color green
	 $ns duplex-link-op $R1 $R2 color black	
	 $ns duplex-link-op $R2 $H3 color blue
	 $ns duplex-link-op $R2 $H4 color red
	 $ns duplex-link-op $R2 $H6 color green

	 $ns duplex-link-op $R1 $R2 queuePos 0.5
	 set tcp1 [new Agent/TCP/Reno]
	 set tcp2 [new Agent/TCP/Reno]
	 set udp1 [new Agent/UDP]

	 $ns attach-agent $H1 $tcp1
	 set ftp1 [new Application/FTP]
	 $ftp1 attach-agent $tcp1
	

	 $ns attach-agent $H2 $tcp2
	 set ftp2 [new Application/FTP]
	 $ftp2 attach-agent $tcp2
	
 	 $ns attach-agent $H5 $udp1
 	 set cbr1 [new Application/Traffic/CBR]
	 $cbr1 set PacketSize_ 100B
	 $cbr1 set rate_ 1Mb
	 $cbr1 attach-agent $udp1


	 set tcpsink1 [new Agent/TCPSink]
	 $ns attach-agent $H3 $tcpsink1

	 set tcpsink2 [new Agent/TCPSink]
	 $ns attach-agent $H4 $tcpsink2

	 set udpsink1 [new Agent/LossMonitor]
	 $ns attach-agent $H6 $udpsink1

	 $ns connect $tcp1 $tcpsink1
	 $ns connect $tcp2 $tcpsink2
	 $ns connect $udp1 $udpsink1	
	
 	 $tcp1 set fid_ 1
	 $tcp2 set fid_ 2
	 $udp1 set fid_ 3		
  }


$ns at 0 "$H1 label \"H1\""
$ns at 0 "$H2 label \"H2\""
$ns at 0 "$R1 label \"R1\""
$ns at 0 "$R2 label \"R2\""
$ns at 0 "$H3 label \"H3\""
$ns at 0 "$H4 label \"H4\""

if { $scenario_no == 2 } {
	$ns at 0 "$H5 label \"H5\""
	$ns at 0 "$H6 label \"H6\""
} 

$ns at 0 "puts $queue_mechanism"
$ns at 0 "puts $scenario_no"
$ns at 0 "$ftp1 start"
$ns at 180 "$ftp1 stop"
$ns at 0 "$ftp2 start"
$ns at 180 "$ftp2 stop"
$ns at 30 "record"
if { $scenario_no == 2 } {
	$ns at 0 "$cbr1 start"
	$ns at 180 "$cbr1 stop"
} 
$ns at 180.5 "finish"
$ns run
