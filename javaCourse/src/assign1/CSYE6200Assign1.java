package assign1;

/**
 * A starter file for implementing CSYE 6200 Assignment 1 <br>
 * Note: the package is 'assign1' so your code should be in source folder: src\assign1
 * Filename: CSYE6200Assign1.java <br>
 * 
 * NUID: 001951332 <br>
 * @author Meera Sudhakar
 */
class CSYE6200Assign1 {

	/**
	 * Your program starts with this method call
	 */
	public static void main(String args[]) throws java.io.IOException {
		// Create an instance of the class, and call the constructor method
		CSYE6200Assign1 prog1 = new CSYE6200Assign1();
		prog1.run(); // call the run method
		// We're done. The program will exit.
	}

	/**
	 * Constructor
	 */
	public CSYE6200Assign1() {
		// After a 'new' call the constructor is executed first - for now, nothing happens
	}
	
	/**
	 * Perform all of the user operations
	 */
	public void run() throws java.io.IOException {
		char inChar = ' '; 
		// Create an array to collect the input history. This array collects the last four inputs for 
		// the sake of verifying the password (bonus part of the assignment), but when option 3 is selected,
		// it only displays the last three inputs that were entered. 
		char[] arrayWithInputHistory = {'*', '*', '*', '*'};
		do {
			System.out.println("\nEnter choice (1,2,3), or \'q\' to quit, then press <enter>."); //moved this line into the do-while loop so that the user will know that he can enter multiple values
			do {
				inChar = (char) System.in.read();
			} while(inChar == '\n' | inChar == '\r'); //leaving out the carriage return and new line chars
			
			// Add the input to the array
			for (int i=1; i<=arrayWithInputHistory.length-1;i++) {
				arrayWithInputHistory[i-1] = arrayWithInputHistory[i];
			}
			arrayWithInputHistory[3] = inChar; // adding the latest input to the last position of the history array
			boolean ret = isPassCodeTyped(arrayWithInputHistory); // bonus part. Checked whenever a new input is given by the user
			switch (inChar) {
			case '1':
				System.out.println("You selected option 1");
				// Printing the number and number squared from range 1-9
				int sqrSum = 0;
				for (int i = 1;i <= 9;i++) {
					int iSqr = i * i;
					System.out.println("The number is: " + i + ". Square of the number is: " + iSqr + ".");
					sqrSum += iSqr;
				}
				// Printing the sum of the displayed squared values
				System.out.println("Sum of the squares is: " + sqrSum);
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
				for (int i = 1; i < arrayWithInputHistory.length; i++) {
					System.out.println (arrayWithInputHistory[i]);
				}
				break;  
			case '\r': break;
			case '\n': break;
			case 'q': break;
			default:
				if (ret != true) { // if the password is found to have been entered, then ret is true and the line below is not printed 
					System.out.println("Invalid selection: " + inChar);
					break;
				}
				 
			}
			// react to input and take appropriate action

			// check for password matching
			// if (isPassCodeTyped(inchar)) 
			//    ...do something...

		} 
		while (inChar != 'q'); // Exit on quit
		System.out.println("Quitting...");
	}

	/*
	 * Has the passcode been typed?
	 * @return true if the password sequence has been typed
	 */
	private boolean isPassCodeTyped(char[] inputArray) {
		// Check this keypress, and also check prior keypress values
		String myPassCode = "msud";
		char[] myPassCodeArray  = myPassCode.toCharArray();
		int minLength = Math.min(myPassCodeArray.length, inputArray.length);
		for(int i = 0; i < minLength; i++) {
			if (myPassCodeArray[i] != inputArray[i]) {
				return false;
			}
		}
		System.out.println("Password Accepted.");
		return true;
	}
}