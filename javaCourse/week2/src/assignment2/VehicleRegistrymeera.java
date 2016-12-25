package assignment2;
import java.util.ArrayList;
import java.util.HashMap;

/**
 * Class used for vehicle registry
 * @author Meera Sudhakar
 * ID: 001951332
 */
public class VehicleRegistry {
	private ArrayList<Vehicle> vehicleList = new ArrayList<Vehicle>();
	private HashMap<String,Vehicle> vehicleHash = new HashMap();

	/**
	 * Constructor
	 */
	public VehicleRegistry() {
		// TODO Auto-generated constructor stub
		
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		VehicleRegistry test = new VehicleRegistry();
		
		// Create three new vehicles and add them to the arrayList and the hashMap
		Vehicle v1 = new Vehicle(13, 60, 16.5, "Toyota", "SE", 2016, "ABC333");
		test.addVehicleToArrayList(v1);
		test.addVehicleToHashMap(v1);
		Vehicle v2 = new Vehicle();
		test.addVehicleToArrayList(v2);
		test.addVehicleToHashMap(v2);
		Vehicle v3 = new Vehicle();
		test.addVehicleToArrayList(v3);
		test.addVehicleToHashMap(v3);
		
		// Call the various methods on the arrayList
		test.getVehicleFromArrayList(0);
		test.getVehicleFromArrayList(1);
		test.getVehicleFromArrayList(2);
		test.removeVehicleFromArrayList(v2);
		test.displayVehicleContentsInArrayList();
		
		// Call the retrieve method on the hashMap
		test.retrieveVehicleFromHashMap(v1.licensePlate);
		test.retrieveVehicleFromHashMap(v3.licensePlate);
	}
	
	/**
	 * Method to add a vehicle to the arrayList
	 * @param v (object to be added to the list)
	 */
	public void addVehicleToArrayList(Vehicle v) {
		vehicleList.add(v);
		System.out.println("Vehicle being added to the list is: \n" + v);
	}
	
	/**
	 * Method to get a vehicle from the arrayList
	 * @param index (index of the object in the list)
	 */
	public void getVehicleFromArrayList(int index) {
		System.out.println("Details of the Vehicle with index " + index + " are: \n"+ vehicleList.get(index));
	}
	
	/**
	 * Method to remove a vehicle from the arrayList
	 * @param v (object to be removed from the list)
	 */
	public void removeVehicleFromArrayList(Vehicle v) {
		vehicleList.remove(v);
		System.out.println("Vehicle removed from the list is: \n" + v);
	}
	
	/**
	 * Method to display the contents of the arrayList
	 */
	public void displayVehicleContentsInArrayList() {
		System.out.println("\n-----DETAILS OF ALL VEHICLES IN THE LIST-----\n");
		for (Vehicle v: vehicleList) {
			System.out.println(v);
		}
	}
	
	/**
	 * Method to add a vehicle to the hashmap
	 * @param v (object to be added to the hash)
	 */
	public void addVehicleToHashMap(Vehicle v){
		vehicleHash.put(v.licensePlate, v);
	}
	
	/**
	 * Method to retrieve a vehicle from the hashmap using the license plate
	 * @param licensePlate (retrieve from the hashMap by the license plate)
	 */
	public void retrieveVehicleFromHashMap(String licensePlate) {
		Vehicle v = vehicleHash.get(licensePlate);
		System.out.println("The vehicle retrieved from the hashmap is:\n" + v);
	}

}
