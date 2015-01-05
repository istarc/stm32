/* Board includes */
#include "mbed.h"
/* Include lwIP */
#include "lwip.h"
/* Kernel includes. */
#include "FreeRTOS.h"
#include "task.h"
#include "timers.h"
#include "semphr.h"

void SystemClock_Config(void);
static void MX_GPIO_Init(void);

void ToggleLED_Timer(void*);
void DetectButtonPress(void*);
void ToggleLED_IPC(void*);
void Networking(void*);

xQueueHandle pbq;

// MCU Pin names FreeRTOS.mbed/inc/targets/HAL/TARGET_STM/STM32F4XX/PinNames.h
// MCU Pin-STM32F4Discovery Board mapping: http://www.st.com/st-web-ui/static/active/en/resource/technical/document/user_manual/DM00039084.pdf
DigitalIn pb(PA_0); // STM32F4Discovery Board User Push Button
DigitalOut myled1(PD_12); // STM32F4Discovery Board Green Led
DigitalOut myled2(PD_14); // STM32F4Discovery Board Red Led

int main(void)
{
  /* Configure the system clock */
  SystemClock_Config();
  /* Initialize all configured peripherals */
  MX_GPIO_Init();
  MX_LWIP_Init();

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

  /* Create tasks */
  xTaskCreate(
      Networking,                       /* Function pointer */
      "Task4",                          /* Task name - for debugging only*/
      configMINIMAL_STACK_SIZE,         /* Stack depth in words */
      (void*) NULL,                     /* Pointer to tasks arguments (parameter) */
      tskIDLE_PRIORITY + 2UL,           /* Task priority*/
      NULL                              /* Task handle */
  );
  
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
    vTaskDelay(10 / portTICK_RATE_MS); /* Wait press, probe every 10 ms */
    if(pb == 1) {
      vTaskDelay(10 / portTICK_RATE_MS); /* Debounce delay 10 ms */
      while(pb == 1)
        vTaskDelay(10 / portTICK_RATE_MS); /* Wait release, probe every 10 ms */
      vTaskDelay(10 / portTICK_RATE_MS); /* Debounce Delay 10 ms */

      /* Notify Task 3 */
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

/**
 * TASK 4: Networking
 */
void Networking(void *pvParameters){
  while (1) {
    MX_LWIP_Process();
  }
}

void MX_GPIO_Init(void)
{

  GPIO_InitTypeDef GPIO_InitStruct;

  /* GPIO Ports Clock Enable */
  __GPIOH_CLK_ENABLE();
  __GPIOC_CLK_ENABLE();
  __GPIOA_CLK_ENABLE();
  __GPIOB_CLK_ENABLE();

  /*Configure GPIO pin : PA8 */
  GPIO_InitStruct.Pin = GPIO_PIN_8;
  GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_LOW;
  GPIO_InitStruct.Alternate = GPIO_AF0_MCO;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

}

/** System Clock Configuration
*/
void SystemClock_Config(void)
{

  RCC_OscInitTypeDef RCC_OscInitStruct;
  RCC_ClkInitTypeDef RCC_ClkInitStruct;

  __PWR_CLK_ENABLE();

  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSI|RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.HSIState = RCC_HSI_ON;
  RCC_OscInitStruct.HSICalibrationValue = 6;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 8;
  RCC_OscInitStruct.PLL.PLLN = 336;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 4;
  HAL_RCC_OscConfig(&RCC_OscInitStruct);

  RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_SYSCLK|RCC_CLOCKTYPE_PCLK1
                              |RCC_CLOCKTYPE_PCLK2;
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;
  HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5);

  HAL_RCC_MCOConfig(RCC_MCO1, RCC_MCO1SOURCE_HSI, RCC_MCODIV_1);

}