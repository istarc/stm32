/**
  ******************************************************************************
  * @file    LwIP/LwIP_TCP_Echo_Client/Src/main.c 
  * @author  MCD Application Team
  * @version V1.1.0
  * @date    26-June-2014
  * @brief   This sample code implements a TCP Echo Client application based on 
  *          Raw API of LwIP stack. This application uses STM32F4xx the 
  *          ETH HAL API to transmit and receive data. 
  *          The communication is done with a web browser of a remote PC.
  ******************************************************************************
  * @attention
  *
  * <h2><center>&copy; COPYRIGHT(c) 2014 STMicroelectronics</center></h2>
  *
  * Licensed under MCD-ST Liberty SW License Agreement V2, (the "License");
  * You may not use this file except in compliance with the License.
  * You may obtain a copy of the License at:
  *
  *        http://www.st.com/software_license_agreement_liberty_v2
  *
  * Unless required by applicable law or agreed to in writing, software 
  * distributed under the License is distributed on an "AS IS" BASIS, 
  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  * See the License for the specific language governing permissions and
  * limitations under the License.
  *
  ******************************************************************************
  */

/* Includes ------------------------------------------------------------------*/
#include "main.h"
#include "lwip/opt.h"
#include "lwip/init.h"
#include "lwip/netif.h"
#include "lwip/lwip_timers.h"
#include "netif/etharp.h"
#include "ethernetif.h"
#include "app_ethernet.h"
#include "tcp_echoclient.h"

/* Private typedef -----------------------------------------------------------*/
/* Private define ------------------------------------------------------------*/
/* Private macro -------------------------------------------------------------*/
/* Private variables ---------------------------------------------------------*/
struct netif gnetif;

/* Private function prototypes -----------------------------------------------*/
static void SystemClock_Config(void);
static void BSP_Config(void);
static void Netif_Config(void);

/* Private functions ---------------------------------------------------------*/

/**
  * @brief  Main program
  * @param  None
  * @retval None
  */
int main(void)
{
  /* STM32F4xx HAL library initialization:
       - Configure the Flash prefetch, instruction and Data caches
       - Configure the Systick to generate an interrupt each 1 msec
       - Set NVIC Group Priority to 4
       - Global MSP (MCU Support Package) initialization
     */
  HAL_Init();  
  
  /* Configure the system clock to 168 Mhz */
  SystemClock_Config();
  
  /* Configure the BSP */
  BSP_Config();
    
  /* Initilaize the LwIP stack */
  lwip_init();
  
  /* Configure the Network interface */
  Netif_Config();
  
  /* Notify user about the netwoek interface config */
  User_notification(&gnetif);

  /* Infinite loop */
  while (1)
  {  
    /* Read a received packet from the Ethernet buffers and send it 
       to the lwIP for handling */
    ethernetif_input(&gnetif);

    /* Handle timeouts */
    sys_check_timeouts();
  }
}

/**
  * @brief  Configurates the BSP.
  * @param  None
  * @retval None
  */
static void BSP_Config(void)
{
   GPIO_InitTypeDef GPIO_InitStructure;
   
   __GPIOB_CLK_ENABLE();
   
  GPIO_InitStructure.Pin = GPIO_PIN_14;
  GPIO_InitStructure.Mode = GPIO_MODE_IT_FALLING;
  GPIO_InitStructure.Pull = GPIO_NOPULL ;
  HAL_GPIO_Init(GPIOB, &GPIO_InitStructure);
 
  HAL_NVIC_SetPriority(EXTI15_10_IRQn, 0xF, 0);
  HAL_NVIC_EnableIRQ(EXTI15_10_IRQn); 
  
  /* Initialize STM324x9I-EVAL's LEDs */
  BSP_LED_Init(LED1);
  BSP_LED_Init(LED2);
  BSP_LED_Init(LED3);
  BSP_LED_Init(LED4);

  /* Initialize Key button */
  BSP_PB_Init(BUTTON_KEY, BUTTON_MODE_EXTI);
  
  /* Set Systick Interrupt to the highest priority */
  HAL_NVIC_SetPriority(SysTick_IRQn, 0x0, 0x0);
}

/**
  * @brief  Configurates the network interface
  * @param  None
  * @retval None
  */
static void Netif_Config(void)
{
  struct ip_addr ipaddr;
  struct ip_addr netmask;
  struct ip_addr gw;
  
  IP4_ADDR(&ipaddr, IP_ADDR0, IP_ADDR1, IP_ADDR2, IP_ADDR3);
  IP4_ADDR(&netmask, NETMASK_ADDR0, NETMASK_ADDR1 , NETMASK_ADDR2, NETMASK_ADDR3);
  IP4_ADDR(&gw, GW_ADDR0, GW_ADDR1, GW_ADDR2, GW_ADDR3);
  
  /* add the network interface */    
  netif_add(&gnetif, &ipaddr, &netmask, &gw, NULL, &ethernetif_init, &ethernet_input);
  
  /*  Registers the default network interface */
  netif_set_default(&gnetif);
  
  if (netif_is_link_up(&gnetif))
  {
    /* When the netif is fully configured this function must be called */
    netif_set_up(&gnetif);
  }
  else
  {
    /* When the netif link is down this function must be called */
    netif_set_down(&gnetif);
  }
  
  /* Set the link callback function, this function is called on change of link status*/
  netif_set_link_callback(&gnetif, ethernetif_update_config);
}

/**
  * @brief  EXTI line detection callbacks
  * @param  GPIO_Pin: Specifies the pins connected EXTI line
  * @retval None
  */
void HAL_GPIO_EXTI_Callback(uint16_t GPIO_Pin)
{
  if (GPIO_Pin == GPIO_PIN_14)
  {
    ethernetif_set_link(&gnetif);
  }
  else if (GPIO_Pin == GPIO_PIN_15)
  {
    /*connect to tcp server */ 
    tcp_echoclient_connect();
  }
}

/**
  * @brief  System Clock Configuration
  *         The system Clock is configured as follow : 
  *            System Clock source            = PLL (HSE)
  *            SYSCLK(Hz)                     = 168000000
  *            HCLK(Hz)                       = 168000000
  *            AHB Prescaler                  = 1
  *            APB1 Prescaler                 = 4
  *            APB2 Prescaler                 = 2
  *            HSE Frequency(Hz)              = 25000000
  *            PLL_M                          = 25
  *            PLL_N                          = 336
  *            PLL_P                          = 2
  *            PLL_Q                          = 7
  *            VDD(V)                         = 3.3
  *            Main regulator output voltage  = Scale1 mode
  *            Flash Latency(WS)              = 5
  * @param  None
  * @retval None
  */
static void SystemClock_Config(void)
{
  RCC_ClkInitTypeDef RCC_ClkInitStruct;
  RCC_OscInitTypeDef RCC_OscInitStruct;

  /* Enable Power Control clock */
  __PWR_CLK_ENABLE();

  /* The voltage scaling allows optimizing the power consumption when the device is 
     clocked below the maximum system frequency, to update the voltage scaling value 
     regarding system frequency refer to product datasheet.  */
  __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE1);

  /* Enable HSE Oscillator and activate PLL with HSE as source */
  RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_HSE;
  RCC_OscInitStruct.HSEState = RCC_HSE_ON;
  RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
  RCC_OscInitStruct.PLL.PLLSource = RCC_PLLSOURCE_HSE;
  RCC_OscInitStruct.PLL.PLLM = 25;
  RCC_OscInitStruct.PLL.PLLN = 336;
  RCC_OscInitStruct.PLL.PLLP = RCC_PLLP_DIV2;
  RCC_OscInitStruct.PLL.PLLQ = 7;
  HAL_RCC_OscConfig(&RCC_OscInitStruct);
 
  /* Select PLL as system clock source and configure the HCLK, PCLK1 and PCLK2 
     clocks dividers */
  RCC_ClkInitStruct.ClockType = (RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2);
  RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
  RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
  RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV4;  
  RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV2;  
  HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5);
}

#ifdef  USE_FULL_ASSERT

/**
  * @brief  Reports the name of the source file and the source line number
  *   where the assert_param error has occurred.
  * @param  file: pointer to the source file name
  * @param  line: assert_param error line source number
  * @retval None
  */
void assert_failed(uint8_t* file, uint32_t line)
{
  /* User can add his own implementation to report the file name and line number,
     ex: printf("Wrong parameters value: file %s on line %d\r\n", file, line) */

  /* Infinite loop */
  while (1)
  {}
}
#endif

/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/
