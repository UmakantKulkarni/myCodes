/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaapplication4;

/**
 *
 * @author GAJANAN
 */
public class MyThread extends Thread {
    
    private boolean done = false;
    private int ctr = 0;
    
    public MyThread (String name){
        super(name);
    }
    
    public void run(){
        while(!done){
            doWork();
            System.out.println("Thread " + getName() + " - loop#" + ctr++);
        }
    }
    
    private void doWork(){
    for (int i = 0; i < 10000; i++){
        Math.exp(i);
    }
    }
    
}
