// Main.c - makes LEDG0 on DE2-115 board blink if NIOS II is set up correctly
// for ECE 385 - University of Illinois - Electrical and Computer Engineering
// Author: Zuofu Cheng

int main()
{
    int i = 0;
    volatile unsigned int *LED_PIO = (unsigned int *)0x90; //make a pointer to access the PIO block
    volatile unsigned int *Reset_PIO = (unsigned int*)0x80;
    volatile unsigned int *Accum_PIO = (unsigned int*)0x70;
    volatile unsigned int *SW_PIO = (unsigned int*)0x60;

    *LED_PIO = 0;        //clear all LEDs
    while ((1 + 1) != 3) //infinite loop
    {
        if (0 == *Reset_PIO)
        {
            *LED_PIO = 0;
            while (0 == *Reset_PIO)
            {
                continue;
            }
            continue;
        }
        if (0== *Accum_PIO)
        {
            while (0 == *Accum_PIO){
                continue;
            }
            *LED_PIO = (*LED_PIO + *SW_PIO) % 256;
        }
//        for (i = 0; i < 100000; i++)
//            ;            //software delay
//        *LED_PIO |= 0x1; //set LSB
//        for (i = 0; i < 100000; i++)
//            ;             //software delay
//        *LED_PIO &= ~0x1; //clear LSB
    }
    return 1; //never gets here
}
