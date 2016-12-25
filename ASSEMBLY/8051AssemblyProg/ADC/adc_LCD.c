

#include <18F4525.H>
#device ADC=10
#use delay(clock=4000000)
#fuses HS,NOLVP,NOWDT,PUT,PROTECT

#use i2c(Master,Fast,sda=PIN_C4,scl=PIN_C3)
//#use rs232(baud=9600,xmit=pin_c6,rcv=pin_c7)

#include <LCD4X20 logsun.c>


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
   

  lcd_init();

}



void main()

{

  init();
  printf(lcd_putc,"\f****WEL-COME****");
  printf(lcd_putc,"\n LOGSUN SYSEM,PUNE ");

  delay_ms(5000);

  printf(lcd_putc,"\fA-D CONVERTER");
  printf(lcd_putc,"\nCH 0:%X",adc_data);
 dac_data=0;
 up=0;
do{
   lcd_gotoxy(6,2);
	printf(lcd_putc,"%X",adc_data);
    adc_data=read_pcf8591(0x00);
  output_B(adc_data);
}while(1);
}










