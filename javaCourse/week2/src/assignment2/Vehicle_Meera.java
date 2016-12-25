package assignment2;

/**
 * CSYE 6200 Vehicle starter class
 * 
 * @author: Meera Sudhakar
 * ID: 001951332
 *
 */
public class Vehicle_Meera {
   int passengers;
   int fuelCap;
// Note - in the lecture, we switched from using Miles Per Gallon (MPG) to using Kilometers Per Liter (KPL).
   double kpl; // <== so this should be 'kpl', not 'mpg'... made the change
   String make;
   String model; 
   int modelYear;
   
   /**
    * Constructor that assigns default values to the parameters of the object
    */
   public Vehicle_Meera() {
	   passengers = 4;
	   fuelCap = 50;
	   kpl = 20.5;
	   make = "Volvo";
	   model = "S80";
	   modelYear = 2005;
   }
   
   /**
    * Constructor that sets the values (of the parameters) that are passed to it
    * @param passengers (Number of passengers)
    * @param fuelCap (Fuel Capacity)
    * @param kpl (Kilometers per Liter)
    * @param make (Make of the vehicle)
    * @param model (Model of the vehicle) 
    * @param modelYear (Model Year)
    */
   public Vehicle_Meera (int passengers, int fuelCap, double kpl, String make, String model, int modelYear) {
	   this.passengers = passengers;
	   this.fuelCap = fuelCap;
	   this.kpl = kpl;
	   this.make = make;
	   this.model = model;
	   this.modelYear = modelYear;
   }
   
   /**
    * Method that returns the vehicle's range
    * @return
    */
   double calculateRange() {
	   return fuelCap * kpl;
   }
   
   /**
    * Method to print an attractive display of the vehicle's data including range
    */
   public String toString() {
	   return "Number of passengers: " + this.passengers + ".\nFuel Capacity: " + this.fuelCap + ".\nKilometers per Liter: " + this.kpl + ".\nRange: " + this.calculateRange() + ".\nMake: " + this.make + ".\nModel: " + this.model + ".\nModel Year: " + this.modelYear + ".\n";
   }
}
