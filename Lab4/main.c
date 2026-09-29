/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

File    : main.c
Purpose : Fur Elise player, E155 Lab 4

*/

#include <stdint.h>
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_FLASH.h"
#include "STM32L432KC_GPIO.h"
#include "timer.h"

#define AUDIO_PIN 6  // PA6

// --- VERIFY BEFORE TRUSTING: these two blocks were looked up from public
// register-map references, not read directly from your copy of RM0394.
// Cross-check both against your manual before you rely on them.

// TIM15 and TIM16 share interrupt lines with TIM1 on this chip -- there is
// no standalone "TIM16" line. The vector table entry TIM16's update event
// fires on is named TIM1_UP_TIM16. This IRQ number carries over the same
// numbering pattern you already used for TIM2 (28) earlier in this project;
// confirm it against your own vector table.
#define TIM1_UP_TIM16_IRQn 25u
#define NVIC_ISER0 (*(volatile uint32_t *)0xE000E100UL)

// TIM15/TIM16 are on APB2 (not APB1, where TIM2 lived), so their enable
// bits are in a different register: RCC->APB2ENR.
#define RCC_APB2ENR_TIM15EN (1UL << 16)
#define RCC_APB2ENR_TIM16EN (1UL << 17)

// Pitch in Hz, duration in ms
const int notes[][2] = {
{659,	125},
{623,	125},
{659,	125},
{623,	125},
{659,	125},
{494,	125},
{587,	125},
{523,	125},
{440,	250},
{  0,	125},
{262,	125},
{330,	125},
{440,	125},
{494,	250},
{  0,	125},
{330,	125},
{416,	125},
{494,	125},
{523,	250},
{  0,	125},
{330,	125},
{659,	125},
{623,	125},
{659,	125},
{623,	125},
{659,	125},
{494,	125},
{587,	125},
{523,	125},
{440,	250},
{  0,	125},
{262,	125},
{330,	125},
{440,	125},
{494,	250},
{  0,	125},
{330,	125},
{523,	125},
{494,	125},
{440,	250},
{  0,	125},
{494,	125},
{523,	125},
{587,	125},
{659,	375},
{392,	125},
{699,	125},
{659,	125},
{587,	375},
{349,	125},
{659,	125},
{587,	125},
{523,	375},
{330,	125},
{587,	125},
{523,	125},
{494,	250},
{  0,	125},
{330,	125},
{659,	125},
{  0,	250},
{659,	125},
{1319,	125},
{  0,	250},
{623,	125},
{659,	125},
{  0,	250},
{623,	125},
{659,	125},
{623,	125},
{659,	125},
{623,	125},
{659,	125},
{494,	125},
{587,	125},
{523,	125},
{440,	250},
{  0,	125},
{262,	125},
{330,	125},
{440,	125},
{494,	250},
{  0,	125},
{330,	125},
{416,	125},
{494,	125},
{523,	250},
{  0,	125},
{330,	125},
{659,	125},
{623,	125},
{659,	125},
{623,	125},
{659,	125},
{494,	125},
{587,	125},
{523,	125},
{440,	250},
{  0,	125},
{262,	125},
{330,	125},
{440,	125},
{494,	250},
{  0,	125},
{330,	125},
{523,	125},
{494,	125},
{440,	500},
{  0,	0}};

// TIM16's update-event ISR: fires every ARR+1 prescaled ticks, toggles the
// audio pin -- this is what actually generates each note's square wave.
// The name MUST match your startup file's vector table entry for
// TIM1_UP_TIM16 exactly, or it silently falls through to the default
// handler and nothing will toggle (a good thing to single-step and confirm
// the first time this runs).
void TIM1_UP_TIM16_IRQHandler(void) {
    if (TIM16->SR & TIM_SR_UIF) {
        TIM16->SR &= ~TIM_SR_UIF;
        GPIO->ODR ^= (1UL << AUDIO_PIN);
    }
}

// Starts/stops TIM16 for the given note. freq_hz == 0 is a rest: stop the
// timer (so the ISR can't fire) and force the pin low directly.
static void playPitch(uint32_t freq_hz) {
    if (freq_hz == 0) {
        TIM16->CR1 &= ~TIM_CR1_CEN;
        GPIO->ODR &= ~(1UL << AUDIO_PIN);
        return;
    }
    setFrequency(TIM16, freq_hz);
}

int main(void) {
    // Bring the clock up to 80 MHz: wait states first, then the PLL switch.
    configureFlash();
    configureClock();

    // GPIOA clock, audio pin as push-pull output, start silent.
    RCC->AHB2ENR |= (1 << 0);  // GPIOAEN
    pinMode(AUDIO_PIN, GPIO_OUTPUT);
    GPIO->ODR &= ~(1UL << AUDIO_PIN);

    // TIM15 (duration) and TIM16 (pitch) clocks.
    RCC->APB2ENR |= RCC_APB2ENR_TIM15EN | RCC_APB2ENR_TIM16EN;

    initTIM(TIM15);
    initTIM(TIM16);

    NVIC_ISER0 |= (1UL << TIM1_UP_TIM16_IRQn);

    int i = 0;
    while (1) {
        uint32_t freq = (uint32_t)notes[i][0];
        uint32_t dur  = (uint32_t)notes[i][1];

        if (dur == 0) break;  // end of song

        playPitch(freq);       // TIM16 ISR toggles the pin in the background
        delay_ms(TIM15, dur);  // blocks in the foreground for this note's length

        i++;
    }

    // Song finished: silence output and halt.
    TIM16->CR1 &= ~TIM_CR1_CEN;
    GPIO->ODR &= ~(1UL << AUDIO_PIN);
    while (1) { }
}

/*************************** End of file ****************************/
