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
#include "CppUTest/CommandLineTestRunner.h"

Serial device(STDIO_UART_TX, STDIO_UART_RX);

int main() {
	int argc = 0;
	char* argv[] = {""};
	device.printf("Hello World\n");
	CommandLineTestRunner::RunAllTests(argc, argv);
}
