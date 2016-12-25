package week5;

import java.io.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.logging.Level;
import java.util.logging.Handler;
import java.util.logging.FileHandler;


public class CollSortExample {

	//String data[] = {"XYZ-009", "WRX-009", "ABC-343", "ABC-532", "AAT-654", "GKL-867", "LKJ237", "POI7654", "QEW132"};
	private Arraylist<Vehicle> vehList = null;

	public CollSortExample(int size) {
		vehList = new Arraylist<Vehicle>(size);

		vehList.add(new Vehicle("VYZ-765"));
		vehList.add(new Vehicle("LKQ-455"));
		vehList.add(new Vehicle("BHU-731"));
		vehList.add(new Vehicle("ASE-493"));
		
	}

	public void display(){
		for (Vehicle veh : vehList){
			System.out.println("Vehicle: " + veh);
		}
	}

	public static void main(String[] args) {

		CollSortExample cse = new CollSortExample(32);
		cse.display();
		
	}

}