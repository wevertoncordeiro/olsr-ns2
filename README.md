# olsr-ns2
OLSR (RFC 3626 + ETX / ML / MD variants) for NS-2

Frequently Asked Questions (FAQ) about the OLSR-ETX / ML / MD module for NS-2
Copyright (c) 2009 Weverton Luis da Costa Cordeiro
Acknowledgements

Thanks to Francisco J. Ros, who has initially released OLSR code for NS2 (http://masimum.dif.um.es/?Software:UM-OLSR) as open source software.
Introduction

I have received several questions regarding the OLSR-ETX / ML / MD module, most of them more than once. In order to ease the process of obtaining information, I have selected the most relevant Q&A and posted in this page, in hope that it will be useful for prospective users. This document is not intended to have the same style of a scientific document or report; in any case, my apologies for mistakes found in it. Comments and contributions are very welcome.

QUESTION - How do I install the OLSR-ETX / ML / MD module for NS-2?

(Adapted from UM-OLSR, by Francisco J. Ros)

The process is fairly simple. Here we assume that you have downloaded and unpackaged the allinone distribution of ns2. Assuming also that you have downloaded olsr-x.x.xx.tar.gz to your home folder, execute:

$ tar xzf olsr-x.x.xx.tar.gz
$ cd ns-allinone-x.xx/ns-x.xx/
$ patch -p1 < ~/olsr-x.x.x/olsr.patch


If you haven't installed ns2 yet, then do the following:

$ cd ..
$ ./install


On the other hand, if you are installing UM-OLSR on a running installation of ns2:

$ ./configure
$ make distclean
$ ./configure
$ make


NOTE: code should work on previous versions of ns2, but only patches for the latest ones are provided.

QUESTION - What is the purpose of the several parameters of the OLSR-ETX / ML / MD module ?

These parameters are use to specify which algorithms should be used for selection of multipoint relays and computation of routing tables, the behavior of the OLSR protocol, etc.

In summary, the implementations that you may find in the web site (http://www.inf.ufrgs.br/~wlccordeiro/resources/olsr/) are actually several versions of the same ns module for simulating the different flavours of OLSR: the original OLSR (as published in RFC 3626), OLSR-ETX (a variation of the original OLSR employing the metric proposed by De Couto et al.), OLSR-ML (proposed by Passos et al.), and OLSR-MD (the one our team have proposed). You may find link to the papers describing each of these papers in http://www.inf.ufrgs.br/~wlccordeiro/resources.html . Basically, what we have done was implementing all these flavors in the same ns module. The behaviour of the module depends on the values assigned to the following variables:

Simulation of the ordinary OLSR:

Agent/OLSR set mpr_algorithm_        1
Agent/OLSR set routing_algorithm_    1
Agent/OLSR set link_quality_         1
Agent/OLSR set link_delay_           false


Simulation of OLSR-ETX:

Agent/OLSR set mpr_algorithm_        2
Agent/OLSR set routing_algorithm_    2
Agent/OLSR set link_quality_         2
Agent/OLSR set link_delay_           false


Simulation of OLSR-ML:

Agent/OLSR set mpr_algorithm_        2
Agent/OLSR set routing_algorithm_    2
Agent/OLSR set link_quality_         3
Agent/OLSR set link_delay_           false


Simulation of OLSR-MD:

Agent/OLSR set mpr_algorithm_        2
Agent/OLSR set routing_algorithm_    2
Agent/OLSR set link_quality_         2  # doesn't matter in this case
Agent/OLSR set link_delay_           true


The variable mpr_algorithm_ indicates the Multipoint Relay (MPR) selection algorithm that is going to be used. Some of the algorithms implemented in the OLSR module algorithm are extensive explained in the papers Quality of service routing in ad-hoc networks using OLSR and Optimal path selection in a link state QoS routing protocol.

The variable routing_algorithm_, in turn, indicates whether the shortest path or Dijkstra algorithm will be used to compute each node's routing table.

The variable link_quality_ indicates how the link quality metric will be computed: if it will either follow the guidelines proposed by De Couto et al (A HighThroughput Path Metric for MultiHop Wireless Routing) or by Passos et al. (Mesh Network Performance Measurements).

Finally, the variable link_delay_ indicates whether the minimum delay between nodes will serve as criterion for the selection of paths between them. In order to compute delay, we have used a variation of the CapProbe algorithm (further information and references may be found in Providing Quality of Service for Mesh Networks Using Link Delay Measurements).

QUESTION - How do I configure my tcl scripts to simulate a mesh network? What do the values for the various OLSR parameters in the TCL scripts mean?

The meaning of the various parameter values used to define the behavior of the OLSR protocol in the TCL script are described in the OLSR_parameter.h file. These are described in the table below:
Parameter 	Description 	Possible Values 	Value Description
Agent/OLSR set use_mac_ 	Determines if layer 2 notifications are enabled or not 	true, false 	--
Agent/OLSR set willingness 	Willingness of a node for forwarding packets on behalf of other nodes 	(see RFC 3626) 	(see RFC 3626)
Agent/OLSR set hello_ival_ 	HELLO messages' emission interval 	(see RFC 3626) 	(see RFC 3626)
Agent/OLSR set tc_ival_ 	TC messages' emission interval 	(see RFC 3626) 	(see RFC 3626)
Agent/OLSR set tc_redundancy_ (v 0.2.2 and prior, see below) 	Determine the redundancy level of TC messages 	0 (OLSR_TC_REDUNDANCY_MPR_SEL_SET) 	(see RFC 3626)
1 (OLSR_TC_REDUNDANCY_MPR_SEL_SET_PLUS_MPR_SET) 	(see RFC 3626)
2 (OLSR_TC_REDUNDANCY_FULL) 	(see RFC 3626)
3 (OLSR_TC_REDUNDANCY_MPR_SET) 	non-OLSR standard: publish mpr set only
Agent/OLSR set mpr_algorithm_ 	Indicate which MPR selection algorithm will be used 	1 (OLSR_DEFAULT_MPR) 	use the original MPR selection algorithm as proposed in RFC 3626
2 (OLSR_MPR_R1) 	non-OLSR standard: use the MPR selection algorithm OLSR_R1 (paper)
3 (OLSR_MPR_R2) 	non-OLSR standard: use the MPR selection algorithm OLSR_R2 (paper)
4 (OLSR_MPR_QOLSR) 	non-OLSR standard: use the MPR selection algorithm QOLSR_MPR_Selection (paper)
5 (OLSR_MPR_OLSRD) 	non-OLSR standard: use the MPR selection algorithm implemented in olsrd (see http://www.olsr.org/)
Agent/OLSR set routing_algorithm_ 	Determine which routing algorith is to be used 	1 (OLSR_DEFAULT_ALGORITHM) 	use the original hop count algorithm as proposed in RFC 3626
2 (OLSR_DIJKSTRA_ALGORITHM) 	non-OLSR standard: use Dijkstra algorithm to compute routes based on the metric enabled
Agent/OLSR set link_quality_ 	Determines which heuristic should be used for link quality computation 	1 (OLSR_BEHAVIOR_NONE) 	No link quality computation, default OLSR behavior
2 (OLSR_BEHAVIOR_ETX) 	non-OLSR standard: use the ETX metric to assert link quality between nodes (paper)
3 (OLSR_BEHAVIOR_ML) 	non-OLSR standard: use the ML metric to assert link quality between nodes (paper)
* Agent/OLSR set fish_eye_ 	Determine whether fish eye extension should be used 	true, false 	(see paper; note: the fish eye extension is not guaranteed to work properly as specified)
Agent/OLSR set link_delay_ 	Determine whether the link delay extension should be enabled 	true, false 	(see paper)
Agent/OLSR set c_alpha_ 	Factor that will be used to smooth link delays 	[0,1] 	(see paper)


IMPORTANT: In the case of the OLSR modules prior to version 0.2.3, the values specified to the tc_redundancy_ parameter have a different interpretation, non-compliant to RFC 3626, as follows:

Parameter 	Description 	Possible Values 	Value Description
Agent/OLSR set tc_redundancy_ 	Determine the redundancy level of TC messages 	0 	non-OLSR standard: no node is published in TC messages
1 	non-OLSR standard: publish the mpr set in TC messages
2 	non-OLSR standard: publish the mpr sel set in TC messages
3 	non-OLSR standard: publish the mpr set plus mpr sel set in TC messages

QUESTION - How should I use the scripts (result.sh and run.sh) placed in "other" directory?

The scripts run.sh and result.sh are actually a batch for processing the wtrace.tr file generated during the simulation execution. run.sh runs the simulation 10 times, using 10 different seeds for the random number generator, and result.sh aggregates the information about throughput, delay, jitter, and packet loss from all the 10 simulations, and outputs a .txt that contains data to plot graphics for each of these aspects evaluated.

Just for documentation, within the script named run.sh, you'll find the words ATRASO, VAZAO, and bloqueio. These are Portuguese words for DELAY, THROUGHPUT, and loss, respectively.

The bash scripts run.sh and result.sh use a number of .pl scripts, developed by Prof. Dr. Mauro Margalho Coutinho and available at http://www.cci.unama.br/margalho/simulacao/simulacao.htm . With these files you'll be able to calculate the metrics for each simulated protocol. Also there is a 'conv' program that is required within the run.sh. This little program I wrote for converting a number from scientific notation to decimal notation. The source code of this program is available at http://www.inf.ufrgs.br/~wlccordeiro/resources/olsr/ .

QUESTION - I would like to develop my own enhancements to the OLSR-ETX / ML / MD module. How can I do that?

There is a tutorial on how to implement a manet routing protocol written by Francisco J. Ros, which is available at http://masimum.inf.um.es/?Documents . This is a good starting point to understand how the OLSR protocol was actually implemented under ns2, and where to start implementing your own stuff.

QUESTION - When using a mobile scenario (i.e., cbr-traffic, mobile senders, stationary receivers), the packet loss is enormous when using "ETX" and "Dijkstra" as OLSR settings. Analyzing the tracefile yields a lot of loops (most of them in the beginning, when the packet is immediately sent back to the receiver) and some where the packet runs in a "local loop". Why does it happen?

This problem is actually a drawback of OLSR (RFC 3626) and also of OLSRv2 (http://www.ietf.org/id/draft-ietf-manet-olsrv2-09.txt). This has been noticed not only on simulation, but also on experimental testbeds and production networks (using the olsrd daemon). The majority of mobile ad hoc networks practitioners argue this is caused by MPRs, which tend to function nicely in highly dense environments, but create these shortcoming in sparse networks. Others believe this is due to the excessive flooding of TC messages in the network. Below you may find some messages in discussion lists regarding this issue:

http://www.ietf.org/mail-archive/web/manet-dt/current/msg00255.html
http://lists.olsr.org/pipermail/olsr-users/2008-June/002590.html
http://www.ietf.org/mail-archive/web/manet/current/msg11161.html
http://www.open-mesh.org/wiki/the-olsr-story

At the time we were conducting our research with OLSR-MD, the Fish-Eye extension was introduced to OLSR (see http://portal.acm.org/citation.cfm?id=1260671 and http://lists.olsr.org/pipermail/olsr-cvs/2005-December/000093.html as initial references). However, the tests we have conducted with Fish-Eye under NS2 simulations were rather misleading, thus we have not activated it in our simulations (even though it is coded in the OLSR module we have extended).

We believe an initial effort towards mitigating this issue is looking at OLSRD, a variant of OLSR that has tackled this issue on experimental and real testbeds.
