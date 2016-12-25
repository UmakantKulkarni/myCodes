/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package javaapplication7;

/**
 *
 * @author GAJANAN
 */
public class ThreadTest {
    
    private MyRunnable myRunA = null;
    private Thread threadA = null;
    
    private MyRunnable myRunB = null;
    private Thread threadB = null;
    
    public ThreadTest(){
        
        myRunA = new MyRunnable("A");
        threadA = new Thread(myRunA);        
        
        myRunB = new MyRunnable("B");
        threadB = new Thread(myRunA);        
    }
    
    public void begin(){
        threadA.start();
        threadB.start();
    }
    
    public static void main(String[] args){
    
        ThreadTest ttest = new ThreadTest();
        ttest.begin();
        System.out.println("ThreadTest main is Done....");
    }
    
}
