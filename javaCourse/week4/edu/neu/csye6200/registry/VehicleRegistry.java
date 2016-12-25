package edu.neu.csye6200.registry;
/**
 * CSYE 6200 Vehicle Registry class
 * 
 * @author Umakant Kulkarni
 * ID: 001685850
 *
 */
import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.logging.Handler;
import java.util.logging.FileHandler;


public class VehicleRegistry {

	private static Logger log = Logger.getLogger(VehicleRegistry.class.getName());

	private static VehicleRegistry instance = null; // only one

	private VehicleRegistry () {
		log.info("Constructing a VehicleRegistry Private/Default constructor\n");
	} // A private constructor

	protected static ArrayList<Vehicle> vehicleList = new ArrayList<Vehicle>() ;
	protected static Map<String,Vehicle> vehicleMap = new HashMap<String,Vehicle>() ;

	public static VehicleRegistry getInstance() {
		// Creation only happens the first time
		if (instance == null) {
			instance = new VehicleRegistry();
			log.info("Constructing a VehicleRegistry Instance\n");
		}
		return (instance); // All other times we get the first one
	}

	public static void main(String[] args) throws Exception{

		writeToLogFile(); // Call a method to write logs to Disk
		
		VehicleRegistry database = VehicleRegistry.getInstance();
		
		//Add 3 new vehicles ; Use get to read the Data and store it to hashmap

		Vehicle v1 = new Vehicle(4, 35, 19, "Maruti", "800", 1983, "KLU287");
		database.addVehicle(v1);
		database.addVehicleToMap(v1.licensePlate,v1);
		database.getVehicle();

		Vehicle v2 = new Vehicle();
		database.addVehicle(v2);
		database.addVehicleToMap(v2.licensePlate,v2);
		database.getVehicle();

		Vehicle v3 = new Vehicle(2,48,5,"Lamborghini1","Gallardo1",2010,"XB1999");
		database.addVehicle(v3);
		database.addVehicleToMap(v3.licensePlate,v3);

		//Add 9 more new vehicles ; This is the part of assignment 4
		Vehicle v4 = new Vehicle(2,50,9,"Lamborghini2","Gallardo2",2011,"NB2888");
		database.addVehicle(v4);
		Vehicle v5 = new Vehicle(2,52,8,"Lamborghini3","Gallardo3",2012,"HB3777");
		database.addVehicle(v5);
		Vehicle v6 = new Vehicle(2,54,7,"Lamborghini4","Gallardo4",2013,"WB4666");
		database.addVehicle(v6);
		Vehicle v7 = new Vehicle(2,56,6,"Lamborghini5","Gallardo5",2014,"TB5555");
		database.addVehicle(v7);
		Vehicle v8 = new Vehicle(2,58,5,"Lamborghini6","Gallardo6",2015,"OB6444");
		database.addVehicle(v8);
		Vehicle v9 = new Vehicle(2,60,4,"Lamborghini7","Gallardo7",2016,"SB7333");
		database.addVehicle(v9);
		Vehicle v10 = new Vehicle(2,62,3,"Lamborghini8","Gallardo8",2009,"LB8222");
		database.addVehicle(v10);
		Vehicle v11 = new Vehicle(2,64,2,"Lamborghini9","Gallardo9",2008,"BB0111");
		database.addVehicle(v11);
		Vehicle v12 = new Vehicle(2,66,1,"Lamborghini10","Gallardo10",2007,"AB0000");
		database.addVehicle(v12);
		
		log.info("Printing Vehicle List from Registry before deleting the Vehicle:\n\n");
		database.printVehicleList(); // Print all the Vehicles in the Registry 	

		database.removeVehicle(); // Remove Vehicle from Registry
		log.info("Printing Vehicle List from Registry after deleting the Vehicle:\n\n");

		database.printVehicleList(); // Print all the Vehicles in the Registry after deleting the recent Vehicle entry
		database.getVehicleFromMap(v1.licensePlate); // Retrieve the 1st and 3rd Vehicle from HashMap using its license Plate
		database.getVehicleFromMap(v3.licensePlate);

		log.info("Printing Unsorted Vehicle List from Registry:\n\n");
		database.printVehicleList(); //Print the Sorted Vehicle

		// Call the Bubble sort method to sort the vehicles on the basis of LicensePlate		
		database.bubbleSort();
		log.info("Printing Sorted Vehicle list\n");
		database.printVehicleList(); //Print the Sorted Vehicle
		
	}	
	
	public void addVehicle(Vehicle vehicle) {
		vehicleList.add(vehicle) ;
		//System.out.println("Vehicle to be added:\n\n" + vehicle);
		log.info("Vehicle to be added in the registry is :\n\n" + vehicle);

	}
	
	public Vehicle getVehicle() {		
		Vehicle get_vehicle = vehicleList.get(vehicleList.size() -1) ;
		//System.out.println("Details of the recently added Vehicle (Output from 'get' command):\n\n"+ get_vehicle);
		log.info("Details of the recently added Vehicle (Output from 'get' command):\n\n"+ get_vehicle);
		return get_vehicle ;

	}

	public void removeVehicle() {
		Vehicle del_vehicle = getVehicle() ;
		vehicleList.remove(vehicleList.size() -1) ;		
		//System.out.println("Recent/Latest Vehicle Removed Succesfully! Deleted Vehicle:\n\n" + del_vehicle);
		log.info("Recent/Latest Vehicle Removed Succesfully! Deleted Vehicle:\n\n" + del_vehicle);

	}	
	
	public void printVehicleList() {
		//System.out.println("***********Vehicle List from Registry**********\n");
		log.info("***********Vehicle List from Registry**********\n");
		for(int i=0 ; i<vehicleList.size() ; i++) {
			System.out.println(vehicleList.get(i));
		}
		System.out.println("******************************************");

	}
	
	public void addVehicleToMap(String licensePlate , Vehicle vehicle) {
		vehicleMap.put(vehicle.licensePlate, vehicle) ;
		log.info("Vehicle added to HashMap is :\n\n"+ vehicle);

	}
	
	public Vehicle getVehicleFromMap(String licensePlate) {
		Vehicle vehicleFrommap = vehicleMap.get(licensePlate);
		//System.out.println("Vehicle retrieved from HashMap:\n\n"+ vehicleFrommap);
		log.info("Vehicle retrieved from HashMap:\n\n"+ vehicleFrommap);

		return vehicleFrommap;	
		
	}

	public void bubbleSort() {

		log.info("Executing Bubble Sort method\n\n");		
		for (int i = 0; i < vehicleList.size(); i++) {  // Each pass pushes the highest value to the end of the list
			for (int j = 0; j < vehicleList.size() - 1; j++) { // After each pass, the number of unsorted items grows shorter
		 		Vehicle vel0 = vehicleList.get(j);
		 		Vehicle vel1 = vehicleList.get(j+1);
		 		if (vel0.licensePlate.compareTo(vel1.licensePlate) > 0) { // We found items that are out of order, so swap them
		 			Vehicle sortVeh = vehicleList.get(j);
					vehicleList.set(j, vehicleList.get(j + 1));
					vehicleList.set(j + 1, sortVeh);
		 		}
 			}
		}

	}	

	public static void writeToLogFile() throws Exception {

		String logFile = "server.log";

		int LOG_SIZE = 1000000;
		int LOG_ROTATION_COUNT = 1000000;		
		
		// Let's send all of the logging to a rotating disk file that uses stock XML formatting!
		try {

		// Create a rotating logfile handler and add it to our logger
		Handler handler2 = new FileHandler(logFile, LOG_SIZE, LOG_ROTATION_COUNT);
		Logger.getLogger("").addHandler(handler2);

		} catch (SecurityException e) { 
			log.severe("Security Exception received: " + e.getMessage());
			e.printStackTrace();
		} catch (IOException e) {
			log.severe("IO ERROR received: " + e.getMessage());
			e.printStackTrace();
		}
	}
	
}
