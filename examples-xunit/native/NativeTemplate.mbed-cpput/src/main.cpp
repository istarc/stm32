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
#include "add.h"
#include "dadd.h"

DigitalOut myled(LED1);

int main() {
    int i = 0;
    while(1) {
        i = add(i,1);
        i = dadd(i,1);
        printf("%d Hello world!\n", i);
        myled = i%3;
        wait(i%10);
    }
}
