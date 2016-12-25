

#include <18F4520.H>
#use delay(clock=12000000)
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
  
  init();
  dac_data=0;
 up=0;
do
{


//******** FOR DAC CONVERSION****************************

    if(dac_data<=250 && up==0)
	dac_data++;
	else
	{
	up=1; 
	if(dac_data<=2)
	up=0;
    else
    dac_data--; 
    }
	write_pcf8591(dac_data);
	//delay_ms(100);

 

}
while(1);
}






           
		











