/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaapplication3;

import java.awt.Toolkit;
import java.util.Timer;
import java.util.TimerTask;

/**
 *
 * @author GAJANAN
 */
public class TimerDemo {
    private Timer timer;
    public TimerDemo() {
        
        timer = new Timer();
        //timer.schedule(new RemindTask(), 5000L); // five second
        
        timer.schedule(new RemindTask(), 5000L, 1000L); //periodic time=  1 second delay time = 5 sec
        //timer.schedule(new RemindTask(), 5000L, 1000L); //periodic time=  1 second delay time = 5 sec
    }
    
    class  RemindTask extends TimerTask{
        int cnt = 0;
        
        @Override
        public void run(){
            System.out.println("Timer alert" + cnt++);
            Toolkit.getDefaultToolkit().beep();
            if (cnt >= 5) timer.cancel();
        }
    
    }
    
 public static void main (String[] args){
     new TimerDemo();
     System.out.println("We are done");
 }
}
