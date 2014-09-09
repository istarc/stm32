with Interfaces;

package body STM32F4xx is
   use type Interfaces.Unsigned_32;

   PLL_M : constant := 25;
   PLL_N : constant := 226;
   PLL_P : constant := 2;
   PLL_Q : constant := 7;

   procedure Initialise is
   begin
      --  FPU settings
      --  Reset the RCC clock configuration to the default reset state.
      --  Set HSION bit.
      RCC.CR := RCC.CR or 16#0000_0001#;

      --  Reset CFGR register.
      RCC.CFGR := 16#0000_0000#;

      --  Reset HSEON, CSSON and PLLON bits.
      RCC.CR := RCC.CR and 16#FEF6_FFFF#;

      --  Reset PLLCFGR register.
      RCC.PLLCFGR := 16#2400_3010#;

      --  Reset HSEBYP bit.
      RCC.CR := RCC.CR and 16#FFFB_FFFF#;

      --  Disable all interrupts.
      RCC.CIR := 16#0000_0000#;

--  #ifdef DATA_IN_ExtSRAM
--        SystemInit_ExtMemCtl();
--  #endif /* DATA_IN_ExtSRAM */

      --  Configure the System clock source, PLL Multiplier and Divider
      --  factors, AHB/APBx prescalers and Flash settings.
      Set_Clock;

      --  Configure the Vector Table location add offset address.
      --  #ifdef VECT_TAB_SRAM
      --   Vector Table Relocation in Internal SRAM
--    SCB->VTOR = SRAM_BASE | VECT_TAB_OFFSET;
--  #else
      --  Vector Table Relocation in Internal FLASH.
      SCB.VTOR := Flash_Base or VECT_TAB_OFFSET;
--  #endif
   end Initialise;

   procedure Set_Clock is
      Counter     : Integer := 0;
      HSE_Status : Uint32 := 0;
   begin
      --  Enable HSE.
      RCC.CR := RCC.CR or RCC_CR_HSEON;

      --  Wait till HSE is ready and if Time out is reached exit.
      loop
         HSE_Status := RCC.CR and RCC_CR_HSERDY;
         Counter   := Counter + 1;
         exit when HSE_Status = 0 and Counter /= HSE_STARTUP_TIMEOUT;
      end loop;

      if (RCC.CR and RCC_CR_HSERDY) /= RESET then
         HSE_Status := 1;
      else
         HSE_Status := 0;
      end if;

      if HSE_Status = 1 then
         --  Select regulator voltage output Scale 1 mode, System frequency up
         --  to 168 MHz.
         RCC.APB1ENR := RCC.APB1ENR or RCC_APB1ENR_PWREN;
         PWR.CR := PWR.CR or PWR_CR_VOS;

         --  HCLK = SYSCLK / 1.
         RCC.CFGR := RCC.CFGR or RCC_CFGR_HPRE_DIV1;

         --  PCLK2 = HCLK / 2.
         RCC.CFGR := RCC.CFGR or RCC_CFGR_PPRE2_DIV2;

         --  PCLK1 = HCLK / 4.
         RCC.CFGR := RCC.CFGR or RCC_CFGR_PPRE1_DIV4;

         --  Configure the main PLL.
         RCC.PLLCFGR :=
           Uint32 (PLL_M or
                     Interfaces.Shift_Left
                     (Interfaces.Unsigned_32 (PLL_N), 6) or
                     Interfaces.Shift_Left
                     (Interfaces.Shift_Right
                        (Interfaces.Unsigned_32 (PLL_P),
                         1) - 1, 16) or
                     RCC_PLLCFGR_PLLSRC_HSE or
                     Interfaces.Shift_Left
                     (Interfaces.Unsigned_32 (PLL_Q), 24));

         --  Enable the main PLL.
         RCC.CR := RCC.CR or RCC_CR_PLLON;

         --  Wait till the main PLL is ready.
         loop
            exit when (RCC.CR and RCC_CR_PLLRDY) = 0;
         end loop;

         --  Configure Flash prefetch, Instruction cache, Data cache and wait
         --  state.
         Flash.ACR := FLASH_ACR_ICEN or FLASH_ACR_DCEN or
           FLASH_ACR_LATENCY_5WS;

         --  Select the main PLL as system clock source.
         RCC.CFGR := RCC.CFGR and not RCC_CFGR_SW;
         RCC.CFGR := RCC.CFGR or RCC_CFGR_SW_PLL;

         --  Wait till the main PLL is used as system clock source.
         loop
            exit when (RCC.CFGR and RCC_CFGR_SWS) /= RCC_CFGR_SWS_PLL;
         end loop;
      else
         --  If HSE fails to start-up, the application will have wrong clock
         --  configuration. User can add here some code to deal with this
         --  error.
         null;
      end if;
   end Set_Clock;
end STM32F4xx;
