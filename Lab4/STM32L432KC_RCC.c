// STM32L432KC_RCC.c
// Source code for RCC functions

#include "STM32L432KC_RCC.h"

void configurePLL() {
    // Set clock to 80 MHz
    // Output freq = (src_clk) * (N/M) / R
    // (4 MHz) * (N/M) / R = 80 MHz
    // M: 1, N: 40, R: 2
    // Use MSI as PLLSRC

    // Turn off PLL
    RCC->CR &= ~(1 << 24);

    // Wait until PLL is unlocked (e.g. off)
    while(RCC->CR & (1 << 25));

    // Load configuration
    // Set PLL SRC to MSI
    RCC->PLLCFGR &= ~(0b11 << 0);
    RCC->PLLCFGR |= (0b01 << 0);


    // Set PLLN
    // VCO output frequency = VCO input frequency x PLLN with 8 =< PLLN =< 86
    RCC->PLLCFGR &= ~(0b1111111 << 8);
    RCC->PLLCFGR |= (40 << 8);


    // Set PLLM
    // VCO input frequency = PLL input clock frequency / PLLM with 1 <= PLLM <= 8
    RCC->PLLCFGR &= ~(0b111 << 4);
    RCC->PLLCFGR |= (0 << 4);
    

    // Set PLLR
    // PLLCLK output clock frequency = VCO frequency / PLLR with PLLR = 2, 4, 6, or 8
    RCC->PLLCFGR &= ~(0b11 << 25);
    RCC->PLLCFGR |= (0b00 << 25);

    
    // Enable PLLR output
    RCC->PLLCFGR |= (1 << 24);
    

    // Enable PLL
    RCC->CR |= (1 << 24);
    
    // Wait until PLL is locked
    while(!(RCC->CR & (1 << 25)));
}

void configureClock(){
    // Configure and turn on PLL
    configurePLL();

    // Select PLL as clock source
    RCC->CFGR |= (0b11 << 0);
    while(!((RCC->CFGR >> 2) & 0b11));
}