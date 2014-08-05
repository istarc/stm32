/** 
  * Description: A quick and dirty Assembly delay routine
  *
  * C equivalent
  *
  * void delay(int ticks)
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
	ldr r1,=1	@ Load immediate and ...
	muls r0, r1	@ ... multiply it with tick argument
loop:
	nop
	subs r0, #1	@ In each loop decrement
	bne loop	@ until r0 == 0
	bx lr		@ return from subroutine
