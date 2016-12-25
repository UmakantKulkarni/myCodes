

#include <18F4520.H>
#device ADC=10
#use delay(clock=4000000)
#fuses HS,NOLVP,NOWDT,PUT,PROTECT

#use i2c(Master,Fast,sda=PIN_C4,scl=PIN_C3)

long int adc_data=0;
unsigned int dac_data=0;
byte up=0;

BYTE read_pcf8591(BYTE address)
{

   BYTE data;

   i2c_start();
   i2c_write(0x90);
   i2c_write(address);
   i2c_start();
   i2c_write(0x91);
   data=i2c_read(0);
   i2c_stop();
   return(data);
}




void write_pcf8591(BYTE data)
{
   i2c_start();
   i2c_write(0x90);
   i2c_write(0x40);
   i2c_write(data);
   i2c_stop();
}





init()
{
	output_c(0x00);
   output_D(0x00);
   



}



void main()

{

 
  
 dac_data=0;
 up=0;
do{
  
    adc_data=read_pcf8591(0x00);
  output_D(adc_data);
}while(1);
}










