package assignment3;
/**
 * CSYE 6200 Assignment #3 
 */

/**
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


public class RegistryIO {

	public static void main(String[] args) throws Exception {

		Vehicle v1 = new Vehicle(4, 35, 19, "Maruti", "800", 1983,"KLU 287");
		Vehicle v2 = new Vehicle();
		Vehicle v3 = new Vehicle(2,48,5,"Lamborghini","Gallardo",2010,"VB6 999");
		TruckVehicle newTruck = new TruckVehicle(2, 462, 3.44, "Mercedes", "FuelDuel", 2016, "GER 514", 1.50, 2.75, 4.00);	

		VehicleRegistry vehicleReg = new VehicleRegistry();
		vehicleReg.addVehicle(v1);
		vehicleReg.addVehicle(v2);
		vehicleReg.addVehicle(newTruck);

		RegistryIO RegIo = new RegistryIO();
		RegIo.save(vehicleReg.vehicleList,"file.txt");
		RegIo.save(v3,"file.txt");
		RegIo.load("file.txt");

	}

	public void save(ArrayList<Vehicle> vehicles, String filename) throws Exception {
		 
		try {
			FileWriter fw = new FileWriter(filename);
			for (Vehicle vehicle : vehicles) {
				String vehicleInfo = vehicle.toString();
				fw.write(vehicleInfo);
			}
			fw.close();
		} catch (IOException ex) {
			System.err.println("IO ERROR received: " + ex.getMessage());
			ex.printStackTrace();
		} catch (Exception ex) {
			System.err.println("Exception received: " + ex.getMessage());
			ex.printStackTrace(); // just print the trace
		} finally {
			System.out.println("We caught an error… finally (At Public Save method)\n");
		}

	}

	private void save(Vehicle vehicle, String filename) throws Exception {
		 
		try {
			FileWriter fw = new FileWriter(filename, true);
			String vehicleInfo = vehicle.toString();
			fw.write(vehicleInfo);
			fw.close();
		} catch(IOException ex) {
			System.err.println("IO ERROR received: " + ex.getMessage());
			ex.printStackTrace();
		} catch (Exception ex) {
			System.err.println("Exception received: " + ex.getMessage());
			ex.printStackTrace(); // just print the trace
		} finally {
			System.out.println("We caught an error… finally (At Private Save method)\n");
		}

	}

	public void load(String filename) throws Exception {
		 
		Map<String,String> vehicleFieldValueMap = new HashMap<String,String>() ;

		try {
			FileReader fr = new FileReader(filename);
			BufferedReader in = new BufferedReader(fr);
			String str;
			String[] tempStr ;

			System.out.println("Contents of the File: \n");
			//Read the contents of the file
			while ((str = in.readLine()) != null) {

				System.out.println("> " + str);
				tempStr =  str.split("=") ;
				if(tempStr.length > 1)
				{	
					vehicleFieldValueMap.put(tempStr[0].trim(), tempStr[1].trim()); // Store the Entire String to the Map
				}			
				
			}
			System.out.println("\n************End of the File************ \n");

			//Create a new object as vehicle3
			Vehicle vehicle3 = new Vehicle() ;

			//Parse or trim the data/String and save the values of the keys to the vehicle class
			vehicle3.passengers = Integer.parseInt(vehicleFieldValueMap.get("Passenger Capacity")) ;
			vehicle3.fuelCap = Integer.parseInt(vehicleFieldValueMap.get("Fuel Capacity")) ;
			vehicle3.kpl = Double.parseDouble(vehicleFieldValueMap.get("Kilometers Per Litre")) ;
			vehicle3.make = vehicleFieldValueMap.get("Make") ;
			vehicle3.model = vehicleFieldValueMap.get("Model") ;
			vehicle3.modelYear = Integer.parseInt(vehicleFieldValueMap.get("Model Year")) ;
			vehicle3.licensePlate = vehicleFieldValueMap.get("License Plate Number") ;
			
			//Print the data that has beed read by load() function  from the save() function
			System.out.println("\nOutout for the BONUS Part - Data that has beed read using load() function from the save() function and stored into new Vehicle class:\n\n" + vehicle3);
			in.close();

		} catch(IOException ex) {
			System.err.println("IO ERROR received: " + ex.getMessage());
			ex.printStackTrace();
		} catch (Exception ex) {
			System.err.println("Exception received: " + ex.getMessage());
			ex.printStackTrace(); // just print the trace
		} finally {
			System.out.println("We caught an error… finally (At Load method)\n");
		}

	}

}