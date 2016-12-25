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
public class MyThreadTest {
    
    private MyThread threadA = null;
    private MyThread threadB = null;
    private MyThread threadC = null;
    private MyThread threadD = null;
    
    public MyThreadTest(){
        threadA = new MyThread("A");
        threadB = new MyThread("B");
        threadC = new MyThread("C");
        threadD = new MyThread("D");
    }
    
    
    public void run(){
        threadA.setPriority(Thread.MAX_PRIORITY);
        threadB.setPriority(Thread.NORM_PRIORITY);
        threadC.setPriority(Thread.NORM_PRIORITY);
        threadD.setPriority(Thread.MIN_PRIORITY);
        
        threadA.start(); // Turn the thread loose
        threadB.start(); // Turn the thread loose
        threadC.start(); // Turn the thread loose
        threadD.start(); // Turn the thread loose
    }
    
    public static void main(String[] args){
    MyThreadTest mtt = new MyThreadTest();
    mtt.run();
    System.out.println("Main is Done...");
    
    }
}
    
