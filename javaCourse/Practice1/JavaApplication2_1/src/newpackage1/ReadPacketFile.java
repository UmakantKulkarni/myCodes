package newpackage1;

import java.io.EOFException;
import java.util.concurrent.TimeoutException;
import org.pcap4j.core.NotOpenException;
import org.pcap4j.core.PcapHandle;
import org.pcap4j.core.PcapHandle.TimestampPrecision;
import org.pcap4j.core.PcapNativeException;
import org.pcap4j.core.Pcaps;
import org.pcap4j.packet.Packet;
import java.util.Scanner; 

@SuppressWarnings("javadoc")
public class ReadPacketFile {

  private static final int COUNT = 50;

  private static final String PCAP_FILE_KEY
    = ReadPacketFile.class.getName() + ".pcapFile";
  private static final String PCAP_FILE
    = System.getProperty(PCAP_FILE_KEY, "src/main/resources/echoAndEchoReply.pcap");

  private ReadPacketFile() {}

  public static void main(String[] args) throws PcapNativeException, NotOpenException {
    String expr = "";
    char inChar = ' ';  
    Scanner scanner = new Scanner(System.in);
            
    do {
              
        System.out.println("\nEnter choice \'q\' to quit, then press <enter>.");    
        expr = scanner.nextLine();
        System.out.println("Your Input Keyword: " + expr); // Display the input given by User      
        int length2 = expr.length();  //Calculate length of the input String
        
        if (length2 == 1) {
            inChar = expr.charAt(0) ;      

            System.out.println("Your Input Keyword: " + expr); // Display the input given by User      

            PcapHandle handle;
            try {
              handle = Pcaps.openOffline(PCAP_FILE, TimestampPrecision.NANO);
            } catch (PcapNativeException e) {
              handle = Pcaps.openOffline(PCAP_FILE);
            }

            //(int i = 0; i < COUNT; i++)
            for (int i = 0; ; i++) {
              try {
                Packet packet = handle.getNextPacketEx();
                System.out.println(handle.getTimestamp());
                System.out.println(packet);
                //System.out.println(packet.length());
                //System.out.println(packet.getRawData());
              } catch (TimeoutException e) {
              } catch (EOFException e) {
                System.out.println("EOF");
                break;
              }
            }
            handle.close();
        } else {   
            if ("".equals(expr)) {
              System.out.println("Enter key is pressed ; Please enter valid keyword"); //Check if Enter key is pressed without any keyword
            } else {
              System.out.println("Invalid Input Keyword: " + expr); 
            }             
        }      
    }
    while (inChar != 'q'); 
    System.out.println("Quitting..."); // Quit if key 'q' is pressed       
  } 

}