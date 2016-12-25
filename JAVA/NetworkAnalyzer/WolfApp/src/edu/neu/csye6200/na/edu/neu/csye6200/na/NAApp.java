/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package edu.neu.csye6200.na;

/**
 *
 * @author Umakant
 */
import javax.swing.JFrame;
import javax.swing.JPanel;
import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.Container;
import java.awt.event.ActionListener;
import org.pcap4j.core.PcapNativeException;

public abstract class NAApp implements ActionListener {
	
    public static JFrame frame = new JFrame();
    
    public NAApp() throws InterruptedException, PcapNativeException {
        initGUI();
    }
    
    public void initGUI() throws InterruptedException, PcapNativeException {                
        frame.setResizable(true);
        Container content = frame.getContentPane();
        content.setBackground(Color.darkGray);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setLayout(new BorderLayout());
        frame.add(getNorthPanel(),BorderLayout.NORTH);
        frame.add(getCliPanel(),BorderLayout.CENTER);
        JFrame.setDefaultLookAndFeelDecorated(true);
        frame.setVisible(true);
        
    }
    
    public abstract JPanel getCliPanel() throws InterruptedException, PcapNativeException ;
    public abstract JPanel getNorthPanel() ;

}
