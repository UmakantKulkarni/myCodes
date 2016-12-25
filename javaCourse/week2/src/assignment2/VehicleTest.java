package assignment2;
/**
 * CSYE 6200 Assignment #2 starter file
 */

/**
 * A special class used to test the Vehicle class
 * @author Umakant Kulkarni
 * ID: 001685850
 *
 */
public class VehicleTest {

	/**
	 * This is where your program starts
	 * @param args
	 */
	public static void main(String[] args) {
		run() ;
	}
	
	private static void run() {
		Vehicle minivan = new Vehicle();
	    Vehicle sportscar = new Vehicle(2,48,5,"Lamborghini","Gallardo",2010,"VB6 999");
	    
	    System.out.println("Minivan: " + minivan);
	    System.out.println("Sportscar " + sportscar);
	}

}
