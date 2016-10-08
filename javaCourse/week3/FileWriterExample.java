import java.io.FileWriter ;
import java.io.IOException ;
import java.util.logging.Logger;

public class FileWriterExample {

	public void writeDataToFile (String filename) {
		FileWriter fw;

		try {
			fw = new FileWriter(filename);
			fw.write("First Line " + 5);
			fw.close();
		} catch (IOException ex) {
			Logger.getLogger (FileWriterExample.class.getName()).log(Level.SEVERE, null, ex);
		}
	}
	
	public static void main(String[] args) {

		FileWriterExample example = new FileWriterExample();
		example.writeDataToFile("abc.txt");

	}

}