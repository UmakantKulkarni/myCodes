import java.util.ArrayList;
import java.util.List;

import org.jnetpcap.Pcap;
import org.jnetpcap.PcapIf;
import org.xml.sax.Attributes;

public class NetworkInterfaces {

	public static void main(String[] args) {
		List<PcapIf> alldevs = new ArrayList<PcapIf>(); // Will be filled with NICs
		StringBuilder errbuf = new StringBuilder(); // For any error msgs

		int r = Pcap.findAllDevs(alldevs, errbuf);
		if (r == Pcap.NOT_OK || alldevs.isEmpty()) {
			System.err.printf("Can't read list of devices, error is %s",
					errbuf.toString());
			return;
		}

		System.out.println("Network devices found:");

		int i = 0;
		for (PcapIf device : alldevs) {
			String description = (device.getDescription() != null) ? device
					.getDescription() : "No description available";
			System.out.printf("#%d: %s [%s]\n", i++, device.getName(),
					description);
		}
	}

}