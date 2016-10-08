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
class Example9 {
  
  // JAVA Program starts here with a call to main ()
  public static void main(String args[]) throws java.io.IOException {

    String expr = "";
    char inChar = ' ';    
    String[] inputHistory = {"*", "*", "*", "*"}; //Array to store Input History 
    Scanner scanner = new Scanner(System.in); // Method to read the given Input
        
    do {
    
      System.out.println("\nEnter choice (1,2,3), or \'q\' to quit, then press <enter>.");    
      
      expr = scanner.nextLine();
      System.out.println("Your Input Keyword: " + expr); // Display the input given by User      

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
              System.out.println("\nEnter the Input to be converted, then press <enter>.");
              String var = scanner.nextLine(); //Store the Input in a variable
              char charIn = var.charAt(0) ; //Extract the exact keyword from Input        
              System.out.println("Input character before conversion to integer: " + charIn);
              int charToInt  = (int) charIn; // Convert character to Integer
              System.out.println("Output character after conversion to integer: " + charToInt);
              break;  
            case '3':
              System.out.println("You selected option 3");
              System.out.println("Input History from oldest to latest upto 3 entries: ");
              for (int i = 1; i < inputHistory.length; i++) {
                System.out.println (inputHistory[i]); // Display previous 3 Inputs with oldes at the top and latest at the bottom
              }
              break;
            case 'q':
              break;                   
            default:
              System.out.println("Invalid Input Character: " + inChar);
              break;
          }

      } else {   

        if ("ukul".equals(expr)) {
          System.out.println("Password Accepted"); //Compare the input string with the Password 
        } else if ("".equals(expr)) {
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