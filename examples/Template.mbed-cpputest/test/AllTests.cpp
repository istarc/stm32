#include "CppUTest/CommandLineTestRunner.h"

volatile unsigned int * const UART0DR = (unsigned int *)0x101f1000;
 
void print_uart0(const char *s) {
 while(*s != '\0') { /* Loop until end of string */
 *UART0DR = (unsigned int)(*s); /* Transmit char */
 s++; /* Next char */
 }
}
 
void c_entry() {
 print_uart0("Hello world!\n");
}

int main(int argc, char** argv)
{
   c_entry();
   return CommandLineTestRunner::RunAllTests(argc, argv);
}

