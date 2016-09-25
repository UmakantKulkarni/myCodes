/*
This is an Example Program
*/
import java.util.Scanner; 
class Example5 {
	
	// JAVA Program starts here with a call to main ()
	public static void main(String args[]) throws java.io.IOException {

		char inChar = ' ';
		char[] startingArray = {'*', '*', '*', '*'}; 
		Scanner scanner = new Scanner(System.in);
				
		do {
		
			System.out.println("\nEnter choice (1,2,3), or \'q\' to quit, then press <enter>.");
			inChar = scanner.next().charAt(0) ;
			
			//String expr = scanner.nextLine();
			//System.out.println("String is " + expr);
			//int length1 = expr.length();			
			//if (length1 == 1) {
			//	System.out.println("lnth is 1");
			//} else {
			//	System.out.println("lnth is " + length1);
			//}
			//inChar = expr.charAt(0) ;
			
			for (int i=1; i<=startingArray.length-1;i++) {
				startingArray[i-1] = startingArray[i];
			}
			startingArray[3] = inChar;

			
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
				case '3':
					System.out.println("You selected option 3");
					// Displaying the last three inputs
					System.out.println("Displaying the last three inputs (from oldest to latest): ");
					for (int i = 1; i < startingArray.length; i++) {
						System.out.println (startingArray[i]);
					}
					break;
				case 'q': break;
				default:
					System.out.println("Invalid Input: " + inChar);
					break;
			}
			
		}

		while (inChar != 'q'); 
		System.out.println("Quitting...");
				
	}


}