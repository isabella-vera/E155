// timer.c
// Source code for TIM15/TIM16 functions
//
// DESIGN NOTE: TIM15 and TIM16 are 16-bit timers (unlike TIM2's 32-bit
// CNT/ARR), so ARR only implements bits [15:0] -- writing anything into the
// bits above that has no effect on the actual counter, which behaves as if
// the value wrapped mod 65536. At 80 MHz with no prescaling, even the 1 ms
// duration tick needs (80,000,000/1000)-1 = 79999, which doesn't fit.
//
// Fix: give both timers the SAME fixed prescaler, dividing their 80 MHz
// input down to a clean 1 MHz. ARR alone then handles both jobs:
//   - a 1 ms tick for durations: ARR = (1,000,000/1000)-1 = 999
//   - a note's pitch:            ARR = (1,000,000/(2*freq))-1
// This keeps ARR well inside 16 bits for every frequency actually used in
// Fur Elise (262-1319 Hz gives ARR of roughly 380-1908), and is far simpler
// than recomputing PSC per note.
//
// CLOCK ASSUMPTION: TIM15/TIM16 are on APB2, not APB1. This assumes the APB2
// prescaler is left at its reset value of /1, so TIM15CLK = TIM16CLK = PCLK2
// = SYSCLK = 80 MHz (the PLL configuration from the RCC library). Confirm
// this in RM0394's RCC chapter the same way you confirmed APB1 for TIM2.

#include "timer.h"

#define TIM_CLK_HZ    80000000UL
#define PRESCALED_HZ  1000000UL                            // target: 1 MHz
#define TIM_PSC_VALUE ((TIM_CLK_HZ / PRESCALED_HZ) - 1UL)  // = 79

// Common setup for either timer: stop it, install the fixed prescaler, and
// force it to take effect immediately. Does NOT touch DIER -- whether the
// update interrupt gets enabled is decided by which function you call next
// (setFrequency enables it, delay_ms does not).
void initTIM(TIM_TypeDef *tim) {
    tim->CR1 &= ~TIM_CR1_CEN;
    tim->PSC  = TIM_PSC_VALUE;
    tim->EGR |= TIM_EGR_UG;   // load PSC now, reset CNT
    tim->SR  &= ~TIM_SR_UIF;  // clear the UIF that UG just set
}

// Configures 'tim' so its update event fires at 2*freq_hz (two toggles per
// output period) and starts it with the update interrupt enabled. The ISR
// that actually toggles the audio pin lives in main.c, since it needs to
// know which pin -- this function only arms the timer that drives it.
//
// freq_hz == 0 (rest) is NOT handled here. The caller should stop the timer
// and force the audio pin low itself, same as in the TIM2 version.
void setFrequency(TIM_TypeDef *tim, uint32_t freq_hz) {
    uint32_t arr = (PRESCALED_HZ / (2UL * freq_hz)) - 1UL;

    tim->ARR   = arr;
    tim->EGR  |= TIM_EGR_UG;
    tim->SR   &= ~TIM_SR_UIF;
    tim->DIER |= TIM_DIER_UIE;
    tim->CR1  |= TIM_CR1_CEN;
}

// Blocks for 'ms' milliseconds by polling 'tim's update flag as a free-
// running 1 kHz tick (no interrupt -- this is meant to run in the foreground
// while setFrequency's timer toggles the pin in the background via its ISR).
void delay_ms(TIM_TypeDef *tim, uint32_t ms) {
    tim->ARR  = (PRESCALED_HZ / 1000UL) - 1UL;  // 999
    tim->EGR |= TIM_EGR_UG;
    tim->SR  &= ~TIM_SR_UIF;
    tim->CR1 |= TIM_CR1_CEN;

    for (uint32_t i = 0; i < ms; i++) {
        while (!(tim->SR & TIM_SR_UIF)) { }
        tim->SR &= ~TIM_SR_UIF;
    }

    tim->CR1 &= ~TIM_CR1_CEN;
}