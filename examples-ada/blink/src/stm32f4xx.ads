with System;

package STM32F4xx is
   Flash_Base  : constant := 16#0800_0000#;
   VECT_TAB_OFFSET : constant := 16#00#;
   Peripherals : constant := 16#4000_0000#;

   type Uint8 is range 0 .. 255;
   for Uint8'Size use 8;

   type Uint32 is mod 2 ** 32;

   type UInt8_Array is array (Positive range <>) of Uint8;
   type Int_Array is array (Positive range <>) of Uint32;

   type RCC_Type is
      record
         CR         : Uint32;
         PLLCFGR    : Uint32;
         CFGR       : Uint32;
         CIR        : Uint32;
         AHB1RSTR   : Uint32;
         AHB2RSTR   : Uint32;
         AHB3RSTR   : Uint32;
         RESERVED0  : Uint32;
         APB1RSTR   : Uint32;
         APB2RSTR   : Uint32;
         RESERVED1  : Int_Array (1 .. 2);
         AHB1ENR    : Uint32;
         AHB2ENR    : Uint32;
         AHB3ENR    : Uint32;
         RESERVED2  : Uint32;
         APB1ENR    : Uint32;
         APB2ENR    : Uint32;
         RESERVED3  : Int_Array (1 .. 2);
         AHB1LPENR  : Uint32;
         AHB2LPENR  : Uint32;
         AHB3LPENR  : Uint32;
         RESERVED4  : Uint32;
         APB1LPENR  : Uint32;
         APB2LPENR  : Uint32;
         RESERVED5  : Int_Array (1 .. 2);
         BDCR       : Uint32;
         CSR        : Uint32;
         RESERVED6  : Int_Array (1 .. 2);
         SSCGR      : Uint32;
         PLLI2SCFGR : Uint32;
      end record;

   RCC : RCC_Type;

   pragma Import (ASM, RCC);

   for RCC'Address use System'To_Address (Peripherals + 16#3800#);

   type SCB_Type is
      record
         CPUID : Uint32;
         ICSR  : Uint32;
         VTOR : Uint32;
         AIRCR : Uint32;
         SCR : Uint32;
         CCR : Uint32;
         SHP : UInt8_Array (1 .. 12);
         SHCSR : Uint32;
         CFSR : Uint32;
         HFSR : Uint32;
         DFSR : Uint32;
         MMFAR : Uint32;
         BFAR : Uint32;
         AFSR : Uint32;
         PFR   : Int_Array (1 .. 2);
         DFR : Uint32;
         ADR : Uint32;
         MMFR   : Int_Array (1 .. 4);
         ISAR   : Int_Array (1 .. 5);
         RESERVED0 : Int_Array (1 .. 5);
         CPACR     : Uint32;
      end record;

   SCB : SCB_Type;

   pragma Import (ASM, SCB);

   for SCB'Address use System'To_Address (16#E000_E000# + 16#0D00#);

   type PWR_Type is
      record
         CR  : Uint32;
         CSR : Uint32;
      end record;

   PWR : PWR_Type;

   pragma Import (ASM, PWR);

   for PWR'Address use System'To_Address (Peripherals + 16#7000#);

   type Flash_Type is
      record
         ACR     : Uint32;
         KEYR    : Uint32;
         OPTKEYR : Uint32;
         SR      : Uint32;
         CR      : Uint32;
         OPTCR   : Uint32;
      end record;

   Flash : Flash_Type;

   pragma Import (ASM, Flash);

   for Flash'Address use System'To_Address (Flash_Base);

   RCC_CR_HSEON  : constant := 16#0001_0000#;
   RCC_CR_HSERDY : constant := 16#0002_0000#;
   RCC_CR_PLLON  : constant := 16#0100_0000#;
   RCC_CR_PLLRDY : constant := 16#0200_0000#;

   HSE_STARTUP_TIMEOUT : constant := 16#0500#;

   RESET : constant := 0;
   SET   : constant := 16#FFFF_FFFF#;

   RCC_APB1ENR_PWREN :  constant := 16#1000_0000#;

   RCC_CFGR_HPRE_DIV1 : constant := 16#0000_0000#;
   RCC_CFGR_HPRE_DIV2 : constant := 16#0000_0080#;
   RCC_CFGR_HPRE_DIV4 : constant := 16#0000_0090#;
   RCC_CFGR_HPRE_DIV8 : constant := 16#0000_00A0#;

   RCC_CFGR_PPRE1_DIV4 : constant := 16#0000_1400#;

   RCC_CFGR_PPRE2_DIV2 : constant := 16#0000_8000#;
   RCC_CFGR_PPRE2_DIV4 : constant := 16#0000_A000#;

   RCC_PLLCFGR_PLLSRC_HSE : constant := 16#0040_0000#;

   FLASH_ACR_LATENCY_5WS : constant := 16#0000_0005#;

   FLASH_ACR_ICEN : constant := 16#0000_0200#;
   FLASH_ACR_DCEN : constant := 16#0000_0400#;

   RCC_CFGR_SW : constant := 16#0000_0003#;

   RCC_CFGR_SW_PLL  : constant := 16#0000_0008#;

   RCC_CFGR_SWS : constant := 16#0000_000C#;

   RCC_CFGR_SWS_PLL : constant := 16#0000_0008#;

   PWR_CR_VOS : constant := 16#4000#;

   procedure Initialise;
   pragma Export (ASM, Initialise, "SystemInit");

   procedure Set_Clock;
end STM32F4xx;
