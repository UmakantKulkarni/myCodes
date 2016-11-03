/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaapplication7;

import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author GAJANAN
 */
public class MyRunnable implements Runnable{
    
    private boolean done = false;
    private int ctr = 0;
    private String name;
    private int total = 0;
    
    public MyRunnable(String name){
        this.name = name;
    }
    
    @Override
    public void run() {
        while(!done){
            total =0;
            try {
                total = func(50);
            } catch (InterruptedException ex) {
                Logger.getLogger(MyRunnable.class.getName()).log(Level.SEVERE, null, ex);
            }
            System.out.println("Runnable " + name + " - " + ctr++  + " Total: " + total);
        }
    }
    
    //Synchronized a thread unsafe method
    private synchronized int func (int n) throws InterruptedException{
        int value = 0;
        for (int i =0; i < 100; i++){
            Math.atan(0.3456);
            value++;
        }
        Thread.sleep(5L);
        
        for (int i = 0; i < n; i++){
            Math.atan(0.5567);
            value++;
        }
            
        return value;
    }
    
}
