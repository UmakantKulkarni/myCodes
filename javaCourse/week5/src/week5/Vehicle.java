package week5;
/**
 * CSYE 6200 Vehicle starter class
 * 
 * @author Umakant Kulkarni
 * ID: 001685850
 *
 */
import java.util.ArrayList;
public class Vehicle implements Comparable<Vehicle> {
   
	private final String license;

	public Vehicle (String license) {
		this.license = license;
	}

	public String toString(){
		return ("Vehicle :" + license);
	}

	@Override
	public int compareTo(Vehicle veh){
		return license.compareTo(veh.license);
	}

}