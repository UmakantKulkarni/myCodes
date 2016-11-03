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

import java.io.*;
import java.util.ArrayList;

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
			System.err.println("We caught an error… finally1\n");
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
			System.err.println("We caught an error… finally2\n");
		}

	}

	public void load(String filename) throws Exception {
		 
		try {
			FileReader fr = new FileReader(filename);
			BufferedReader in = new BufferedReader(fr);
			String str;
			while ((str = in.readLine()) != null) {
				System.out.println("> " + str);
			}
			in.close();
		} catch(IOException ex) {
			System.err.println("IO ERROR received: " + ex.getMessage());
			ex.printStackTrace();
		} catch (Exception ex) {
			System.err.println("Exception received: " + ex.getMessage());
			ex.printStackTrace(); // just print the trace
		} finally {
			System.err.println("We caught an error… finally3\n");
		}

	}

}