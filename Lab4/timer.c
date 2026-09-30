// timer.c
// Source code for TIM15/TIM16 functions

#include "timer.h"
#include "STM32L432KC_RCC.h"

#define TIM_CLK_HZ    80000000UL
#define PRESCALED_HZ  1000000UL                            // target: 1 MHz
#define TIM_PSC_VALUE ((TIM_CLK_HZ / PRESCALED_HZ) - 1UL)  // = 79


void initTIM(TIM_TypeDef *tim) {
    RCC->AHB2ENR |= (1 << 0);  // enable clocks: GPIOA (AHB2ENR bit 0)
    RCC->APB2ENR |= (1 << 17); // TIM16EN
    RCC->APB2ENR |= (1 << 16); // TIM15EN

    // 80 MHz / (79+1) = 1 MHz tick; 1000 counts = 1 ms
    TIM15->PSC = 79;
    TIM15->ARR = 999;

    TIM15->EGR |= (1 << TIM_EGR_UG);         // load PSC/ARR now
    TIM15->SR  &= ~(1 << TIM_SR_UIF);        // clear flag set by UG
    TIM15->CR1 |= (1 << TIM_CR1_CEN);        // start counter

    // PA6 -> alternate function 14 (TIM16_CH1)
    volatile uint32_t *GPIOA_MODER = (volatile uint32_t *)(0x48000000UL + 0x00);
    volatile uint32_t *GPIOA_AFRL  = (volatile uint32_t *)(0x48000000UL + 0x20);
    *GPIOA_MODER &= ~(0b11 << (6 * 2));
    *GPIOA_MODER |=  (0b10 << (6 * 2));      // 10 = alternate function
    *GPIOA_AFRL  &= ~(0xF << (6 * 4));
    *GPIOA_AFRL  |=  (14  << (6 * 4));       // AF14

    // PWM mode 1 on channel 1 (OC1M = 110), with preload enabled
    TIM16->CCMR1 &= ~(0b111 << TIM_CCMR1_OC1M);
    TIM16->CCMR1 |=  (0b110 << TIM_CCMR1_OC1M);
    TIM16->CCMR1 |=  (1 << TIM_CCMR1_OC1PE);

    TIM16->CCER |= (1 << TIM_CCER_CC1E);     // enable channel 1 output
    TIM16->BDTR |= (1 << TIM_BDTR_MOE);      // main output enable
    TIM16->CR1  |= (1 << TIM_CR1_ARPE);      // buffer ARR
    TIM16->CR1  |= (1 << TIM_CR1_CEN);       // start counter

}


void setFrequency(TIM_TypeDef *tim, uint32_t freq_hz) {
    if (freq_hz == 0) {
        TIM16->CCR1 = 0;                     // CCR = 0 keeps the pin low (rest)
        TIM16->EGR |= (1 << TIM_EGR_UG);
        return;
    }

    uint32_t total = TIM_CLK_HZ / freq_hz;
    uint32_t psc   = total / 65536;
    uint32_t arr   = (total / (psc + 1)) - 1;

    TIM16->PSC  = psc;
    TIM16->ARR  = arr;
    TIM16->CCR1 = (arr + 1) / 2;            
    TIM16->EGR |= (1 << TIM_EGR_UG);         
}


void delay_ms(TIM_TypeDef *TIMx, uint32_t ms) {
    TIMx->SR &= ~(1 << TIM_SR_UIF);         
    while (ms-- > 0) {
        while (!(TIMx->SR & (1 << TIM_SR_UIF)));
        TIMx->SR &= ~(1 << TIM_SR_UIF);
    }
}

