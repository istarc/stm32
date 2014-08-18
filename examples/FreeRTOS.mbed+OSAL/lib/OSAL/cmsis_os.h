/* ----------------------------------------------------------------------
 * Copyright (C) 2011 ARM Limited. All rights reserved.
 *
 * $Date:        10. Februar 2012
 * $Revision:    V0.03
 *
 * Project:      CMSIS-RTOS API
 * Title:        cmsis_os.h template header file
 *
 * Version 0.02
 *    Initial Proposal Phase
 * Version 0.03
 *    osKernelStart added, optional feature: main started as thread
 *    osSemaphores have standard behaviour
 *    osTimerCreate does not start the timer, added osTimerStart
 *    osThreadPass is renamed to osThreadYield
 * -------------------------------------------------------------------- */
#if   defined ( __CC_ARM )
  #define __ASM            __asm                                      /*!< asm keyword for ARM Compiler          */
  #define __INLINE         __inline                                   /*!< inline keyword for ARM Compiler       */
  #define __STATIC_INLINE  static __inline
#elif defined ( __ICCARM__ )
  #define __ASM            __asm                                      /*!< asm keyword for IAR Compiler          */
  #define __INLINE         inline                                     /*!< inline keyword for IAR Compiler. Only available in High optimization mode! */
  #define __STATIC_INLINE  static inline
#elif defined ( __GNUC__ )
  #define __ASM            __asm                                      /*!< asm keyword for GNU Compiler          */
  #define __INLINE         inline                                     /*!< inline keyword for GNU Compiler       */
  #define __STATIC_INLINE  static inline
#endif

#include <stdint.h>
#include "core_cmFunc.h"
	
#include "FreeRTOS.h"
#include "task.h"
#include "timers.h"
#include "queue.h"
#include "semphr.h"


/**
\page cmsis_os_h Header File Template: cmsis_os.h

The file \b cmsis_os.h is a template header file for a CMSIS-RTOS compliant Real-Time Operating System (RTOS).
Each RTOS that is compliant with CMSIS-RTOS shall provide a specific \b cmsis_os.h header file that represents
its implementation.

The file cmsis_os.h contains:
 - CMSIS-RTOS API function definitions
 - struct definitions for parameters and return types
 - status and priority values used by CMSIS-RTOS API functions
 - macros for defining threads and other kernel objects


<b>Name conventions and header file modifications</b>

All definitions are prefixed with \b os to give an unique name space for CMSIS-RTOS functions.
Definitions that are prefixed \b os_ are not used in the application code but local to this header file.
All definitions and functions that belong to a module are grouped and have a common prefix, i.e. \b osThread.

Definitions that are marked with <b>CAN BE CHANGED</b> can be adapted towards the needs of the actual CMSIS-RTOS implementation.
These definitions can be specific to the underlying RTOS kernel.

Definitions that are marked with <b>MUST REMAIN UNCHANGED</b> cannot be altered. Otherwise the CMSIS-RTOS implementation is no longer
compliant to the standard. Note that some functions are optional and need not to be provided by every CMSIS-RTOS implementation.


<b>Function calls from interrupt service routines</b>

The following CMSIS-RTOS functions can be called from threads and interrupt service routines (ISR):
  - \ref osSignalSet
  - \ref osSemaphoreRelease
  - \ref osPoolAlloc, \ref osPoolCAlloc, \ref osPoolFree
  - \ref osMessagePut, \ref osMessageGet
  - \ref osMailAlloc, \ref osMailCAlloc, \ref osMailGet, \ref osMailPut, \ref osMailFree

Functions that cannot be called from an ISR are verifying the interrupt status and return in case that they are called
from an ISR context the status code \b osErrorISR. In some implementations this condition might be caught using the HARD FAULT vector.

Some CMSIS-RTOS implementations support CMSIS-RTOS function calls from multiple ISR at the same time.
If this is impossible, the CMSIS-RTOS rejects calls by nested ISR functions with the status code \b osErrorISRRecursive.


<b>Define and reference object definitions</b>

With <b>\#define osObjectsExternal</b> objects are defined as external symbols. This allows to create a consistent header file
that is used troughtout a project as shown below:

<i>Header File</i>
\code
#include <cmsis_os.h>                                         // CMSIS RTOS header file

// Thread definition
extern void thread_sample (void const *argument);             // function prototype
osThreadDef (thread_sample, osPriorityBelowNormal, 1, 100);

// Pool definition
osPoolDef(MyPool, 10, long);
\endcode


This header file defines all objects when included in a C/C++ source file. When <b>\#define osObjectsExternal</b> is
present before the header file, the objects are defined as external symbols. A single consistent header file can therefore be
used throughout the whole project.

<i>Example</i>
\code
#include "osObjects.h"     // Definition of the CMSIS-RTOS objects
\endcode

\code
#define osObjectExternal   // Objects will be defined as external symbols
#include "osObjects.h"     // Reference to the CMSIS-RTOS objects
\endcode

*/

#ifndef _CMSIS_OS_H
#define _CMSIS_OS_H

/**
  * @note   MUST REMAIN UNCHANGED: \b osCMSIS identifies the CMSIS-RTOS API version
  */
#define osCMSIS           0x00003      /* API version (main [31:16] .sub [15:0]) */

/**
  * @note   CAN BE CHANGED: \b osCMSIS_KERNEL identifies the underlaying RTOS kernel and version number.
  */
#define osCMSIS_KERNEL    0x10000	   /* RTOS identification and version (main [31:16] .sub [15:0]) */

/**
  * @note   MUST REMAIN UNCHANGED: \b osKernelSystemId shall be consistent in every CMSIS-RTOS.
  */
#define osKernelSystemId "KERNEL V1.00"   /* RTOS identification string */

/**
  * @note    MUST REMAIN UNCHANGED: \b osFeature_xxx shall be consistent in every CMSIS-RTOS.
  */
#define osFeature_MainThread   1       /* main thread      1=main can be thread, 0=not available */
#define osFeature_Pool         1       /* Memory Pools:    1=available, 0=not available          */
#define osFeature_MailQ        1       /* Mail Queues:     1=available, 0=not available          */
#define osFeature_MessageQ     1       /* Message Queues:  1=available, 0=not available          */
#define osFeature_Signals      8       /* maximum number of Signal Flags available per thread    */
#define osFeature_Semaphore    30      /* maximum count for SemaphoreInit function               */
#define osFeature_Wait         1       /* osWait function: 1=available, 0=not available          */

#include <stdint.h>
#include <stddef.h>

#ifdef  __cplusplus
extern "C"
{
#endif

/********************   Enumeration, structures, defines  **********************/ 
/**
  * @brief Priority used for thread control.
  * @note  MUST REMAIN UNCHANGED: \b osPriority shall be consistent in every CMSIS-RTOS.
  */
typedef enum  {
  osPriorityIdle          = -3,          /* priority: idle (lowest)                                         */
  osPriorityLow           = -2,          /* priority: low                                                   */
  osPriorityBelowNormal   = -1,          /* priority: below normal                                          */
  osPriorityNormal        =  0,          /* priority: normal (default)                                      */
  osPriorityAboveNormal   = +1,          /* priority: above normal                                          */
  osPriorityHigh          = +2,          /* priority: high                                                  */
  osPriorityRealtime      = +3,          /* priority: realtime (highest)                                    */
  osPriorityError         =  0x84,       /* system cannot determine priority or thread has illegal priority */
} osPriority;

/**
  * @brief Timeout value.
  * @note  MUST REMAIN UNCHANGED: \b osWaitForever shall be consistent in every CMSIS-RTOS.
  */
#define osWaitForever     0xFFFFFFFF     /* wait forever timeout value */

/**
  * @brief Status code values returned by CMSIS-RTOS functions
  * @note  MUST REMAIN UNCHANGED: \b osStatus shall be consistent in every CMSIS-RTOS.
  */
typedef enum {
  osOK                    =     0,       /* function completed; no event occurred.                                                                      */
  osEventSignal           =  0x08,       /* function completed; signal event occurred.                                                                  */
  osEventMessage          =  0x10,       /* function completed; message event occurred.                                                                 */
  osEventMail             =  0x20,       /* function completed; mail event occurred.                                                                    */
  osEventTimeout          =  0x40,       /* function completed; timeout occurred.                                                                       */
  osErrorParameter        =  0x80,       /* parameter error: a mandatory parameter was missing or specified an incorrect object.                        */
  osErrorResource         =  0x81,       /* resource not available: a specified resource was not available.                                             */
  osErrorTimeoutResource  =  0xC1,       /* resource not available within given time: a specified resource was not available within the timeout period. */
  osErrorISR              =  0x82,       /* not allowed in ISR context: the function cannot be called from interrupt service routines.                  */
  osErrorISRRecursive     =  0x83,       /* function called multiple times from ISR with same object.                                                   */
  osErrorPriority         =  0x84,       /* system cannot determine priority or thread has illegal priority.                                            */
  osErrorNoMemory         =  0x85,       /* system is out of memory: it was impossible to allocate or reserve memory for the operation.                 */
  osErrorValue            =  0x86,       /* value of a parameter is out of range.                                                                       */
  osErrorOS               =  0xFF,       /* unspecified RTOS error: run-time error but no other error message fits.                                     */
  os_status_reserved      =  0x7FFFFFFF, /* prevent from enum down-size compiler optimization.                                                          */
} osStatus;

/**
  * @brief Timer type value for the timer definition
  * @note  MUST REMAIN UNCHANGED: \b os_timer_type shall be consistent in every CMSIS-RTOS.
  */
typedef enum   {
  osTimerOnce             =     0,       /* one-shot timer  */
  osTimerPeriodic         =     1,       /* repeating timer */
} os_timer_type;

/**
  * @brief Entry point of a thread.
  * @note  MUST REMAIN UNCHANGED: \b os_pthread shall be consistent in every CMSIS-RTOS.
  */
typedef void (*os_pthread) (void const *argument);

/**
  * @brief Entry point of a timer call back function.
  * @note  MUST REMAIN UNCHANGED: \b os_ptimer shall be consistent in every CMSIS-RTOS.
  */
typedef void (*os_ptimer) (void const *argument);

/* the following data type definitions may shall adapted towards a specific RTOS */

/**
  * @brief Thread ID identifies the thread (pointer to a thread control block).
  * @note  CAN BE CHANGED: \b os_thread_cb is implementation specific in every CMSIS-RTOS.
  */
typedef xTaskHandle osThreadId;

/**
  * @brief Timer ID identifies the timer (pointer to a timer control block).
  * @note  CAN BE CHANGED: \b os_timer_cb is implementation specific in every CMSIS-RTOS.
  */
typedef xTimerHandle osTimerId;

/**
  * @brief Mutex ID identifies the mutex (pointer to a mutex control block).
  * @note  CAN BE CHANGED: \b os_mutex_cb is implementation specific in every CMSIS-RTOS.
  */
typedef xSemaphoreHandle osMutexId;

/**
  * @briefSemaphore ID identifies the semaphore (pointer to a semaphore control block).
  * @note  CAN BE CHANGED: \b os_semaphore_cb is implementation specific in every CMSIS-RTOS.
  */
typedef xSemaphoreHandle osSemaphoreId;

/**
  * @brief Pool ID identifies the memory pool (pointer to a memory pool control block).
  * @note  CAN BE CHANGED: \b os_pool_cb is implementation specific in every CMSIS-RTOS.
  */
typedef struct os_pool_cb *osPoolId;

/**
  * @brief Message ID identifies the message queue (pointer to a message queue control block).
  * @note  CAN BE CHANGED: \b os_messageQ_cb is implementation specific in every CMSIS-RTOS.
  */
typedef xQueueHandle osMessageQId;

/**
  * @brief Mail ID identifies the mail queue (pointer to a mail queue control block).
  * @note  CAN BE CHANGED: \b os_mailQ_cb is implementation specific in every CMSIS-RTOS.
  */
typedef struct os_mailQ_cb *osMailQId;

/**
  * @brief Thread Definition structure contains startup information of a thread.
  * @note  CAN BE CHANGED: \b os_thread_def is implementation specific in every CMSIS-RTOS.
  */
typedef const struct os_thread_def  {
  char                   *name;        /* Thread name                                               */
  os_pthread             pthread;      /* start address of thread function                          */
  osPriority             tpriority;    /* initial thread priority                                   */
  uint32_t               instances;    /* maximum number of instances of that thread function       */
  uint32_t               stacksize;    /* stack size requirements in bytes; 0 is default stack size */
} osThreadDef_t;


/**
  * @brief Timer Definition structure.
  * @note  CAN BE CHANGED: \b os_timer_def is implementation specific in every CMSIS-RTOS.
  */
typedef const struct os_timer_def  {
  os_ptimer                        ptimer;    /* start address of a timer function */
} osTimerDef_t;

/**
  * @brief Mutex Definition structure contains setup information for a mutex.
  * @note  CAN BE CHANGED: \b os_mutex_def is implementation specific in every CMSIS-RTOS.
  */
typedef const struct os_mutex_def  {
  uint32_t                   dummy;    /*  dummy value. */
} osMutexDef_t;

/**
  * @brief Semaphore Definition structure contains setup information for a semaphore.
  * @note  CAN BE CHANGED: \b os_semaphore_def is implementation specific in every CMSIS-RTOS.
  */
typedef const struct os_semaphore_def  {
  uint32_t                   dummy;    /* dummy value. */
} osSemaphoreDef_t;

/**
  * @brief Definition structure for memory block allocation
  * @note  CAN BE CHANGED: \b os_pool_def is implementation specific in every CMSIS-RTOS.
  */
typedef const struct os_pool_def  {
  uint32_t                 pool_sz;    /*  number of items (elements) in the pool */
  uint32_t                 item_sz;    /*  size of an item */
  void                     *pool;      /*  pointer to memory for pool */
} osPoolDef_t;

/**
  * @brief Definition structure for message queue
  * @note  CAN BE CHANGED: \b os_messageQ_def is implementation specific in every CMSIS-RTOS.
  */
typedef const struct os_messageQ_def  {
  uint32_t                queue_sz;    /*  number of elements in the queue */
  uint32_t                 item_sz;    /*  size of an item */
  //void                       *pool;    /*  memory array for messages */
} osMessageQDef_t;

/**
  * @brief Definition structure for mail queue
  * @note  CAN BE CHANGED: \b os_mailQ_def is implementation specific in every CMSIS-RTOS.
  */
typedef const struct os_mailQ_def  {
  uint32_t                queue_sz;    /*  number of elements in the queue */
  uint32_t                 item_sz;    /*  size of an item */
  struct os_mailQ_cb **cb;
} osMailQDef_t;

/**
  * @brief Event structure contains detailed information about an event.
  * @note  MUST REMAIN UNCHANGED: \b os_event shall be consistent in every CMSIS-RTOS.
  *        However the struct may be extended at the end.
  */
typedef struct  {
  osStatus                 status;     /*  status code: event or error information */
  union  {
    uint32_t                    v;     /*  message as 32-bit value */
    void                       *p;     /*  message or mail as void pointer */
    int32_t               signals;     /*  signal flags */
  } value;                             /*  event value */
  union  {
    osMailQId             mail_id;     /*  mail id obtained by \ref osMailCreate */
    osMessageQId       message_id;     /*  message id obtained by \ref osMessageCreate */
  } def;                               /*  event definition */
} osEvent;

/*********************** Kernel Control Functions *****************************/
/**
  * @brief  Start the RTOS Kernel with executing the specified thread.
  * @param  thread_def    thread definition referenced with \ref osThread.
  * @param  argument      pointer that is passed to the thread function as start argument.
  * @retval status code that indicates the execution status of the function
  * @note   MUST REMAIN UNCHANGED: \b osKernelStart shall be consistent in every CMSIS-RTOS.
  */
osStatus osKernelStart (osThreadDef_t *thread_def, void *argument);

/**
  * @brief  Get the value of the Kernel SysTick timer
  * @param  None
  * @retval None
  * @note   MUST REMAIN UNCHANGED: \b osKernelSysTick shall be consistent in every CMSIS-RTOS.
  */
uint32_t osKernelSysTick(void);

/**
  * @brief  Check if the RTOS kernel is already started
  * @param  None
  * @retval 0 RTOS is not started, 1 RTOS is started.
  * @note  MUST REMAIN UNCHANGED: \b osKernelRunning shall be consistent in every CMSIS-RTOS.
  */
int32_t osKernelRunning(void);

/**************************** Thread Management ********************************/
/**
  * @brief Create a Thread Definition with function, priority, and stack requirements.
  * @param  name    :  name of the thread function.
  * @param  priority:  initial priority of the thread function.
  * @param  instances: number of possible thread instances.
  * @param  stacksz:   stack size (in bytes) requirements for the thread function.
  * @note    CAN BE CHANGED: The parameter to \b osThreadDef shall be consistent 
  *          but the macro body is implementation specific in every CMSIS-RTOS.
  */
#if defined (osObjectsExternal)  // object is external
#define osThreadDef(name, thread, priority, instances, stacksz)  \
extern osThreadDef_t os_thread_def_##name
#else                            // define the object
#define osThreadDef(name, thread, priority, instances, stacksz)  \
osThreadDef_t os_thread_def_##name = \
{ #name, (thread), (priority), (instances), (stacksz)  }
#endif

/**
  * @brief Access a Thread defintion.
  * @param  name    :  name of the thread definition object.
  * @note    CAN BE CHANGED: The parameter to \b osThread shall be consistent 
  *          but the macro body is implementation specific in every CMSIS-RTOS.
  */
#define osThread(name)  \
&os_thread_def_##name

/**
  * @brief  Create a thread and add it to Active Threads and set it to state READY.
  * @param  thread_def    thread definition referenced with \ref osThread.
  * @param  argument      pointer that is passed to the thread function as start argument.
  * @retval thread ID for reference by other functions or NULL in case of error.
  * @note   MUST REMAIN UNCHANGED: \b osThreadCreate shall be consistent in every CMSIS-RTOS.
  */
osThreadId osThreadCreate (osThreadDef_t *thread_def, void *argument);

/**
  * @brief  Return the thread ID of the current running thread.
  * @retval thread ID for reference by other functions or NULL in case of error.
  * @note   MUST REMAIN UNCHANGED: \b osThreadGetId shall be consistent in every CMSIS-RTOS.
  */
osThreadId osThreadGetId (void);

/**
  * @brief  Terminate execution of a thread and remove it from Active Threads.
  * @param   thread_id   thread ID obtained by \ref osThreadCreate or \ref osThreadGetId.
  * @retval  status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osThreadTerminate shall be consistent in every CMSIS-RTOS.
  */
osStatus osThreadTerminate (osThreadId thread_id);

/**
  * @brief  Pass control to next thread that is in state \b READY.
  * @retval status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osThreadYield shall be consistent in every CMSIS-RTOS.
  */
osStatus osThreadYield (void);

/**
  * @brief   Change priority of an active thread.
  * @param   thread_id     thread ID obtained by \ref osThreadCreate or \ref osThreadGetId.
  * @param   priority      new priority value for the thread function.
  * @retval  status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osThreadSetPriority shall be consistent in every CMSIS-RTOS.
  */
osStatus osThreadSetPriority (osThreadId thread_id, osPriority priority);

/**
  * @brief   Get current priority of an active thread.
  * @param   thread_id     thread ID obtained by \ref osThreadCreate or \ref osThreadGetId.
  * @retval  current priority value of the thread function.
  * @note   MUST REMAIN UNCHANGED: \b osThreadGetPriority shall be consistent in every CMSIS-RTOS.
  */
osPriority osThreadGetPriority (osThreadId thread_id);



/*********************** Generic Wait Functions *******************************/
/**
  * @brief   Wait for Timeout (Time Delay)
  * @param   millisec      time delay value
  * @retval  status code that indicates the execution status of the function.
  */
osStatus osDelay (uint32_t millisec);

#if (defined (osFeature_Wait)  &&  (osFeature_Wait != 0)) /* Generic Wait available */

/**
  * @brief  Wait for Signal, Message, Mail, or Timeout
  * @param   millisec  timeout value or 0 in case of no time-out
  * @retval  event that contains signal, message, or mail information or error code.
  * @note   MUST REMAIN UNCHANGED: \b osWait shall be consistent in every CMSIS-RTOS.
  */
osEvent osWait (uint32_t millisec);

#endif  /* Generic Wait available */


/***********************  Timer Management Functions ***************************/
/**
  * @brief Define a Timer object.
  * @param  name    :  name of the timer object.
  * @param  function:  name of the timer call back function.
  * @note    CAN BE CHANGED: The parameter to \b osTimerDef shall be consistent 
  *          but the macro body is implementation specific in every CMSIS-RTOS.
  */
#if defined (osObjectsExternal)  // object is external
#define osTimerDef(name, function)  \
extern osTimerDef_t os_timer_def_##name
#else                            // define the object
#define osTimerDef(name, function)  \
osTimerDef_t os_timer_def_##name = \
{ (function)};
#endif

/**
  * @brief Access a Timer definition.
  * @param  name    :  name of the timer object.
  * @note    CAN BE CHANGED: The parameter to \b osTimer shall be consistent 
  *          but the macro body is implementation specific in every CMSIS-RTOS.
  */
#define osTimer(name) \
&os_timer_def_##name

/**
  * @brief  Create a timer.
  * @param  timer_def     timer object referenced with \ref osTimer.
  * @param  type          osTimerOnce for one-shot or osTimerPeriodic for periodic behavior.
  * @param  argument      argument to the timer call back function.
  * @retval  timer ID for reference by other functions or NULL in case of error.
  * @note   MUST REMAIN UNCHANGED: \b osTimerCreate shall be consistent in every CMSIS-RTOS.
  */
osTimerId osTimerCreate (osTimerDef_t *timer_def, os_timer_type type, void *argument);

/**
  * @brief  Start or restart a timer.
  * @param  timer_id      timer ID obtained by \ref osTimerCreate.
  * @param  millisec      time delay value of the timer.
  * @retval  status code that indicates the execution status of the function
  * @note   MUST REMAIN UNCHANGED: \b osTimerStart shall be consistent in every CMSIS-RTOS.
  */
osStatus osTimerStart (osTimerId timer_id, uint32_t millisec);

/**
  * @brief  Stop a timer.
  * @param  timer_id      timer ID obtained by \ref osTimerCreate
  * @retval  status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osTimerStop shall be consistent in every CMSIS-RTOS.
  */
osStatus osTimerStop (osTimerId timer_id);

/***************************  Signal Management ********************************/
/**
  * @brief  Set the specified Signal Flags of an active thread.
  * @param  thread_id     thread ID obtained by \ref osThreadCreate or \ref osThreadGetId.
  * @param  signals       specifies the signal flags of the thread that should be set.
  * @retval  previous signal flags of the specified thread or 0x80000000 in case of incorrect parameters.
  * @note   MUST REMAIN UNCHANGED: \b osSignalSet shall be consistent in every CMSIS-RTOS.
  */
int32_t osSignalSet (osThreadId thread_id, int32_t signal);

/**
  * @brief  Clear the specified Signal Flags of an active thread.
  * @param  thread_id  thread ID obtained by \ref osThreadCreate or \ref osThreadGetId.
  * @param  signals    specifies the signal flags of the thread that shall be cleared.
  * @retval  previous signal flags of the specified thread or 0x80000000 in case of incorrect parameters.
  * @note   MUST REMAIN UNCHANGED: \b osSignalClear shall be consistent in every CMSIS-RTOS.
  */
int32_t osSignalClear (osThreadId thread_id, int32_t signal);

/**
  * @brief  Get Signal Flags status of an active thread.
  * @param  thread_id  thread ID obtained by \ref osThreadCreate or \ref osThreadGetId.
  * @retval  previous signal flags of the specified thread or 0x80000000 in case of incorrect parameters.
  * @note   MUST REMAIN UNCHANGED: \b osSignalGet shall be consistent in every CMSIS-RTOS.
  */
int32_t osSignalGet (osThreadId thread_id);

/**
  * @brief  Wait for one or more Signal Flags to become signaled for the current \b RUNNING thread.
  * @param  signals   wait until all specified signal flags set or 0 for any single signal flag.
  * @param  millisec  timeout value or 0 in case of no time-out.
  * @retval  event flag information or error code.
  * @note   MUST REMAIN UNCHANGED: \b osSignalWait shall be consistent in every CMSIS-RTOS.
  */
osEvent osSignalWait (int32_t signals, uint32_t millisec);


/****************************  Mutex Management ********************************/
/**
  * @brief Define a Mutex.
  * @param  name    : name of the mutex object.
  * @note    CAN BE CHANGED: The parameter to \b osMutexDef shall be consistent 
  *          but the macro body is implementation specific in every CMSIS-RTOS.
  */
#if defined (osObjectsExternal) 
#define osMutexDef(name)  \
extern osMutexDef_t os_mutex_def_##name
#else                    
#define osMutexDef(name)  \
osMutexDef_t os_mutex_def_##name = { 0 }
#endif

/**
  * @brief Access a Mutex defintion.
  * @param  name    : name of the mutex object.
  * @note    CAN BE CHANGED: The parameter to \b osMutex shall be consistent 
  *          but the macro body is implementation specific in every CMSIS-RTOS.
  */
#define osMutex(name)  \
&os_mutex_def_##name

/**
  * @brief  Create and Initialize a Mutex object
  * @param  mutex_def     mutex definition referenced with \ref osMutex.
  * @retval  mutex ID for reference by other functions or NULL in case of error.
  * @note   MUST REMAIN UNCHANGED: \b osMutexCreate shall be consistent in every CMSIS-RTOS.
  */
osMutexId osMutexCreate (osMutexDef_t *mutex_def);

/**
  * @brief Wait until a Mutex becomes available
  * @param mutex_id      mutex ID obtained by \ref osMutexCreate.
  * @param millisec      timeout value or 0 in case of no time-out.
  * @retval  status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osMutexWait shall be consistent in every CMSIS-RTOS.
  */
osStatus osMutexWait (osMutexId mutex_id, uint32_t millisec);

/**
  * @brief Release a Mutex that was obtained by \ref osMutexWait
  * @param mutex_id      mutex ID obtained by \ref osMutexCreate.
  * @retval  status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osMutexRelease shall be consistent in every CMSIS-RTOS.
  */
osStatus osMutexRelease (osMutexId mutex_id);

/**
  * @brief Delete a Mutex
  * @param mutex_id  mutex ID obtained by \ref osMutexCreate.
  * @retval  status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osMutexDelete shall be consistent in every CMSIS-RTOS.
  */
osStatus osMutexDelete (osMutexId mutex_id);


/********************  Semaphore Management Functions **************************/

#if (defined (osFeature_Semaphore)  &&  (osFeature_Semaphore != 0)) /* Use Semaphores */

/**
  * @brief Define  a Semaphore object.
  * @param  name:  name of the semaphore object
  * @note    CAN BE CHANGED: The parameter to \b osSemaphoreDef shall be consistent 
  *          but the macro body is implementation specific in every CMSIS-RTOS.
  */
#if defined (osObjectsExternal)
#define osSemaphoreDef(name)  \
extern osSemaphoreDef_t os_semaphore_def_##name
#else                  
#define osSemaphoreDef(name)  \
osSemaphoreDef_t os_semaphore_def_##name = { 0 }
#endif

/// Access a Semaphore definition.
/// \param         name          name of the semaphore object.
/// \note CAN BE CHANGED: The parameter to \b osSemaphore shall be consistent but the
///       macro body is implementation specific in every CMSIS-RTOS.
#define osSemaphore(name)  \
&os_semaphore_def_##name

/**
  * @brief Create and Initialize a Semaphore object used for managing resources
  * @param semaphore_def semaphore definition referenced with \ref osSemaphore.
  * @param count         number of available resources.
  * @retval  semaphore ID for reference by other functions or NULL in case of error.
  * @note   MUST REMAIN UNCHANGED: \b osSemaphoreCreate shall be consistent in every CMSIS-RTOS.
  */
osSemaphoreId osSemaphoreCreate (osSemaphoreDef_t *semaphore_def, int32_t count);

/**
  * @brief Wait until a Semaphore token becomes available
  * @param  semaphore_id  semaphore object referenced with \ref osSemaphore.
  * @param  millisec      timeout value or 0 in case of no time-out.
  * @retval  number of available tokens, or -1 in case of incorrect parameters.
  * @note   MUST REMAIN UNCHANGED: \b osSemaphoreWait shall be consistent in every CMSIS-RTOS.
  */
int32_t osSemaphoreWait (osSemaphoreId semaphore_id, uint32_t millisec);

/**
  * @brief Release a Semaphore token
  * @param  semaphore_id  semaphore object referenced with \ref osSemaphore.
  * @retval  status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osSemaphoreRelease shall be consistent in every CMSIS-RTOS.
  */
osStatus osSemaphoreRelease (osSemaphoreId semaphore_id);

/**
  * @brief Delete a Semaphore
  * @param  semaphore_id  semaphore object referenced with \ref osSemaphore.
  * @retval  status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osSemaphoreDelete shall be consistent in every CMSIS-RTOS.
  */
osStatus osSemaphoreDelete (osSemaphoreId semaphore_id);

#endif     /* Use Semaphores */

/*******************   Memory Pool Management Functions  ***********************/

#if (defined (osFeature_Pool)  &&  (osFeature_Pool != 0))  /* Use Memory Pool Management */

/**
  * @brief Define a Memory Pool.
  * @param  name:  name of the memory pool.
  * @param  no:    maximum number of objects (elements) in the memory pool.
  * @param   type: data type of a single object (element).
  * @note    CAN BE CHANGED: The parameter to \b osPoolDef shall be consistent but the
  *          macro body is implementation specific in every CMSIS-RTOS.
  */
#if defined (osObjectsExternal) 
#define osPoolDef(name, no, type)   \
extern osPoolDef_t os_pool_def_##name
#else       
#define osPoolDef(name, no, type)   \
osPoolDef_t os_pool_def_##name = \
{ (no), sizeof(type), NULL }
#endif

/**
  * @brief DAccess a Memory Pool definition.
  * @param  name: name of the memory pool
  * @note    CAN BE CHANGED: The parameter to \b osPool shall be consistent but the
  *          macro body is implementation specific in every CMSIS-RTOS.
  */
#define osPool(name) \
&os_pool_def_##name

/**
  * @brief Create and Initialize a memory pool
  * @param  pool_def      memory pool definition referenced with \ref osPool.
  * @retval  memory pool ID for reference by other functions or NULL in case of error.
  * @note   MUST REMAIN UNCHANGED: \b osPoolCreate shall be consistent in every CMSIS-RTOS.
  */
osPoolId osPoolCreate (osPoolDef_t *pool_def);

/**
  * @brief Allocate a memory block from a memory pool
  * @param pool_id       memory pool ID obtain referenced with \ref osPoolCreate.
  * @retval  address of the allocated memory block or NULL in case of no memory available.
  * @note   MUST REMAIN UNCHANGED: \b osPoolAlloc shall be consistent in every CMSIS-RTOS.
  */
void *osPoolAlloc (osPoolId pool_id);

/**
  * @brief Allocate a memory block from a memory pool and set memory block to zero
  * @param  pool_id       memory pool ID obtain referenced with \ref osPoolCreate.
  * @retval  address of the allocated memory block or NULL in case of no memory available.
  * @note   MUST REMAIN UNCHANGED: \b osPoolCAlloc shall be consistent in every CMSIS-RTOS.
  */
void *osPoolCAlloc (osPoolId pool_id);

/**
  * @brief Return an allocated memory block back to a specific memory pool
  * @param  pool_id       memory pool ID obtain referenced with \ref osPoolCreate.
  * @param  block         address of the allocated memory block that is returned to the memory pool.
  * @retval  status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osPoolFree shall be consistent in every CMSIS-RTOS.
  */
osStatus osPoolFree (osPoolId pool_id, void *block);

#endif   /* Use Memory Pool Management */

/*******************   Message Queue Management Functions  *********************/

#if (defined (osFeature_MessageQ)  &&  (osFeature_MessageQ != 0))     /* Use Message Queues */

/**
  * @brief Create a Message Queue Definition.
  * @param  name  :    name of the queue.
  * @param  queue_sz:  maximum number of messages in the queue.
  * @param  type: data type of a single message element (for debugger).
  * @note    CAN BE CHANGED: The parameter to \b osMessageQDef shall be consistent but the
  *          macro body is implementation specific in every CMSIS-RTOS.
  */
#if defined (osObjectsExternal)  // object is external
#define osMessageQDef(name, queue_sz, type)   \
extern osMessageQDef_t os_messageQ_def_##name
#else                            // define the object
#define osMessageQDef(name, queue_sz, type)   \
osMessageQDef_t os_messageQ_def_##name = \
{ (queue_sz), sizeof (type)  }
#endif

/**
  * @brief Access a Message Queue Definition.
  * @param  name  :  name of the queue.
  * @note    CAN BE CHANGED: The parameter to \b osMessageQ shall be consistent but the
  *          macro body is implementation specific in every CMSIS-RTOS.
  */
#define osMessageQ(name) \
&os_messageQ_def_##name

/**
  * @brief Create and Initialize a Message Queue
  * @param queue_def     queue definition referenced with \ref osMessageQ.
  * @param  thread_id     thread ID (obtained by \ref osThreadCreate or \ref osThreadGetId) or NULL.
  * @retval  message queue ID for reference by other functions or NULL in case of error.
  * @note   MUST REMAIN UNCHANGED: \b osMessageCreate shall be consistent in every CMSIS-RTOS.
  */
osMessageQId osMessageCreate (osMessageQDef_t *queue_def, osThreadId thread_id);

/**
  * @brief Put a Message to a Queue.
  * @param  queue_id  message queue ID obtained with \ref osMessageCreate.
  * @param  info      message information.
  * @param  millisec  timeout value or 0 in case of no time-out.
  * @retval status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osMessagePut shall be consistent in every CMSIS-RTOS.
  */
osStatus osMessagePut (osMessageQId queue_id, uint32_t info, uint32_t millisec);

/**
  * @brief Get a Message or Wait for a Message from a Queue.
  * @param  queue_id  message queue ID obtained with \ref osMessageCreate.
  * @param  millisec  timeout value or 0 in case of no time-out.
  * @retval event information that includes status code.
  * @note   MUST REMAIN UNCHANGED: \b osMessageGet shall be consistent in every CMSIS-RTOS.
  */
osEvent osMessageGet (osMessageQId queue_id, uint32_t millisec);

#endif    /* Use Message Queues */

/********************   Mail Queue Management Functions  ***********************/

#if (defined (osFeature_MailQ)  &&  (osFeature_MailQ != 0)) /* Use Mail Queues */

/**
  * @brief Create a Mail Queue Definition
  * @param  name  :    name of the queue.
  * @param  queue_sz:  maximum number of messages in the queue.
  * @param  type:      data type of a single message element (for debugger).
  * @note    CAN BE CHANGED: The parameter to \b osMailQDef shall be consistent but the
  *          macro body is implementation specific in every CMSIS-RTOS.
  */
#if defined (osObjectsExternal)  // object is external
#define osMailQDef(name, queue_sz, type) \
extern struct os_mailQ_cb *os_mailQ_cb_##name \
extern osMailQDef_t os_mailQ_def_##name
#else                            // define the object
#define osMailQDef(name, queue_sz, type) \
struct os_mailQ_cb *os_mailQ_cb_##name \
osMailQDef_t os_mailQ_def_##name =  \
{ (queue_sz), sizeof (type), (&os_mailQ_cb_##name) }
#endif

/**
  * @brief Access a Mail Queue Definition
  * @param  name  :    name of the queue.
  * @note    CAN BE CHANGED: The parameter to \b osMailQ shall be consistent but the
  *          macro body is implementation specific in every CMSIS-RTOS.
  */
#define osMailQ(name)  \
&os_mailQ_def_##name

/**
  * @brief Create and Initialize mail queue
  * @param  queue_def     reference to the mail queue definition obtain with \ref osMailQ
  * @param   thread_id     thread ID (obtained by \ref osThreadCreate or \ref osThreadGetId) or NULL.
  * @retval mail queue ID for reference by other functions or NULL in case of error.
  * @note   MUST REMAIN UNCHANGED: \b osMailCreate shall be consistent in every CMSIS-RTOS.
  */
osMailQId osMailCreate (osMailQDef_t *queue_def, osThreadId thread_id);

/**
  * @brief Allocate a memory block from a mail
  * @param  queue_id      mail queue ID obtained with \ref osMailCreate.
  * @param  millisec      timeout value or 0 in case of no time-out.
  * @retval pointer to memory block that can be filled with mail or NULL in case error.
  * @note   MUST REMAIN UNCHANGED: \b osMailAlloc shall be consistent in every CMSIS-RTOS.
  */
void *osMailAlloc (osMailQId queue_id, uint32_t millisec);

/**
  * @brief Allocate a memory block from a mail and set memory block to zero
  * @param  queue_id      mail queue ID obtained with \ref osMailCreate.
  * @param  millisec      timeout value or 0 in case of no time-out.
  * @retval pointer to memory block that can be filled with mail or NULL in case error.
  * @note   MUST REMAIN UNCHANGED: \b osMailCAlloc shall be consistent in every CMSIS-RTOS.
  */
void *osMailCAlloc (osMailQId queue_id, uint32_t millisec);

/**
  * @brief Put a mail to a queue
  * @param  queue_id      mail queue ID obtained with \ref osMailCreate.
  * @param  mail          memory block previously allocated with \ref osMailAlloc or \ref osMailCAlloc.
  * @retval status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osMailPut shall be consistent in every CMSIS-RTOS.
  */
osStatus osMailPut (osMailQId queue_id, void *mail);

/**
  * @brief Get a mail from a queue
  * @param  queue_id   mail queue ID obtained with \ref osMailCreate.
  * @param millisec    timeout value or 0 in case of no time-out
  * @retval event that contains mail information or error code.
  * @note   MUST REMAIN UNCHANGED: \b osMailGet shall be consistent in every CMSIS-RTOS.
  */
osEvent osMailGet (osMailQId queue_id, uint32_t millisec);

/**
  * @brief Free a memory block from a mail
  * @param  queue_id mail queue ID obtained with \ref osMailCreate.
  * @param  mail     pointer to the memory block that was obtained with \ref osMailGet.
  * @retval status code that indicates the execution status of the function.
  * @note   MUST REMAIN UNCHANGED: \b osMailFree shall be consistent in every CMSIS-RTOS.
  */
osStatus osMailFree (osMailQId queue_id, void *mail);

#endif /* Use Mail Queues */

/*************************** Additional specific APIs to Free RTOS ************/
/**
* @brief  Suspend execution of a thread.
* @param   thread_id   thread ID obtained by \ref osThreadCreate or \ref osThreadGetId.
* @retval  status code that indicates the execution status of the function.
*/
osStatus osThreadSuspend (osThreadId thread_id);

/**
* @brief  Resume execution of a suspended thread.
* @param   thread_id   thread ID obtained by \ref osThreadCreate or \ref osThreadGetId.
* @retval  status code that indicates the execution status of the function.
*/
osStatus osThreadResume (osThreadId thread_id);

/**
* @brief  Suspend execution of a all active threads.
* @retval  status code that indicates the execution status of the function.
*/
osStatus osThreadSuspendAll (void);

/**
* @brief  Resume execution of a all suspended threads.
* @retval  status code that indicates the execution status of the function.
*/
osStatus osThreadResumeAll (void);

/**
* @brief  Check if a thread is already suspended or not.
* @param   thread_id   thread ID obtained by \ref osThreadCreate or \ref osThreadGetId.
* @retval  status code that indicates the execution status of the function.
*/
osStatus osThreadIsSuspended(osThreadId thread_id);

/**
* @brief  Delay a task until a specified time
* @param   PreviousWakeTime   Pointer to a variable that holds the time at which the 
*          task was last unblocked.
* @param   millisec    time delay value
* @retval  status code that indicates the execution status of the function.
*/
osStatus osDelayUntil (uint32_t PreviousWakeTime, uint32_t millisec);

/**
* @brief   Lists all the current threads, along with their current state 
*          and stack usage high water mark.
* @param   buffer   A buffer into which the above mentioned details
*          will be written
* @retval  status code that indicates the execution status of the function.
*/
osStatus osThreadList (int8_t *buffer);

/**
* @brief  Receive an item from a queue without removing the item from the queue.
* @param  queue_id  message queue ID obtained with \ref osMessageCreate.
* @param  millisec  timeout value or 0 in case of no time-out.
* @retval event information that includes status code.
*/
osEvent osMessagePeek (osMessageQId queue_id, uint32_t millisec);

/**
* @brief  Create and Initialize a Recursive Mutex
* @param  mutex_def     mutex definition referenced with \ref osMutex.
* @retval  mutex ID for reference by other functions or NULL in case of error..
*/
osMutexId osRecursiveMutexCreate (osMutexDef_t *mutex_def);

/**
* @brief  Release a Recursive Mutex
* @param   mutex_id      mutex ID obtained by \ref osRecursiveMutexCreate.
* @retval  status code that indicates the execution status of the function.
*/
osStatus osRecursiveMutexRelease (osMutexId mutex_id);

/**
* @brief  Release a Recursive Mutex
* @param   mutex_id    mutex ID obtained by \ref osRecursiveMutexCreate.
* @param millisec      timeout value or 0 in case of no time-out.
* @retval  status code that indicates the execution status of the function.
*/
osStatus osRecursiveMutexWait (osMutexId mutex_id, uint32_t millisec);

#ifdef  __cplusplus
}
#endif

#endif  // _CMSIS_OS_H

