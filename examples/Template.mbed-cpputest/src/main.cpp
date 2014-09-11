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
//#include "CppUTest/CommandLineTestRunner.h"

Serial device(STDIO_UART_TX, STDIO_UART_RX);

int main() {
	device.printf("Hello World\n");
}
