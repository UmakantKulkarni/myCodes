public class ErrorTest {
	
	public void makeError() {

		Exception ex = new Exception("I have an error");
		ex.printStackTrace();

	}

	public static void main(String[] args) {

		ErrorTest et = new ErrorTest();
		et.makeError();

	}

}