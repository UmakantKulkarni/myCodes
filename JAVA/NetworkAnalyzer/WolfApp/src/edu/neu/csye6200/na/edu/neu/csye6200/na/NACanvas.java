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

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import javax.swing.JPanel;


public class NACanvas extends JPanel{

    int s; 
    int[] h = new int[17];

    public NACanvas(int[] Height){  
        //s = Shifting;
        h = Height;
    }
    
    @Override
    public void paint(Graphics g){
        
        int[] k = new int[17];
        
        for (int i = 0;i<17;i++){
                k[i]=h[i];
        }
        
        if ( h[13] >= 500 ){
            
            int c = h[13];
            int p = h[13]/500;
            h[13] = h[13]- (p*500);       
            
            for (int i = 0;i<13;i++){
                h[i]=(h[i]*h[13])/c;
            }            
            for (int i = 14;i<17;i++){
                h[i]=(h[i]*h[13])/c;
            }            
        }
        
        super.paint(g);
        g.setColor(Color.darkGray);
        g.fillRect(0, 0, getWidth(), getHeight());
        s = (getWidth()/22);
        
        g.setFont(new Font("Serif", Font.BOLD, 15));
        g.setColor(Color.white);
        g.drawString("No. of Packets/Protocol",3*s,20);
        g.drawString("Packet Size/Protocol",12*s,20);
        g.drawString("Overall packet Statistics",18*s,20);
        
        g.setColor(Color.red);
        g.fillRect(s, getHeight()-30-h[2], s/2, h[2]);
        g.drawString("TCP",s,getHeight()-15);
        g.drawString(Integer.toString(k[2]),s,getHeight()-h[2]-35);
        
        g.setColor(Color.green);
        g.fillRect(2*s, getHeight()-30-h[1], s/2, h[1]);
        g.drawString("UDP",s*2,getHeight()-15);
        g.drawString(Integer.toString(k[1]),s*2,getHeight()-h[1]-35);
        
        g.setColor(Color.blue);
        g.fillRect(3*s, getHeight()-30-h[3], s/2, h[3]);
        g.drawString("ICMP",s*3,getHeight()-15);
        g.drawString(Integer.toString(k[3]),s*3,getHeight()-h[3]-35);
        
        g.setColor(Color.orange);
        g.fillRect(4*s, getHeight()-30-h[4], s/2, h[4]);
        g.drawString("HTTP",s*4,getHeight()-15);
        g.drawString(Integer.toString(k[4]),s*4,getHeight()-h[4]-35);
        
        g.setColor(Color.black  );
        g.fillRect(5*s, getHeight()-30-h[5], s/2, h[5]);
        g.drawString("RA",s*5,getHeight()-15);
        g.drawString(Integer.toString(k[5]),s*5,getHeight()-h[5]-35);
        
        g.setColor(Color.magenta);
        g.fillRect(6*s, getHeight()-30-h[6], s/2, h[6]);
        g.drawString("Other",s*6,getHeight()-15);
        g.drawString(Integer.toString(k[6]),s*6,getHeight()-h[6]-35);
        
        g.setColor(Color.pink);
        g.fillRect(7*s, getHeight()-30-h[0], s/2, h[0]);
        g.drawString("Total",s*7,getHeight()-15);
        g.drawString(Integer.toString(k[0]),s*7,getHeight()-h[0]-35);
        
        g.setColor(Color.white);
        g.drawLine(s*9, 0, s*9, getHeight());
        
        g.setColor(Color.red);
        g.fillRect(s*10, getHeight()-30-h[9], s/2, h[9]);
        g.drawString("TCP",s*10,getHeight()-15);
        g.drawString(Integer.toString(k[9]),s*10,getHeight()-h[9]-35);
        
        g.setColor(Color.green);
        g.fillRect(11*s, getHeight()-30-h[10], s/2, h[10]);
        g.drawString("UDP",s*11,getHeight()-15);
        g.drawString(Integer.toString(k[10]),s*11,getHeight()-h[10]-35);
        
        g.setColor(Color.blue);
        g.fillRect(12*s, getHeight()-30-h[8], s/2, h[8]);
        g.drawString("ICMP",s*12,getHeight()-15);
        g.drawString(Integer.toString(k[8]),s*12,getHeight()-h[8]-35);
        
        g.setColor(Color.orange);
        g.fillRect(13*s, getHeight()-30-h[7], s/2, h[7]);
        g.drawString("HTTP",s*13,getHeight()-15);
        g.drawString(Integer.toString(k[7]),s*13,getHeight()-h[7]-35);
        
        g.setColor(Color.black  );
        g.fillRect(14*s, getHeight()-30-h[11], s/2, h[11]);
        g.drawString("Other",s*14,getHeight()-15);
        g.drawString(Integer.toString(k[11]),s*14,getHeight()-h[11]-35);
        
        g.setColor(Color.magenta);
        g.fillRect(15*s, getHeight()-30-h[12], s/2, h[12]);
        g.drawString("Total",s*15,getHeight()-15);
        g.drawString(Integer.toString(k[12]),s*15,getHeight()-h[12]-35);
        
        g.setColor(Color.white);
        g.drawLine(s*17, 0, s*17, getHeight());
        
        g.setColor(Color.red);
        g.fillRect(18*s, getHeight()-30-h[13], s/2, h[13]);
        g.drawString("PR",s*18,getHeight()-15);
        g.drawString(Integer.toString(k[13]),s*18,getHeight()-h[13]-35);
        
        g.setColor(Color.blue);
        g.fillRect(19*s, getHeight()-30-h[14], s/2, h[14]);
        g.drawString("PD",s*19,getHeight()-15);
        g.drawString(Integer.toString(k[14]),s*19,getHeight()-h[14]-35);
        
        g.setColor(Color.green);
        g.fillRect(20*s, getHeight()-30-h[15], s/2, h[15]);
        g.drawString("NP",s*20,getHeight()-15);
        g.drawString(Integer.toString(k[15]),s*20,getHeight()-h[15]-35);
        
        g.setColor(Color.orange);
        g.fillRect(21*s, getHeight()-30-h[16], s/2, h[16]);
        g.drawString("PC",s*21,getHeight()-15);
        g.drawString(Integer.toString(k[16]),s*21,getHeight()-h[16]-35);
        
    }
}