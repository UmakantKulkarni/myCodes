/*
This is an Example Program
*/
import java.util.Scanner; 
class Example8 {
  
  // JAVA Program starts here with a call to main ()
  public static void main(String args[]) throws java.io.IOException {

    char inChar = ' ';
    String expr = "";
    String[] inputHistory = {"*", "*", "*", "*"}; 
    Scanner scanner = new Scanner(System.in);
        
    do {
    
      System.out.println("\nEnter choice (1,2,3), or \'q\' to quit, then press <enter>.");
      //inChar = scanner.next().charAt(0) ;
      expr = scanner.nextLine();
      System.out.println("Your Input " + expr);

      int length2 = expr.length();  

      for (int i=1; i<=inputHistory.length-1;i++) {
        inputHistory[i-1] = inputHistory[i];
      }
      inputHistory[3] = expr;   

      if (length2 == 1) {

        //System.out.println("lnth is 1");
        inChar = expr.charAt(0) ;      
                   
          switch (inChar) {
            case '1':
              System.out.println("You selected option 1");
              int sumCube = 0;
              for (int i = 0; i < 10; i++) {
                int iCube = i * i * i;
                System.out.println("The number is = "+ i +" ; The Cubed number is = "+ iCube);
                sumCube += iCube;
              }
              System.out.println("Sum of the Cubes is: " + sumCube);
              break;
            case '2':
              System.out.println("You selected option 2");
              System.out.println("Input character before conversion to integer: " + inChar);
              int charToInt  = (int) inChar;
              System.out.println("Output character after conversion to integer: " + charToInt);
              break;  
            case '3':
              System.out.println("You selected option 3");
              System.out.println("Input History from oldest to latest upto 3 entries: ");
              for (int i = 1; i < inputHistory.length; i++) {
                System.out.println (inputHistory[i]);
              }
              break;
            case 'q':
              break;
            default:
              System.out.println("Invalid Input: " + inChar);
              break;
          }
      } else {
        //System.out.println("length  is " + length2);
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