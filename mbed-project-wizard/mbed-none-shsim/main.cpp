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
extern "C" {
#include <stdlib.h>
#include <stdio.h>
}
#include "add.h"
#include "dadd.h"

int main(void) {
    int i = 0;
    i = add(i,1);
    printf("%d Hello world!\n", i);
    i = dadd(i,1);
    printf("%d Hello world!\n", i);

    return 0;
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
