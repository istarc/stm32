/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
  * @brief  Main program
  * STM32F4DIS Base Board RS-232 Interface is mapped to the UART6 of
  * STM32F4-Discovery Board (see STM32F4-BB User Manual).
  *
  * Note: Make sure that jumpers JP1 and JP2 are fitted on the Base Board.
  *
  * This project shows how to retarget STDIO by
  *  1. patching PeripheralNames.h (see patchfile),
  *  2. enabling DEVICE_SERIAL (see Makefile),
  *  3. redefining STDIO_UART_TX, STDIO_UART_RX, STDIO_UART values to
  *     pins PC_6, PC_7, UART_6, respectively (see Makefile).
  *
  * @param  None
  * @retval None
  */
#include "mbed.h"

using namespace mbed;
 
DigitalOut myled(LED1);
 
int main() {

    while(1) {
        myled = 1;
        wait(0.5);
	printf("+");
	fflush(stdout);
        myled = 0;
        wait(0.5);
	printf("-");
	fflush(stdout);
    }
}

/*
 * Override C++ new/delete operators to reduce memory footprint
 */
#ifdef CUSTOM_NEW

void *operator new(size_t size) {
        return malloc(size);
}

void *operator new[](size_t size) {
        return malloc(size);
}

void operator delete(void *p) {
        free(p);
}

void operator delete[](void *p) {
        free(p);
}

#endif
