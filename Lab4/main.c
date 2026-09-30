/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************

-------------------------- END-OF-HEADER -----------------------------

*/

#include <stdint.h>
#include "STM32L432KC_RCC.h"
#include "STM32L432KC_FLASH.h"
#include "STM32L432KC_GPIO.h"
#include "timer.h"

#define AUDIO_PIN 6  // PA6

#define TIM1_UP_TIM16_IRQn 25u
#define NVIC_ISER0 (*(volatile uint32_t *)0xE000E100UL)

// TIM15/TIM16 are on APB2
#define RCC_APB2ENR_TIM15EN (1UL << 16)
#define RCC_APB2ENR_TIM16EN (1UL << 17)

// Pitch in Hz, duration in ms
/*
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
*/


const int notes[][2] = {
    // Twinkle, twinkle, little star
    {262, 125}, // C
    {262, 125}, // C
    {392, 125}, // G
    {392, 125}, // G
    {440, 125}, // A
    {440, 125}, // A
    {392, 250}, // G
    {  0, 125}, // Rest

    // How I wonder what you are
    {349, 125}, // F
    {349, 125}, // F
    {330, 125}, // E
    {330, 125}, // E
    {294, 125}, // D
    {294, 125}, // D
    {262, 250}, // C
    {  0, 125}, // Rest

    // Up above the world so high
    {392, 125}, // G
    {392, 125}, // G
    {349, 125}, // F
    {349, 125}, // F
    {330, 125}, // E
    {330, 125}, // E
    {294, 250}, // D
    {  0, 125}, // Rest

    // Like a diamond in the sky
    {392, 125}, // G
    {392, 125}, // G
    {349, 125}, // F
    {349, 125}, // F
    {330, 125}, // E
    {330, 125}, // E
    {294, 250}, // D
    {  0, 125}, // Rest

    // Twinkle, twinkle, little star
    {262, 125}, // C
    {262, 125}, // C
    {392, 125}, // G
    {392, 125}, // G
    {440, 125}, // A
    {440, 125}, // A
    {392, 250}, // G
    {  0, 125}, // Rest

    // How I wonder what you are
    {349, 125}, // F
    {349, 125}, // F
    {330, 125}, // E
    {330, 125}, // E
    {294, 125}, // D
    {294, 125}, // D
    {262, 250}  // C
};



void TIM1_UP_TIM16_IRQHandler(void) {
    if (TIM16->SR & TIM_SR_UIF) {
        TIM16->SR &= ~TIM_SR_UIF;
        GPIO->ODR ^= (1UL << AUDIO_PIN);
    }
}

// Starts/stops TIM16 for the given note
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

        playPitch(freq);       // toggles the pin in the background
        delay_ms(TIM15, dur);  // blocks in the foreground for this note's length

        i++;
    }

    // Song finished: silence output and halt.
    TIM16->CR1 &= ~TIM_CR1_CEN;
    GPIO->ODR &= ~(1UL << AUDIO_PIN);
    while (1) { }
}

/*************************** End of file ****************************/