/* includes ------------------------------------------------------------------*/
#include "mbed.h"
#include "FreeRTOS.h"
#include "task.h"
#include "timers.h"
/* defines -------------------------------------------------------------------*/
#define DELAY 100000000
#define BUSY_WAIT // Uncomment to use busy wait rather than osDelay (the latter is better ;-))
/* macros --------------------------------------------------------------------*/
/* function prototypes -------------------------------------------------------*/
void led1_callback(void*);
void led2_thread(void*);

/* variables -----------------------------------------------------------------*/
DigitalOut led1(LED1);
DigitalOut led2(LED2);

/* functions -----------------------------------------------------------------*/
void led1_callback(void *args){
      led1 = !led1;
}

void led2_thread(void *args){
    int i=0;
    while(true){
#if defined(BUSY_WAIT)
        for(i=0; i<DELAY; i++)
            __asm volatile("nop");
#else
        vTaskDelay(1000/portTICK_RATE_MS);
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

    TimerHandle_t idTim1;
    idTim1=xTimerCreate("Timer1", 1000/portTICK_RATE_MS, pdTRUE, 0, led1_callback);
    xTimerStart(idTim1, 0);
    xTaskCreate(led2_thread, "Thread1", 1024, (void*) NULL, tskIDLE_PRIORITY + 1UL, NULL);

    vTaskStartScheduler();
    
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
