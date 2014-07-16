/* C prototype:
 *
 *  void delay(unsigned long iterations);
 *
 * // A quick and dirty 'Delay' routine
 * void delay(unsigned int ticks)
 * {
 *   unsigned long us = 1*ticks;
 *
 *   while (us--)
 *   {
 *     __asm volatile("nop");
 *   }
 * }
 *
 */
	.syntax unified
	.cpu cortex-m4
	.thumb

	.section  .text.Delay
  	.weak  Delay
	.type  Delay, %function

Delay:
	ldr r1,=1
	muls r0, r1
loop:
	nop
	subs r0, #1
	bne loop
	bx lr
