# ======================================================================
# Define options
# ======================================================================
set opt(chan)           Channel/WirelessChannel  ;# channel type
#set opt(prop)           Propagation/TwoRayGround   ;# radio-propagation model
set opt(prop)           Propagation/Shadowing   ;# radio-propagation model
set opt(netif)          Phy/WirelessPhy          ;# network interface type
set opt(mac)            Mac/802_11               ;# MAC type
set opt(ifq)            Queue/DropTail/PriQueue  ;# interface queue type
set opt(ll)             LL                       ;# link layer type
set opt(ant)            Antenna/OmniAntenna      ;# antenna model
set opt(ifqlen)         50                       ;# max packet in ifq
set opt(nn)             11                       ;# number of mobilenodes
set opt(adhocRouting)   OLSR                 ;# routing protocol

set opt(cp)             ""                       ;# connection pattern file
set opt(sc)             ""                       ;# node movement file.

set opt(x)              1000                     ;# x coordinate of topology
set opt(y)              1000                     ;# y coordinate of topology
set opt(seed) X
set opt(stop)           50                       ;# time to stop simulation

set opt(cbr-start)      5.0
set opt(cbr-stop)       45.0
set opt(pa-start)       7.0
set opt(pa-stop)        37.0
set opt(pa1-start)      9.0
set opt(pa1-stop)       39.0
# ============================================================================

#
# check for random seed
#
if {$opt(seed) > 0} {
    puts "Seeding Random number generator with $opt(seed)\n"
    ns-random $opt(seed)
}

#Ganho das antenas
Antenna/OmniAntenna set Gt_ 18.0
Antenna/OmniAntenna set Gr_ 18.0

Phy/WirelessPhy set bandwidth_ 11Mb

# frequencia (2.4 GHz 802.11b) {Alcance = 276 metros}
Phy/WirelessPhy set freq_ 2.4e+9

Mac/802_11 set dataRate_ 11Mb
Mac/802_11 set basicRate_ 2Mb

Propagation/Shadowing set pathlossExp_ 2.7       ;#expoente de perdas
Propagation/Shadowing set std_db_ 4.0           ;#desvio padrao (dB)
#Propagation/TwoRayGround set L_ 1.0

#
# create simulator instance
#
set ns_ [new Simulator]

#
# control OLSR behaviour from this script -
# commented lines are not needed because
# those are default values
#
Agent/OLSR set use_mac_              true
Agent/OLSR set debug_                true
Agent/OLSR set willingness           3
Agent/OLSR set hello_ival_           2
Agent/OLSR set tc_ival_              5
Agent/OLSR set mpr_algorithm_        1
Agent/OLSR set routing_algorithm_    1
Agent/OLSR set link_quality_         1
Agent/OLSR set fish_eye_             false
Agent/OLSR set link_delay_           false
Agent/OLSR set tc_redundancy_        1
Agent/OLSR set c_alpha_              0.6

#
# open traces
#
$ns_ use-newtrace
set tracefd  [open wtrace.tr w]
set namtrace [open simulation.nam w]
$ns_ trace-all $tracefd
$ns_ namtrace-all-wireless $namtrace $opt(x) $opt(y)

#
# create topography object
#
set topo [new Topography]

#
# define topology
#
$topo load_flatgrid $opt(x) $opt(y)

#
# create God
#
create-god $opt(nn)

#
# configure mobile nodes
#
$ns_ node-config -adhocRouting $opt(adhocRouting) \
                 -llType $opt(ll) \
                 -macType $opt(mac) \
                 -ifqType $opt(ifq) \
                 -ifqLen $opt(ifqlen) \
                 -antType $opt(ant) \
                 -propType $opt(prop) \
                 -phyType $opt(netif) \
                 -channelType $opt(chan) \
                 -topoInstance $topo \
                 -wiredRouting OFF \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace OFF

for {set i 1} {$i < $opt(nn)} {incr i} {
    set node_($i) [$ns_ node]
}

#
# positions

$node_(1) set X_ 160.0  #CAPACIT
$node_(1) set Y_ 485.0
$node_(1) set Z_ 15.0

$node_(2) set X_ 305.0  #DI
$node_(2) set Y_ 277.0
$node_(2) set Z_ 15.0

$node_(3) set X_ 340.0   #SECOM
$node_(3) set Y_ 226.0
$node_(3) set Z_ 15.0

$node_(4) set X_ 270.0  #Grad Basico
$node_(4) set Y_ 32.0
$node_(4) set Z_ 15.0

$node_(5) set X_ 476.0  #Reitoria
$node_(5) set Y_ 200.0
$node_(5) set Z_ 15.0

$node_(6) set X_ 628.0  #Incubadora
$node_(6) set Y_ 320.0
$node_(6) set Z_ 15.0

$node_(7) set X_ 570.0  #Musica
$node_(7) set Y_ 440.0
$node_(7) set Z_ 15.0

$node_(8) set X_ 780.0  #LABS
$node_(8) set Y_ 480.0
$node_(8) set Z_ 15.0

$node_(9) set X_ 918.0  #CT
$node_(9) set Y_ 597.0
$node_(9) set Z_ 15.0

$node_(10) set X_ 968.0  #Grad Profissional
$node_(10) set Y_ 550.0
$node_(10) set Z_ 15.0

# cores
$ns_ color 1 red
$ns_ color 2 blue
$ns_ color 3 yellow

# setup UDP connection
# CAPACIT -> GRAD PROFISSIONAL
set udp [new Agent/UDP]
$udp set class_ 1
set null [new Agent/Null]
$ns_ attach-agent $node_(1) $udp
$ns_ attach-agent $node_(10) $null
$ns_ connect $udp $null
$udp set fid_ 1

set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 40     # RTP + UDP + Payload
$cbr set rate_ 8Kb
$cbr attach-agent $udp
$ns_ at 5.0 "$cbr start"
$ns_ at 45.0  "$cbr stop"

#GRAD PROFISSIONAL -> CAPACIT
set udp1 [new Agent/UDP]
$udp1 set class_ 2
set null1 [new Agent/Null]
$ns_ attach-agent $node_(10) $udp1
$ns_ attach-agent $node_(1) $null1
$ns_ connect $udp1 $null1
$udp1 set fid_ 2

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 40     # RTP + UDP + Payload
$cbr1 set rate_ 8Kb
$cbr1 attach-agent $udp1
$ns_ at 5.0 "$cbr1 start"
$ns_ at 45.0  "$cbr1 stop"

#REITORIA -> CAPACIT
set udp2 [new Agent/UDP]
$udp2 set class_ 3
set null2 [new Agent/Null]
$ns_ attach-agent $node_(5) $udp2
$ns_ attach-agent $node_(1) $null2
$ns_ connect $udp2 $null2
$udp2 set fid_ 3

set cbr2 [new Application/Traffic/CBR]
$cbr2 set packetSize_ 40     # RTP + UDP + Payload
$cbr2 set rate_ 8Kb
$cbr2 attach-agent $udp2
$ns_ at 7.0 "$cbr2 start"
$ns_ at 45.0  "$cbr2 stop"

#CAPACIT -> REITORIA
set udp3 [new Agent/UDP]
$udp3 set class_ 4
set null3 [new Agent/Null]
$ns_ attach-agent $node_(1) $udp3
$ns_ attach-agent $node_(5) $null3
$ns_ connect $udp3 $null3
$udp3 set fid_ 4

set cbr3 [new Application/Traffic/CBR]
$cbr3 set packetSize_ 40     # RTP + UDP + Payload
$cbr3 set rate_ 8Kb
$cbr3 attach-agent $udp3
$ns_ at 7.0 "$cbr3 start"
$ns_ at 45.0  "$cbr3 stop"

#REITORIA -> CT
set udp4 [new Agent/UDP]
$udp4 set class_ 5
set null4 [new Agent/Null]
$ns_ attach-agent $node_(5) $udp4
$ns_ attach-agent $node_(9) $null4
$ns_ connect $udp4 $null4
$udp4 set fid_ 5

set cbr4 [new Application/Traffic/CBR]
$cbr4 set packetSize_ 40     # RTP + UDP + Payload
$cbr4 set rate_ 8Kb
$cbr4 attach-agent $udp4
$ns_ at 9.0 "$cbr4 start"
$ns_ at 45.0  "$cbr4 stop"

#CT -> REITORIA
set udp5 [new Agent/UDP]
$udp5 set class_ 6
set null5 [new Agent/Null]
$ns_ attach-agent $node_(9) $udp5
$ns_ attach-agent $node_(5) $null5
$ns_ connect $udp5 $null5
$udp5 set fid_ 6

set cbr5 [new Application/Traffic/CBR]
$cbr5 set packetSize_ 40     # RTP + UDP + Payload
$cbr5 set rate_ 8Kb
$cbr5 attach-agent $udp5
$ns_ at 9.0 "$cbr5 start"
$ns_ at 45.0  "$cbr5 stop"

#DI -> CT
set udp6 [new Agent/UDP]
$udp6 set class_ 7
set null6 [new Agent/Null]
$ns_ attach-agent $node_(2) $udp6
$ns_ attach-agent $node_(9) $null6
$ns_ connect $udp6 $null6
$udp6 set fid_ 7

set cbr6 [new Application/Traffic/CBR]
$cbr6 set packetSize_ 40     # RTP + UDP + Payload
$cbr6 set rate_ 8Kb
$cbr6 attach-agent $udp6
$ns_ at 11.0 "$cbr6 start"
$ns_ at 45.0  "$cbr6 stop"

#CT -> DI
set udp7 [new Agent/UDP]
$udp7 set class_ 8
set null7 [new Agent/Null]
$ns_ attach-agent $node_(9) $udp7
$ns_ attach-agent $node_(2) $null7
$ns_ connect $udp7 $null7
$udp7 set fid_ 8

set cbr7 [new Application/Traffic/CBR]
$cbr7 set packetSize_ 40     # RTP + UDP + Payload
$cbr7 set rate_ 8Kb
$cbr7 attach-agent $udp7
$ns_ at 11.0 "$cbr7 start"
$ns_ at 45.0  "$cbr7 stop"

#SECOM -> LABS
set udp8 [new Agent/UDP]
$udp8 set class_ 9
set null8 [new Agent/Null]
$ns_ attach-agent $node_(3) $udp8
$ns_ attach-agent $node_(8) $null8
$ns_ connect $udp8 $null8
$udp8 set fid_ 9

set cbr8 [new Application/Traffic/CBR]
$cbr8 set packetSize_ 40     # RTP + UDP + Payload
$cbr8 set rate_ 8Kb
$cbr8 attach-agent $udp8
$ns_ at 13.0 "$cbr8 start"
$ns_ at 45.0  "$cbr8 stop"

#LABS -> SECOM
set udp9 [new Agent/UDP]
$udp9 set class_ 10
set null9 [new Agent/Null]
$ns_ attach-agent $node_(8) $udp9
$ns_ attach-agent $node_(3) $null9
$ns_ connect $udp9 $null9
$udp9 set fid_ 10

set cbr9 [new Application/Traffic/CBR]
$cbr9 set packetSize_ 40     # RTP + UDP + Payload
$cbr9 set rate_ 8Kb
$cbr9 attach-agent $udp9
$ns_ at 13.0 "$cbr9 start"
$ns_ at 45.0  "$cbr9 stop"

#DI -> SECOM
set udp10 [new Agent/UDP]
$udp10 set class_ 11
set null10 [new Agent/Null]
$ns_ attach-agent $node_(2) $udp10
$ns_ attach-agent $node_(3) $null10
$ns_ connect $udp10 $null10
$udp10 set fid_ 11

set cbr10 [new Application/Traffic/CBR]
$cbr10 set packetSize_ 40     # RTP + UDP + Payload
$cbr10 set rate_ 8Kb
$cbr10 attach-agent $udp10
$ns_ at 15.0 "$cbr10 start"
$ns_ at 45.0  "$cbr10 stop"

#SECOM -> DI
set udp11 [new Agent/UDP]
$udp11 set class_ 12
set null11 [new Agent/Null]
$ns_ attach-agent $node_(3) $udp11
$ns_ attach-agent $node_(2) $null11
$ns_ connect $udp11 $null11
$udp11 set fid_ 12

set cbr11 [new Application/Traffic/CBR]
$cbr11 set packetSize_ 40     # RTP + UDP + Payload
$cbr11 set rate_ 8Kb
$cbr11 attach-agent $udp11
$ns_ at 15.0 "$cbr11 start"
$ns_ at 45.0  "$cbr11 stop"

#
# configurando trafego de background - pareto
#
# DI -> LABS
set tcp [new Agent/TCP]
$tcp set class_ 13
set sink [new Agent/TCPSink]
$ns_ attach-agent $node_(2) $tcp
$ns_ attach-agent $node_(8) $sink
$ns_ connect $tcp $sink
$tcp set fid_ 13

set p [new Application/Traffic/Pareto]
$p set packetSize_ 210
$p set burst_time_ 500ms
$p set idle_time_ 500ms
$p set rate_ 200k
$p set shape_ 1.5
$p attach-agent $tcp
$ns_ at 6.0 "$p start"
$ns_ at 35.0  "$p stop"

# GRAD BASICO -> CT
set tcp1 [new Agent/TCP]
$tcp1 set class_ 14
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(4) $tcp1
$ns_ attach-agent $node_(9) $sink1
$ns_ connect $tcp1 $sink1
$tcp1 set fid_ 14

set p1 [new Application/Traffic/Pareto]
$p1 set packetSize_ 210
$p1 set burst_time_ 500ms
$p1 set idle_time_ 500ms
$p1 set rate_ 200k
$p1 set shape_ 1.5
$p1 attach-agent $tcp1
$ns_ at 8.0 "$p1 start"
$ns_ at 35.0  "$p1 stop"

#SECOM -> GRAD PROFISSIONAL
set tcp2 [new Agent/TCP]
$tcp2 set class_ 15
set sink2 [new Agent/TCPSink]
$ns_ attach-agent $node_(3) $tcp2
$ns_ attach-agent $node_(10) $sink2
$ns_ connect $tcp2 $sink2
$tcp2 set fid_ 15

set p2 [new Application/Traffic/Pareto]
$p2 set packetSize_ 210
$p2 set burst_time_ 500ms
$p2 set idle_time_ 500ms
$p2 set rate_ 200k
$p2 set shape_ 1.5
$p2 attach-agent $tcp2
$ns_ at 10.0 "$p2 start"
$ns_ at 35.0  "$p2 stop"


## Label the Special Node in NAM
$ns_ at 0.0 "$node_(1) label CAPACIT"
$ns_ at 0.0 "$node_(2) label Dep_Informatica"
$ns_ at 0.0 "$node_(3) label SECOM"
$ns_ at 0.0 "$node_(4) label Grad_Basico"
$ns_ at 0.0 "$node_(5) label Reitoria"
$ns_ at 0.0 "$node_(6) label Incubadora"
$ns_ at 0.0 "$node_(7) label Musica"
$ns_ at 0.0 "$node_(8) label Laboratorios"
$ns_ at 0.0 "$node_(9) label Centro_Tec"
$ns_ at 0.0 "$node_(10) label Grad_Profissional"

#
# print (in the trace file) routing table and other
# internal data structures on a per-node basis
#
#$ns_ at 5.0 "[$node_(1) agent 255] print_rtable"
#$ns_ at 5.0 "[$node_(2) agent 255] print_rtable"
#$ns_ at 5.0 "[$node_(3) agent 255] print_rtable"
#$ns_ at 5.0 "[$node_(4) agent 255] print_rtable"
#$ns_ at 5.0 "[$node_(5) agent 255] print_rtable"
#$ns_ at 5.0 "[$node_(6) agent 255] print_rtable"
#$ns_ at 5.0 "[$node_(7) agent 255] print_rtable"
#$ns_ at 5.0 "[$node_(8) agent 255] print_rtable"
#$ns_ at 5.0 "[$node_(9) agent 255] print_rtable"
#$ns_ at 5.0 "[$node_(10) agent 255] print_rtable"
#$ns_ at 5.0 "[$node_(1) agent 255] print_linkset"
#$ns_ at 5.0 "[$node_(1) agent 255] print_nbset"
#$ns_ at 5.0 "[$node_(1) agent 255] print_nb2hopset"
#$ns_ at 5.0 "[$node_(1) agent 255] print_mprset"
#$ns_ at 5.0 "[$node_(1) agent 255] print_mprselset"
#$ns_ at 5.0 "[$node_(1) agent 255] print_topologyset"

#
# source connection-pattern and node-movement scripts
#
if { $opt(cp) == "" } {
    puts "*** NOTE: no connection pattern specified."
    set opt(cp) "none"
} else {
    puts "Loading connection pattern..."
    source $opt(cp)
}
if { $opt(sc) == "" } {
    puts "*** NOTE: no scenario file specified."
    set opt(sc) "none"
} else {
    puts "Loading scenario file..."
    source $opt(sc)
    puts "Load complete..."
}

#
# define initial node position in nam
#
for {set i 1} {$i < $opt(nn)} {incr i} {
    $ns_ initial_node_pos $node_($i) 20
}

#
# tell all nodes when the simulation ends
#
for {set i 1} {$i < $opt(nn) } {incr i} {
    $ns_ at $opt(stop).0 "$node_($i) reset";
}

$ns_ at $opt(stop).0002 "puts \"NS EXITING...\" ; $ns_ halt"
$ns_ at $opt(stop).0001 "stop"

proc stop {} {
    global ns_ tracefd namtrace
    $ns_ flush-trace
    close $tracefd
    close $namtrace
}

#
# begin simulation
#
puts "Starting Simulation..."

$ns_ run
