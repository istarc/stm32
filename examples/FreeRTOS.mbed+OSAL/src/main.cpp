/* includes ------------------------------------------------------------------*/
#include "mbed.h"
#include "cmsis_os.h"
/* defines -------------------------------------------------------------------*/
#define DELAY 100000000
#define BUSY_WAIT // Uncomment to use busy wait rather than osDelay (the latter is better ;-))
/* macros --------------------------------------------------------------------*/
/* function prototypes -------------------------------------------------------*/
static void led1_callback(void const*);
static void led2_thread(void const*);
static void bwait(void);

/* variables -----------------------------------------------------------------*/
DigitalOut led1(LED1);
DigitalOut led2(LED2);
osTimerDef(Timer1, led1_callback); //via macro
osThreadDef(Thread1, led2_thread,  osPriorityLow, 1, 1024); //via macro

/* functions -----------------------------------------------------------------*/
static void led1_callback(void const *args){
      led1 = !led1;
}

static void led2_thread(void const *args){
    int i=0;
    while(true){
#if defined(BUSY_WAIT)
        for(i=0; i<DELAY; i++)
            __asm volatile("nop");
#else
        osDelay(1000);
#endif
        led2 = !led2;
    }
}

/**
  * @brief  Main program
  * @param  None
  * @retval None
  */
int main() {

    osTimerId idTim1;
    osThreadId idTh1;

    idTim1=osTimerCreate(osTimer(Timer1), osTimerPeriodic, NULL);
    osTimerStart(idTim1, 1000);
    idTh1=osThreadCreate(osThread(Thread1), NULL);
    
    osKernelStart(NULL, NULL);
    
    for(;;);
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
