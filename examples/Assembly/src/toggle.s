/* C prototype:
 *
 *  GPIO_ToggleBits(GPIOD,GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15);
 *  
 *  GPIOD = GPIOD_BASE + 0x14 (GPIO port output data register) = 0x40020C14
 *          GPIOD_BASE = AHB1PERIPH_BASE + 0x0C00
 *                       AHB1PERIPH_BASE = PERIPH_BASE + 0x00020000
 *                                         PERIPH_BASE = 0x40000000
 *
 * GPIO_Pin_12 | GPIO_Pin_13 | GPIO_Pin_14 | GPIO_Pin_15 =
 * 0x1000      | 0x2000      | 0x4000      | 0x8000      = 0xF000
 *
 */
	.syntax unified
	.cpu cortex-m4
	.thumb

	.section  .text.Toggle
  	.weak  Toggle
	.type  Toggle, %function

Toggle:
    push {r0,r1} 		// Save r0, r1 onto stack
    ldr r0,=0x40020C14	// Load GPIOD address
    ldr r1,[r0]			// Load GPIOD status at GPIOD address [ro] and store to r1
    eor r1,r1,#0xF000	// XOR GPIOD status (only Pins 12,13,14,15) and store to r1
    str r1,[r0]			// Store new status r1 to GPIOD address [ro]
    pop {r0,r1}			// Restore r0, r1 from stack
    bx lr				// Return from function call
