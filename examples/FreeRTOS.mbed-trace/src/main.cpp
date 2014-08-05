/* Board includes */
#include "mbed.h"
/* Kernel includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "timers.h"
#include "semphr.h"

#define BLOCK_

void ToggleLED_Timer(void*);
void DetectButtonPress(void*);
void ToggleLED_IPC(void*);

xQueueHandle pbq;

// MCU Pin names FreeRTOS.mbed/inc/targets/HAL/TARGET_STM/STM32F4XX/PinNames.h
// MCU Pin-STM32F4Discovery Board mapping: http://www.st.com/st-web-ui/static/active/en/resource/technical/document/user_manual/DM00039084.pdf
DigitalIn pb(PA_0); // STM32F4Discovery Board User Push Button
DigitalOut myled1(PD_12); // STM32F4Discovery Board Green Led
DigitalOut myled2(PD_14); // STM32F4Discovery Board Red Led

int main(void)
{
  vTraceInitTraceData ();
  uiTraceStart();

  /* Create IPC variables */
  pbq = xQueueCreate(10, sizeof(int));
  if (pbq == 0) {
    while(1); /* fatal error */
  }
  
  /* Create tasks */
  xTaskCreate(
		  ToggleLED_Timer,                 /* Function pointer */
		  "Task1",                          /* Task name - for debugging only*/
		  configMINIMAL_STACK_SIZE,         /* Stack depth in words */
		  (void*) NULL,                     /* Pointer to tasks arguments (parameter) */
		  tskIDLE_PRIORITY + 2UL,           /* Task priority*/
		  NULL                              /* Task handle */
  );
  
  xTaskCreate(
		  DetectButtonPress,
		  "Task2",
		  configMINIMAL_STACK_SIZE,
		  (void*) NULL,
		  tskIDLE_PRIORITY + 2UL,
		  NULL);

  xTaskCreate(
		  ToggleLED_IPC,
		  "Task3",
		  configMINIMAL_STACK_SIZE,
		  (void*) NULL,
		  tskIDLE_PRIORITY + 2UL,
		  NULL);
  
  /* Start the RTOS Scheduler */
  vTaskStartScheduler();
  
  /* HALT */
  while(1); 
}

/**
 * TASK 1: Toggle LED via RTOS Timer
 */
void ToggleLED_Timer(void *pvParameters){
  
  while (1) {
    myled1 = myled1 ^ 1;
    
    /*
    Delay for a period of time. vTaskDelay() places the task into
    the Blocked state until the period has expired.
    The delay period is spacified in 'ticks'. We can convert
    yhis in milisecond with the constant portTICK_RATE_MS.
    */
    vTaskDelay(1500 / portTICK_RATE_MS);
  }
}

/**
 * TASK 2: Detect Button Press
 * 			And Signal Event via Inter-Process Communication (IPC)
 */
void DetectButtonPress(void *pvParameters){
  
  int sig = 1;
  
  while (1) {
	/* Detect Button Press  */
    if(pb > 0) {
      while(pb > 0)
        vTaskDelay(100 / portTICK_RATE_MS); /* Button Debounce Delay */
      while(pb == 0)
        vTaskDelay(100 / portTICK_RATE_MS); /* Button Debounce Delay */
      
      xQueueSendToBack(pbq, &sig, 0); /* Send Message */
    }
  }
}

/**
 * TASK 3: Toggle LED via Inter-Process Communication (IPC)
 *
 */
void ToggleLED_IPC(void *pvParameters) {
  
  int sig;
  portBASE_TYPE status;
  
  while (1) {
    status = xQueueReceive(pbq, &sig, portMAX_DELAY); /* Receive Message */
    												  /* portMAX_DELAY blocks task indefinitely if queue is empty */
    if(status == pdTRUE) {
      myled2 = myled2 ^ 1;
    }
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

