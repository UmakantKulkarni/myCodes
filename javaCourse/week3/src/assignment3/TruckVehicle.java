package assignment3;
/**
 * CSYE 6200 Assignment #3 starter file
 */

/**
 * A special class used to test the Vehicle class
 * @author Umakant Kulkarni
 * ID: 001685850
 *
 */
public class TruckVehicle extends Vehicle {

	public double heightCargo; // in meters
	public double lengthCargo; // in  meters
	public double widthCargo; // in meters

	public TruckVehicle() {

		heightCargo = 1.25 ;
		lengthCargo = 2.5 ;
		widthCargo = 3.75 ;

	}

	public TruckVehicle (int passengers, int fuelCap, double kpl, String make, String model, int modelYear, String licensePlate, 
		double heightCargo, double lengthCargo, double widthCargo) {

		super (passengers, fuelCap, kpl, make, model, modelYear, licensePlate) ;
		
		this.heightCargo = heightCargo ;
		this.lengthCargo = lengthCargo ;
		this.widthCargo = widthCargo ;

	}
		
	public double CalCargoArea (double length, double width) {
		double cargoArea;
		return cargoArea = length * width;
	}
	
	public String toString() {
		return super.toString() + "Area of Cargo = " + CalCargoArea(this.lengthCargo, this.heightCargo) + " meter squared \n\n";
	}

}
