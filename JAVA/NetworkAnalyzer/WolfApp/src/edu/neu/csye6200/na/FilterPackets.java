/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.neu.csye6200.na;

/**
 *
 * @author umakant_kulkarni
 */
import org.pcap4j.core.NotOpenException;
import org.pcap4j.core.PcapHandle;
import org.pcap4j.core.PcapNativeException;
import org.pcap4j.core.PcapStat;
import org.pcap4j.packet.Packet;

/**
 *
 * @author GAJANAN
 */
public class FilterPackets {
    
    public static final int COUNT = 500;

    public static double roundToDecimals(double d, int c)  
        {   
           int temp = (int)(d * Math.pow(10 , c));  
           return ((double)temp)/Math.pow(10 , c);  
           
        }   

    
    public static int[] filterPackets (String[] dataLimit, PcapHandle Handle, int[] protocol, double[] packetSize, Packet packet) throws NotOpenException, PcapNativeException {

                System.out.println("\nFrame #: " + protocol[0]);
                System.out.println(Handle.getTimestamp());
                System.out.println(packet);        
                String Str = packet.toString();

                if ( Str.contains("80 (HTTP)") ) {
                    protocol[4]++;
                    packetSize[0] += packet.length();
                } else if ( Str.contains("Protocol: 1 (ICMPv4)") ) {
                    protocol[3]++;
                    packetSize[1] += packet.length();
                } else if ( Str.contains("Router Advertisement") ) {
                    protocol[5]++;
                } else if ( Str.contains("Protocol: 6 (TCP)") ) {
                    protocol[2]++;
                    packetSize[2] += packet.length();
                } else if ( Str.contains("Protocol: 17 (UDP)") ) {
                    protocol[1]++;
                    packetSize[3] += packet.length();
                } else {
                    protocol[6]++;
                    packetSize[4] += packet.length();
                }

                System.out.println("Parameter\t\tHTTP\tICMP\tTCP\tUDP\tRA\tOther\tTotal");
                System.out.println("-----------------------------------------------------------------------------");
                System.out.println("No. of Packets\t\t "+protocol[4]+"\t "+protocol[3]+"\t"+protocol[2]+"\t"+protocol[1]+"\t "+protocol[5]+"\t  "+protocol[6]+"\t  "+protocol[0]);
                System.out.println("-----------------------------------------------------------------------------");
                
                double p1 = roundToDecimals((packetSize[0]/1000),2);
                double p2 = roundToDecimals((packetSize[1]/1000),2);
                double p3 = roundToDecimals((packetSize[2]/1000),2);
                double p4 = roundToDecimals((packetSize[3]/1000),2);
                double p5 = roundToDecimals((packetSize[4]/1000),2);
                double p6 = roundToDecimals((p4+p3+p2+p1),3);
                
                System.out.println("Data Used (KB)\t\t"+p1+"\t"+p2+"\t"+p3+"\t"+p4+"\t -"+"\t "+p5+"\t"+p6);  
                
                int httpInt = (int) p1;
                int icmpInt = (int) p2;
                int tcpInt = (int) p3;
                int udpInt = (int) p4;
                
                PcapStat ps = Handle.getStats();
                int PacketsReceived = (int) ps.getNumPacketsReceived();
                int PacketsDropped = (int) ps.getNumPacketsDropped();
                int NullPacketsDropped = (int) ps.getNumPacketsDroppedByIf();
                int PacketsCaptured = (int) ps.getNumPacketsCaptured();

                System.out.println("\n\nPackets Received\tPackets Dropped\t\tPackets Rejected\t\tPackets Captured");
                System.out.println("-------------------------------------------------------------------------------------------------");
                System.out.println("\t"+ps.getNumPacketsReceived()+"\t\t\t"+ps.getNumPacketsDropped()+"\t\t\t"+ps.getNumPacketsDroppedByIf()+"\t\t\t\t"+ps.getNumPacketsCaptured());

                System.out.println("\n******************************************************End of Frame******************************************************");

                /*if (((packetSize[0]/1000) > 200) || ((packetSize[3]/1000) > 1000) || ((packetSize[1]/1000) > 20) || ((packetSize[2]/1000) > 300) || ((packetSize[4]/1000) > 200))  {
                    System.exit(0);
                } */

                if (httpInt > Integer.parseInt(dataLimit[1]) || icmpInt > Integer.parseInt(dataLimit[2]) || tcpInt > Integer.parseInt(dataLimit[0]) || udpInt > Integer.parseInt(dataLimit[3])) {
                    System.out.println("Protocols: \t\t\tHTTP\tICMP\tTCP\tUDP");
                    System.out.println("Data Limit reached (KB)\t\t"+httpInt+"\t"+icmpInt+"\t"+tcpInt+"\t"+udpInt);  
                    System.exit(0);
                } 
               
                /*if (protocol[0] >= COUNT) {
                    break;
                }*/
                
                int[] A = new int[] {protocol[0], protocol[1], protocol[2], protocol[3], protocol[4], protocol[5],
                    protocol[6], (int)p1, (int)p2, (int)p3, (int)p4, (int)p5, (int) p6, PacketsReceived, PacketsDropped, NullPacketsDropped, PacketsCaptured};
                
                protocol[0]++;
                
                return A;       
    }    
}
