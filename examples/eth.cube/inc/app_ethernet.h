/**
  ******************************************************************************
  * @file    LwIP/LwIP_TCP_Echo_Client/Inc/app_ethernet.h 
  * @author  MCD Application Team
  * @version V1.1.0
  * @date    26-June-2014
  * @brief   Header for app_ethernet.c module
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

/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __APP_ETHERNET_H
#define __APP_ETHERNET_H

#ifdef __cplusplus
 extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "lwip/netif.h"

/* Exported types ------------------------------------------------------------*/
/* Exported constants --------------------------------------------------------*/   
/* Exported macro ------------------------------------------------------------*/
/* Exported functions ------------------------------------------------------- */
void User_notification(struct netif *netif);

#ifdef __cplusplus
}
#endif

#endif /* __APP_ETHERNET_H */


/************************ (C) COPYRIGHT STMicroelectronics *****END OF FILE****/

