package assignment2;
/**
 * CSYE 6200 Vehicle Registry class
 * 
 * @author Umakant Kulkarni
 * ID: 001685850
 *
 */
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class VehicleRegistry {

	private List<Vehicle> vehicleList = new ArrayList<Vehicle>() ;
	private Map<String,Vehicle> vehicleMap = new HashMap<String,Vehicle>() ;

	public VehicleRegistry() {
				
	}

	public static void main(String[] args) {
		
		VehicleRegistry database = new VehicleRegistry();
		
		//Add 3 new vehicles ; Use get to read the Data and store it to hashmap

		Vehicle v1 = new Vehicle(4, 35, 19, "Maruti", "800", 1983, "KLU 287");
		database.addVehicle(v1);
		database.addVehicleToMap(v1.licensePlate,v1);
		database.getVehicle();

		Vehicle v2 = new Vehicle();
		database.addVehicle(v2);
		database.addVehicleToMap(v2.licensePlate,v2);
		database.getVehicle();

		Vehicle v3 = new Vehicle(2,48,5,"Lamborghini","Gallardo",2010,"VB6 999");
		database.addVehicle(v3);
		database.addVehicleToMap(v3.licensePlate,v3);
		
		database.printVehicleList(); // Print all the Vehicles in the Registry 
		database.removeVehicle(); // Remove Vehicle from Registry
		database.printVehicleList(); // Print all the Vehicles in the Registry after deleting the recent Vehicle entry
		database.getVehicleFromMap(v1.licensePlate); // Retrieve the 1st and 3rd Vehicle from HashMap using its license Plate
		database.getVehicleFromMap(v3.licensePlate);
	}	
	
	public void addVehicle(Vehicle vehicle) {
		vehicleList.add(vehicle) ;
		System.out.println("Vehicle to be added:\n\n" + vehicle);
	}
	
	public Vehicle getVehicle() {
		//return vehicleList.get(vehicleList.size() -1) ;
		Vehicle get_vehicle = vehicleList.get(vehicleList.size() -1) ;
		System.out.println("Details of the recently added Vehicle (Output from 'get' command):\n\n"+ get_vehicle);
		return get_vehicle ;
	}

	public void removeVehicle() {
		Vehicle del_vehicle = getVehicle() ;
		vehicleList.remove(vehicleList.size() -1) ;		
		System.out.println("Recent/Latest Vehicle Removed Succesfully! Deleted Vehicle:\n\n" + del_vehicle);
	}	
	
	public void printVehicleList() {
		System.out.println("***********Vehicle List from Registry**********");
		for(int i=0 ; i<vehicleList.size() ; i++) {
			System.out.println(vehicleList.get(i));
		}
		System.out.println("******************************************");
	}
	
	public void addVehicleToMap(String licensePlate , Vehicle vehicle) {
		vehicleMap.put(vehicle.licensePlate, vehicle) ;
						
	}
	
	public Vehicle getVehicleFromMap(String licensePlate) {
		Vehicle vehicleFrommap = vehicleMap.get(licensePlate);
		System.out.println("Vehicle retrieved from HashMap:\n\n"+ vehicleFrommap);
		return vehicleFrommap;
		
	}
	

}
