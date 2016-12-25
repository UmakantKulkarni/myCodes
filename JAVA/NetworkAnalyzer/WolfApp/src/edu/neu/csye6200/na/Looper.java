/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.neu.csye6200.na;
/**
 *
 * @author Umakant
 */
import java.io.IOException;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.pcap4j.core.NotOpenException;
import org.pcap4j.core.PcapHandle;
import org.pcap4j.core.PcapNativeException;
import org.pcap4j.core.PcapNetworkInterface;
import org.pcap4j.packet.Packet;

public class Looper implements Runnable{
    
    public AtomicBoolean keepRunning;
    public int[] A; 
    String[] dataLimit = new String [4];
    public static String csk = null;
    
    public Looper() {
        keepRunning = new AtomicBoolean(true);
        dataLimit = WolfApp.pktSize;
    }
        
    public void stop() {
        keepRunning.set(false);
    }
    
    @Override   
    public void run() {
        
        try {
            GetPacket.dispConstants();            
            PcapNetworkInterface Nif = GetPacket.dispNIFs(WolfApp.x[4]);
            PcapHandle packetHandle = GetPacket.makePacket(Nif);
           
            int[] Protocol = new int[] {1, 0, 0, 0, 0, 0, 0} ;
            double[] PacketSize = new double[] {0, 0, 0, 0, 0, 0} ;
            while (keepRunning.get()) {
                
                Packet packet = packetHandle.getNextPacket();
                if (packet == null) {
                    continue;
                }
                else {
                    A = FilterPackets.filterPackets(dataLimit, packetHandle, Protocol, PacketSize, packet) ;      
                    WolfApp.geta(A);
                }                
            }
            packetHandle.close();
        } catch (PcapNativeException | NotOpenException | InterruptedException ex) {
            Logger.getLogger(Looper.class.getName()).log(Level.SEVERE, null, ex);
        } catch (IOException ex) {
            Logger.getLogger(Looper.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
   
}
