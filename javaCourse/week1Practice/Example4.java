/*
This is an Example Program
*/

class Example4 {
	
	// JAVA Program starts here with a call to main ()
	public static void main(String args[]) throws java.io.IOException {

		char inChar = ' ';
		char[] startingArray = {'*', '*', '*'}; 
		
		do {
	
			System.out.println("\nEnter choice (1,2,3), or \'q\' to quit, then press <enter>.");
			inChar = (char) System.in.read();
			switch (inChar) {
				case '1':
					System.out.println("You selected option 1");
					for (int i = 0; i < 10; i++) {
						int iSqre = i * i;
						System.out.println("The number is = "+ i +" ; The Squared number is = "+ iSqre);
					}
					break;
				case '2':
					System.out.println("You selected option 2");
					// Converting the input into an integer and printing it
					System.out.println("Input char before conversion to integer: " + inChar);
					int inCharIntForm  = (int) inChar;
					System.out.println("Input  char after conversion to integer: " + inCharIntForm);
					break;	
				case 'q':
				case '\r': break;
				case '\n': break;
				default:
					System.out.println("Invalid selection: " + inChar);
					break;
			}
			
		}

		while (inChar != 'q'); 
		System.out.println("Quitting...");
				
	}


}