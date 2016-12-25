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
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.List;
import org.pcap4j.core.BpfProgram.BpfCompileMode;
import org.pcap4j.core.NotOpenException;
import org.pcap4j.core.PcapAddress;
import org.pcap4j.core.PcapHandle;
import org.pcap4j.core.PcapHandle.TimestampPrecision;
import org.pcap4j.core.PcapNativeException;
import org.pcap4j.core.PcapNetworkInterface;
import org.pcap4j.core.PcapNetworkInterface.PromiscuousMode;
import org.pcap4j.core.Pcaps;
import org.pcap4j.util.LinkLayerAddress;

@SuppressWarnings("javadoc")
public class GetPacket {
    
    public static String LINE_SEPARATOR = System.getProperty("line.separator");
    public static String msg1;

    public static final int READ_TIMEOUT = 10;
    public static final int SNAPLEN = 65536;
    public static final int BUFFER_SIZE = 1048576;
    public static final boolean TIMESTAMP_PRECISION_NANO = false;
    public static final String NIF_NAME = null;
    public static String allNIFs;
    
    public static void dispConstants () {
        
        System.out.println("READ_TIMEOUT : " + READ_TIMEOUT);
        System.out.println("SNAPLEN : " + SNAPLEN);
        System.out.println("BUFFER_SIZE_KEY : " + BUFFER_SIZE);
        System.out.println("TIMESTAMP_PRECISION_NANO_KEY : " + TIMESTAMP_PRECISION_NANO);
        System.out.println("NIF_NAME_KEY : " + NIF_NAME);
        System.out.println("\n");
        
    } 
    
    public static String write(String msg) throws IOException {
        System.out.print(msg);
        return msg;
    }

  /**
   *
   * @return string
   * @throws IOException if fails to read.
   */
    public static String read() throws IOException {
        BufferedReader reader
          = new BufferedReader(new InputStreamReader(System.in));
        return reader.readLine();
    }

  /**
   *
   * @param nifs nifs
   * @throws IOException if fails to show.
   */
    public static String showNifList(List<PcapNetworkInterface> nifs)throws IOException {
        StringBuilder sb = new StringBuilder(200);
        int nifIdx = 0;
        for (PcapNetworkInterface nif: nifs) {
          sb.append("NIF[").append(nifIdx).append("]: ")
            .append(nif.getName()).append(LINE_SEPARATOR);

          if (nif.getDescription() != null) {
            sb.append("      : description: ")
              .append(nif.getDescription()).append(LINE_SEPARATOR);
          }

          for (LinkLayerAddress addr: nif.getLinkLayerAddresses()) {
            sb.append("      : link layer address: ")
              .append(addr).append(LINE_SEPARATOR);
          }

          for (PcapAddress addr: nif.getAddresses()) {
            sb.append("      : address: ")
              .append(addr.getAddress()).append(LINE_SEPARATOR);
          }
          nifIdx++;
        }
        sb.append(LINE_SEPARATOR);

        msg1 = write(sb.toString());
        return msg1;
    }
  
    
    public static String showNIF () throws PcapNativeException, IOException {
        List<PcapNetworkInterface> allDevs = Pcaps.findAllDevs();
        allNIFs = showNifList(allDevs);        
        return allNIFs;
    }
    
    public static List<PcapNetworkInterface> showDev () throws PcapNativeException, IOException {
        List<PcapNetworkInterface> allDevs = Pcaps.findAllDevs();
        return allDevs;
    }
    
    public static PcapNetworkInterface dispNIFs (int a) throws PcapNativeException, IOException {
        List<PcapNetworkInterface> allDevs = showDev();
        PcapNetworkInterface nif = doSelect(allDevs,a);
        
        System.out.println(nif.getName() + " (" + nif.getDescription() + ")");
        for (PcapAddress addr: nif.getAddresses()) {
            if (addr.getAddress() != null) {
                System.out.println("IP address: " + addr.getAddress());
            }
        }
        System.out.println("");
        return nif;
    }
    
    public static PcapHandle makePacket (PcapNetworkInterface Nif) throws PcapNativeException, NotOpenException {
        
        PcapNetworkInterface nif = Nif;

        PcapHandle.Builder phb = new PcapHandle.Builder(nif.getName())
            .snaplen(SNAPLEN)
            .promiscuousMode(PromiscuousMode.PROMISCUOUS)
            .timeoutMillis(READ_TIMEOUT)
            .bufferSize(BUFFER_SIZE);

        if (TIMESTAMP_PRECISION_NANO) {
            phb.timestampPrecision(TimestampPrecision.NANO);
        }

        PcapHandle handle = phb.build();
        handle.setFilter("",BpfCompileMode.OPTIMIZE);
        
        return handle;
        
    }
    
    public static PcapNetworkInterface doSelect(List<PcapNetworkInterface> nifs, int a) throws IOException {
        int nifIdx = a;
        while (true) {
          try {
            //nifIdx = Integer.parseInt(input);
            if (nifIdx < 0 || nifIdx >= nifs.size()) {
              write("Invalid input." + LINE_SEPARATOR);
              continue;
            }
            else {
              break;
            }
          } catch (NumberFormatException e) {
            write("Invalid input." + LINE_SEPARATOR);
            continue;
          }
        }
        return nifs.get(nifIdx);
    }
    
}
