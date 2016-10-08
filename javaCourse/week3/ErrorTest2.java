public class ErrorTest2 {
	
	public void makeError() throws Exception {

		throw new Exception("I have an error");
		//ex.printStackTrace();

	}

	public void dealWithIt() {
		try {
			makeError();	
		} catch (Exception ex) {
			ex.printStackTrace();
		}		

	}

	public static void main(String[] args) {

		ErrorTest2 et = new ErrorTest2();
		et.dealWithIt();

	}

}