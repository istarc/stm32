/** 
  *  Description: Toogle LED Assembly Routine
  *  Target: STM32F4 Discovery Board
  *
  *  The GPIO device that drives LEDs is computed as follows:
  *
  *  PERIPH_BASE = 0x40000000
  *  AHB1PERIPH_BASE = PERIPH_BASE + 0x00020000
  *  GPIOD_BASE = AHB1PERIPH_BASE + 0x0C00
  *  GPIOD = GPIOD_BASE + 0x14 (GPIO port output data register) = 0x40020C14
  *
  *  The GPIO values to toggle individual LEDs are the following:
  *
  *  LED1: Pin 12 | LED2: Pin 13 | LED3: Pin 14 | LED4: Pin 15 | All LEDs
  *  0x1000       | 0x2000       | 0x4000       | 0x8000       | 0xF000
  *
  */
	.syntax unified
	.cpu cortex-m4
	.thumb

	.section  .text.toggle
  	.weak  toggle
	.type  toggle, %function

toggle:
    push {r0,r1} 	@ Save r0, r1 onto stack
    ldr r0,=0x40020C14	@ Load GPIOD address
    ldr r1,[r0]		@ Load GPIOD status at GPIOD address [ro] and store to r1
    eor r1,r1,#0xF000	@ XOR GPIOD status (only Pins 12,13,14,15) and store to r1
    str r1,[r0]		@ Store new status r1 to GPIOD address [ro]
    pop {r0,r1}		@ Restore r0, r1 from stack
    bx lr		@ Return from function call
