#include "MKL46Z4.h"

// LED (RG)
// LED_GREEN = PTD5
// LED_RED = PTE29

// LED_GREEN = PTD5
void led_green_init()
{
  SIM->COPC = 0;
  SIM->SCGC5 |= SIM_SCGC5_PORTD_MASK;
  PORTD->PCR[5] = PORT_PCR_MUX(1);
  GPIOD->PDDR |= (1 << 5);
  GPIOD->PSOR = (1 << 5);
}

// LED_RED = PTE29
void led_red_init()
{
  SIM->COPC = 0;
  SIM->SCGC5 |= SIM_SCGC5_PORTE_MASK;
  PORTE->PCR[29] = PORT_PCR_MUX(1);
  GPIOE->PDDR |= (1 << 29);
  GPIOE->PSOR = (1 << 29);
}

void Green_LED_On(void)
{
  GPIOD->PCOR = (1u << 5);
}

void Red_LED_On(void)
{
  GPIOE->PCOR = (1u << 29);
}

void Green_LED_Off(void)
{
  GPIOD->PSOR = (1u << 5);
}

void Red_LED_Off(void)
{
  GPIOE->PSOR = (1u << 29);
}

void sw1_button_init(void)
{
  SIM->SCGC5 |= SIM_SCGC5_PORTC_MASK;
  PORTC->PCR[3] = PORT_PCR_MUX(1) | PORT_PCR_PE(1) | PORT_PCR_PS(1); // set port c pin 3 as GPIO, Pull enable and select
  GPIOC->PDDR &= ~(1 << 3);                                          // set port c pin 3 as input
}

void sw2_button_init(void)
{
  SIM->SCGC5 |= SIM_SCGC5_PORTC_MASK;
  PORTC->PCR[12] = PORT_PCR_MUX(1) | PORT_PCR_PE(1) | PORT_PCR_PS(1); // set port c pin 12 as GPIO, Pull enable and select
  GPIOC->PDDR &= ~(1 << 12);
}

int check_SW1(void)
{ // returns 1 if SW1 is pressed and 0 if switch is not pressed
  if ((0x00000008 & PTC->PDIR) == 0x00000008)
  {
    return 0;
  }
  else
  {
    return 1;
  }
}

int check_SW2(void)
{ // returns 1 if SW2 is pressed and 0 if switch is not pressed
  if ((0x00001000 & PTC->PDIR) == 0x00001000)
  {
    return 0;
  }
  else
  {
    return 1;
  }
}

int main(void)
{
  led_green_init();
  led_red_init();
  sw1_button_init();
  sw2_button_init();
  Green_LED_On();
  int sw1_state = 0;
  int sw2_state = 0;
  int sw1_count = 0;
  int sw2_count = 0;

  while (1)
  {
       
      if (check_SW1()) // SW1 se ha pulsado
      { 
        sw1_count++;
        if (sw1_count == 2)
        {
          sw1_state = !sw1_state;
          sw1_count = 0;
        }
        while (check_SW1()); // Esperar a que el botón se deje de pulsar
      }

      if (check_SW2()) // SW2 se ha pulsado
      { 
        sw2_count++;
        if (sw2_count == 2)
        {
          sw2_state = !sw2_state;
          sw2_count = 0;
        }
        while (check_SW2());
      }
      
      if (sw1_state == 0 && sw2_state == 0) // Si ambas puertas están cerradas
      {
        Green_LED_On(); // Encender LED verde
        Red_LED_Off();  // Apagar LED rojo
        sw1_count = 1;
        sw2_count = 1;
      }
      else   // Si alguna o ambas puertas están abiertas
      {                  
        Red_LED_On();    // Encender LED rojo
        Green_LED_Off(); // Apagar LED verde
      }
    }

    return 0;
  }
