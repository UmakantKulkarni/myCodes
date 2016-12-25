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

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.FlowLayout;
import java.awt.event.ActionEvent;
import java.io.IOException;
import java.util.Arrays;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;
import org.pcap4j.core.PcapNativeException;

public class WolfApp extends NAApp {
        
    private static final Logger log = Logger.getLogger(WolfApp.class.getName());
    public static int[] x = new int[5];
    public static String[] pktSize = new String[5];
    public static Looper looper = new Looper();
    public Thread t = new Thread(looper);
    public static JPanel northPanel = new JPanel(new BorderLayout()); 
    public static JPanel CliPanel = new JPanel(new BorderLayout()); 
    public JButton btn0= null;
    public JButton btn1= null;
    public JButton btn2= null;
    public JButton btn3= null;
    public static NACanvas myCanvas;
    public static JTextField txt1 = new JTextField("5000",10);
    public static JTextField txt2 = new JTextField("5000",10);
    public static JTextField txt3 = new JTextField("5000",10);
    public static JTextField txt4 = new JTextField("5000",10);
    public static JTextField txt5 = new JTextField("0",10);
    public static JTextArea textArea = new JTextArea(38,88);
        
    /**
     * WolfApp3 constructor
     * @throws java.lang.InterruptedException
     */
    public WolfApp() throws InterruptedException, PcapNativeException {
    	frame.setTitle("WolfApp");
        frame.setSize(1000, 700);
    }
   

    @Override
    public JPanel getNorthPanel() {
        
        JPanel panSouth = new JPanel(new FlowLayout());
        JPanel panNorth = new JPanel(new FlowLayout());
        
        JPanel pan1 = new JPanel(new BorderLayout());
        JPanel pan2 = new JPanel(new BorderLayout());
        JPanel pan3 = new JPanel(new BorderLayout());
        JPanel pan4 = new JPanel(new BorderLayout());
        JPanel pan5 = new JPanel(new BorderLayout());
        
        JLabel lbl1 = new JLabel("TCP Data Limit", JLabel.CENTER);
        JLabel lbl2 = new JLabel("HTTP Data Limit", JLabel.CENTER);
        JLabel lbl3 = new JLabel("ICMP Data Limit", JLabel.CENTER);
        JLabel lbl4 = new JLabel("UDP Data Limit", JLabel.CENTER);
        JLabel lbl5 = new JLabel("NIF", JLabel.CENTER);
        
        lbl1.setForeground(Color.cyan);
        lbl2.setForeground(Color.cyan);
        lbl3.setForeground(Color.cyan);
        lbl4.setForeground(Color.cyan);
        lbl5.setForeground(Color.cyan);
        
        txt1.setBackground(Color.black);
        txt2.setBackground(Color.black);
        txt3.setBackground(Color.black);
        txt4.setBackground(Color.black);
        txt5.setBackground(Color.black);
        txt1.setForeground(Color.yellow);
        txt2.setForeground(Color.yellow);
        txt3.setForeground(Color.yellow);
        txt4.setForeground(Color.yellow);
        txt5.setForeground(Color.yellow);

        pan1.add(lbl1, BorderLayout.NORTH);
        pan1.add(txt1, BorderLayout.CENTER);
        pan2.add(lbl2, BorderLayout.NORTH);
        pan2.add(txt2, BorderLayout.CENTER);
        pan3.add(lbl3, BorderLayout.NORTH);
        pan3.add(txt3, BorderLayout.CENTER);
        pan4.add(lbl4, BorderLayout.NORTH);
        pan4.add(txt4, BorderLayout.CENTER);
        pan5.add(lbl5, BorderLayout.NORTH);
        pan5.add(txt5, BorderLayout.CENTER);
        
        northPanel.setBackground(Color.BLUE);
        pan1.setBackground(Color.BLUE);
        pan2.setBackground(Color.BLUE);
        pan3.setBackground(Color.BLUE);
        pan4.setBackground(Color.BLUE);
        pan5.setBackground(Color.BLUE);
        panSouth.setBackground(Color.BLUE);
        panNorth.setBackground(Color.blue);
                
        btn0 = new JButton("Start");
        btn0.setBackground(Color.black);
        btn0.setForeground(Color.yellow);
        btn0.addActionListener(this);
        btn1 = new JButton("Stop");
        btn1.setBackground(Color.black);
        btn1.setForeground(Color.yellow);
        btn1.addActionListener(this);
        btn2 = new JButton("Pause");
        btn2.setBackground(Color.black);
        btn2.setForeground(Color.yellow);
        btn2.addActionListener(this);
        btn3 = new JButton("Resume");
        btn3.setBackground(Color.black);
        btn3.setForeground(Color.yellow);
        btn3.addActionListener(this);
        panSouth.add(btn0);
        panSouth.add(btn1);
        panSouth.add(btn2);
        panSouth.add(btn3);
        
        panNorth.add(pan1);
        panNorth.add(pan2);
        panNorth.add(pan3);
        panNorth.add(pan4);
        panNorth.add(pan5);
       
        northPanel.add(panSouth, BorderLayout.SOUTH);
        northPanel.add(panNorth, BorderLayout.NORTH);
        
        return northPanel;
        
    }
    
    @Override
    public JPanel getCliPanel () throws InterruptedException, PcapNativeException{ 
       
            try {
                textArea.setForeground(Color.yellow);
                textArea.setBackground(Color.black);
                JScrollPane scrolltxt = new JScrollPane(textArea);
                textArea.setLineWrap(true);
                textArea.setWrapStyleWord(true);
                scrolltxt.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_AS_NEEDED);
                scrolltxt.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_AS_NEEDED);
                textArea.setText(GetPacket.showNIF());
                CliPanel.add(scrolltxt, BorderLayout.CENTER);
            } catch (IOException ex) {
                Logger.getLogger(WolfApp.class.getName()).log(Level.SEVERE, null, ex);
            }
            return CliPanel;
    }

    public static void geta (int[] a) throws InterruptedException{ 
        
        System.out.println(" Value of A is " + Arrays.toString(a));
        myCanvas = new NACanvas(a);
        frame.add(myCanvas, BorderLayout.CENTER);
        myCanvas.updateUI();             
           
    }
    
    @Override
    public void actionPerformed(ActionEvent e){
        
        log.info("We Received an Action Event" + e);
        
        try {
            x[0] = Integer.parseInt(txt1.getText());
            pktSize[0] = Integer.toString(x[0]);
        } catch (NumberFormatException nfe) {
            txt1.setText("5000");
            pktSize[0]=txt1.getText();
        }
        
        try {
            x[1] = Integer.parseInt(txt2.getText());
            pktSize[1] = Integer.toString(x[1]);
        } catch (NumberFormatException nfe) {
            txt2.setText("5000");
            pktSize[1]=txt2.getText();
        }
        
        try {
            x[2] = Integer.parseInt(txt3.getText());
            pktSize[2] = Integer.toString(x[2]);
        } catch (NumberFormatException nfe) {
            txt3.setText("5000");
            pktSize[2]=txt3.getText();
        }
        
        try {
            x[3] = Integer.parseInt(txt4.getText());
            pktSize[3] = Integer.toString(x[3]);
        } catch (NumberFormatException nfe) {
            txt4.setText("5000");
            pktSize[3]=txt4.getText();
        }
        
        try {
            x[4] = Integer.parseInt(txt5.getText());
        } catch (NumberFormatException nfe) {
            txt5.setText("1");
            x[4] = Integer.parseInt(txt5.getText());
        }
        
        txt1.setEditable(false);
        txt2.setEditable(false);
        txt3.setEditable(false);
        txt4.setEditable(false);
        txt5.setEditable(false);
        
        if(e.getActionCommand().equals("Stop")){
            t.stop();
            looper.stop();
            looper = null;
            System.exit(0);
        } else if(e.getActionCommand().equals("Start")) {
            t.start();
        } else if(e.getActionCommand().equals("Pause")) {
            t.suspend();
        } else if(e.getActionCommand().equals("Resume")) {
            t.resume();        
        }
                
    }    	
    /**
     * Wolf application starting point
     * @param args
     */
    public static void main(String[] args) {
        SwingUtilities.invokeLater(new Runnable() {
            @Override
            public void run() {
                try {
                    WolfApp wapp = new WolfApp();

                } catch (InterruptedException | PcapNativeException ex) {
                    Logger.getLogger(WolfApp.class.getName()).log(Level.SEVERE, null, ex);
                }
            }
        });
        log.info("WolfApp started");
    }        

}