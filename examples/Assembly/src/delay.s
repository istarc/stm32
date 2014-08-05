/** 
  * Description: A quick and dirty Assembly delay routine
  *
  * C equivalent
  *
  * void delay(unsigned long ticks)
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

	.section  .text.delay
  	.weak  delay
	.type  delay, %function

delay:
	ldr r1,=1
	muls r0, r1
loop:
	nop
	subs r0, #1
	bne loop
	bx lr
