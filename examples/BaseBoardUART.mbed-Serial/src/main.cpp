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
  * This example is based on http://developer.mbed.org/handbook/Serial
  *
  * @param  None
  * @retval None
  */
#include "mbed.h"

using namespace mbed;
 
DigitalOut myled(LED1);
Serial pc(PC_6, PC_7); // tx, rx
 
int main() {

    pc.baud(9600);

    while(1) {
        myled = 1;
        wait(0.5);
	pc.printf("+");
        myled = 0;
        wait(0.5);
	pc.printf("-");
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
