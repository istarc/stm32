/* Includes ------------------------------------------------------------------*/
#include "mbed.h"
/* Defines ------ ------------------------------------------------------------*/
/**
  * CHOOSE ONE
  */
//#define DEFAULT_TOGGLE /* Use default mbed implementation main.c:38*/
#define ASSEMBLY_TOGGLE /* Use pure assembly implementation toggle.s */
//define INLINE_ASSEMBLY_TOGGLE /* Use inline assembly implementation main.c:45 */

/**
  * CHOOSE ONE
  */
//#define DEFAULT_DELAY /* Use default mbed delay implementation main.c:58 */
#define ASSEMBLY_DELAY /* Use pure assembly implementation delay.s */
//#define C_EQUIVALENT /* Use Assembly Delay C equivalent main.c:75 */

/* Macros --------------------------------------------------------------------*/
/* Global Variables ----------------------------------------------------------*/
DigitalOut myled(LED1);

/* Prototypes ----------------------------------------------------------------*/
/* Prototypes that require C linking instead of C++ */
extern "C" void delay(int);
extern "C" void toggle(void);
/* Functions -----------------------------------------------------------------*/

/**
  * @brief  Main program
  * @param  None
  * @retval None
  */
int main() {
	while(1) {

	/* Assembly: Example 1: Toggle LED */
#ifdef DEFAULT_TOGGLE
		myled = myled ^ 1;
#endif
#ifdef ASSEMBLY_TOGGLE
		toggle(); /* Use pure assembly implementation toggle.s */
#endif
#ifdef INLINE_ASSEMBLY_TOGGLE
		__asm volatile( /* Use inline assembly */
			"push {r0,r1}        \n" // Save r0, r1 onto stack
			/* Thumb does not support 32 immediates "ldr r0,=0x40020C14". */
			/* It has to be replaced by two following commands with two 16-bit immediates */
			"movw r0,#0x0C14     \n" // Store lower half of GPIOD address to r0
			"movt r0,#0x4002     \n" // Store upper half of GPIOD address to r0
			"ldr r1,[r0]         \n" // Load GPIOD status at GPIOD address [ro] and store to r1
			"eor r1,r1,#0xF000   \n" // XOR GPIOD status (only Pins 12,13,14,15) and store to r1
			"str r1,[r0]         \n" // Store new status r1 to GPIOD address [ro]
			"pop {r0,r1}         \n"); // Restore r0, r1 from stack
#endif

	/* Assembly: Example 2: Delay */
#ifdef DEFAULT_DELAY
		wait(0.2);
#endif
#ifdef ASSEMBLY_DELAY
		delay(0xFFFFFF);
#endif
#ifdef C_EQUIVALENT
		delay(0xFFFFFF);
#endif
	}
}

/**
  * @brief  delay routine (C equivalent of delay.s)
  * @param  ticks ... delay length
  * @retval None
  */
#ifdef C_EQUIVALENT
void delay(unsigned long ticks)
{
	unsigned long us = 1*ticks;
	while (us--)
	{
	__asm volatile("nop");
	}
}
#endif

