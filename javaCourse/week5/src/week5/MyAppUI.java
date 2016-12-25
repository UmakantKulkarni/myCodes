package week5;

import java.util.logging.Logger;
import java.util.logging.Level;
import javax.swing.JFrame;
import javax.*;
import java.awt.BorderLayout;
import java.*;

public class MyAppUI{

	private Logger log = Logger.getLogger(MyAppUI.class.getName());

	private JFrame frame = null;
	private JPanel mainPanel = null;

	public MyAppUI(){
		log.info("App started");
		initGUI();

	}

	private void initGUI(){
		frame = new JFrame();
		frame.setTitle("MyAppUI");
		frame.setSize(400, 300);
		frame.setResizable(true);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setLayout(new BorderLayout());
		frame.add(getMainPanel(),BorderLayout.NORTH);
		frame.setVisible(true);

	}

	public JPanel getMainPanel(){
		mainPanel = new JPanel();
		mainPanel.setLayout(new FlowLayout());
		JButtun btn0 = new JButtun("Start");
		JButtun btn1 = new JButtun("Stop");
		mainPanel.add(btn0);
		mainPanel.add(btn1);
		return mainPanel;
	}


	public static void main(String[] args){
		MyAppUI myapp = new MyAppUI();
	}
}