/**
 * CSYE 6200 Vehicle starter class
 * 
 * @author (your name here)
 * ID: (your ID here)
 *
 */
public class Vehicle {
   int passengers;
   int fuelCap;
// Note - in the lecture, we switched from using Miles Per Gallon (MPG) to using Kilometers Per Liter (KPL).
   double kpl; // <== so this should be 'kpl', not 'mpg'
   String make ;
   String model ;
   int modelYear ;
   String licensePlate ;

   public Vehicle() {
	   this.make = "Volvo" ;
	   this.model = "S80" ;
	   this.licensePlate = "VBG 984" ;
	   this.passengers = 4 ;
	   this.fuelCap = 70 ;
	   this.kpl = 8.08 ;
	   this.modelYear = 2006 ;
   }
   
   public Vehicle(int passengers, int fuelCap, double kpl, String make, String model, int modelYear, String licensePlate) 
   {
	
	this.passengers = passengers;
	this.fuelCap = fuelCap;
	this.kpl = kpl;
	this.make = make;
	this.model = model;
	this.modelYear = modelYear;
	this.licensePlate = licensePlate;
}
   
   public double vehicleRange() {
	   return fuelCap * kpl ;
   }

@Override
public String toString() {
	return make + " " + model + "\n[\nPassenger Capacity = " + passengers + " \nFuel Capacity = " + fuelCap + " \nKilometers Per Litre = " + kpl + " \nMake = " + make
			+ " \nModel = " + model + " \nModel Year = " + modelYear + " \nLicense Plate Number = " + licensePlate + "\nRange = " + vehicleRange() + "km\n]";
}

}