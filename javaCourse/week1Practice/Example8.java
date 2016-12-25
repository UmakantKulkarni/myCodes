/**
 * CSYE 6200 Assignment #1 starter file
 */

/**
 * 
 * @author Umakant Kulkarni
 * ID: 001685850
 *
 */
import java.util.Scanner; 
class Example8 {
  
  // JAVA Program starts here with a call to main ()
  public static void main(String args[]) throws java.io.IOException {

    char inChar = ' ';
    String expr = "";
    String[] inputHistory = {"*", "*", "*", "*"}; //Array to store Input History 
    Scanner scanner = new Scanner(System.in); // Method to read the given Input
        
    do {
    
      System.out.println("\nEnter choice (1,2,3), or \'q\' to quit, then press <enter>.");
      
      expr = scanner.nextLine();
      System.out.println("Your Input " + expr); // Display the input given bu User

      int length2 = expr.length();  //Calculate length of the input String

      for (int i=1; i<=inputHistory.length-1;i++) {
        inputHistory[i-1] = inputHistory[i];
      } 
      inputHistory[3] = expr; //Store the given input in the Input History Array

      //If Input is a single character
      if (length2 == 1) {
        
        inChar = expr.charAt(0) ;      
                   
          //Use switch case to process the input and take further actions
          switch (inChar) {
            case '1':
              System.out.println("You selected option 1");
              int sumCube = 0;
              for (int i = 0; i < 10; i++) {
                int iCube = i * i * i;
                System.out.println("The number is = "+ i +" ; The Cubed number is = "+ iCube);
                sumCube += iCube; 
              }
              System.out.println("Sum of the Cubes is: " + sumCube); // Display Sum of all Cubes
              break;
            case '2':
              System.out.println("You selected option 2");
              System.out.println("Input character before conversion to integer: " + inChar);
              int charToInt  = (int) inChar; // Convert character to Integer
              System.out.println("Output character after conversion to integer: " + charToInt);
              break;  
            case '3':
              System.out.println("You selected option 3");
              System.out.println("Input History from oldest to latest upto 3 entries: ");
              for (int i = 1; i < inputHistory.length; i++) {
                System.out.println (inputHistory[i]); // Display previous 3 Inputs with oldes at thr top and latest at the bottom
              }
              break;
            case 'q':
              break;
            default:
              System.out.println("Invalid Input: " + inChar);
              break;
          }
      } else {        
        if ("ukul".equals(expr)) {
          System.out.println("Password Accepted");
        } else {
          System.out.println("Invalid Input: " + expr);
        }      
      }      
    }
    while (inChar != 'q'); 
    System.out.println("Quitting...");        
  }
}