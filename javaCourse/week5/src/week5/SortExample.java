package week5;

public class SortExample {

	String data[] = {"XYZ-009", "WRX-009", "ABC-343", "ABC-532", "AAT-654", "GKL-867", "LKJ237", "POI7654", "QEW132"};

	public SortExample() {
	}

	public void sort(){
		
		int chkCounter = 0;
		boolean changed;
		for (int j = 0 ; j < data.length-1; j++ ){
			changed = false;
			for (int i = 0 ; i < data.length-(j+1); i++ ){
				chkCounter++;
				if (data[i].compareTo(data[i+1]) < 0){
					String temp = data[i];
					data[i]=data[i+1];
					data[i+1] = temp;
					changed = true;

				}

			}
			if (!changed) break;
		}
		System.out.println("Couter :\n"+ chkCounter);
	}

	public void displayList (){

		for (String licStr : data){
			System.out.println(">" + licStr);
		}

	}

	public static void main(String[] args) {

		SortExample se = new SortExample();
		se.displayList();
		se.sort();
		se.displayList();

	}

}