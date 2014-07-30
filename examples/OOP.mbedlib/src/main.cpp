/* Includes ------------------------------------------------------------------*/
#include <new>
#include <cstddef>

#include "TimeDelay.h"

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
/* Private function prototypes -----------------------------------------------*/
/* Private functions ---------------------------------------------------------*/

/**
  * @brief  Main program
  * @param  None
  * @retval None
  */

#include "mbed.h"

DigitalOut myled1(PD_12);
DigitalOut myled2(PD_13);
DigitalOut myled3(PD_14);
DigitalOut myled4(PD_15);

int main() {
  TimeDelay td1 = TimeDelay(); /* OOP: Automatic object instantiation (using stack) */
#ifdef NO_EXCEPTIONS
  TimeDelay *td2 = new TimeDelay(); /* OOP: Dynamic object instantiation (using heap) */
#else
  TimeDelay *td2 = NULL;
  try { /* OOP: Exception handling */
          td2 = new TimeDelay();
  } catch(int e) {
          while(true);
  }
#endif

  while (1)
  {
    /* PD12 to be toggled */
    myled1 = myled1 ^ 1;

    /* Insert delay */
    wait(td1.get()/0x8FFFFF+0.25);

    /* PD13 to be toggled */
    myled2 = myled2 ^ 1;

    /* Insert delay */
    wait(td1.get()/0x8FFFFF+0.25);

    /* PD14 to be toggled */
    myled3 = myled3 ^ 1;

    /* Insert delay */
    wait(td1.get()/0x8FFFFF+0.25);

    /* PD15 to be toggled */
    myled4 = myled4 ^ 1;

    /* Insert delay */
    wait(td2->get()/0x8FFFFF+0.25);
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
