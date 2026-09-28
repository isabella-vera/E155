// main.c
// Bring-up test for the RCC, FLASH, and GPIO libraries (no timers needed).
//
// What it does:
//   Phase 1: blink PIN at the reset-default 4 MHz clock (slow).
//   Phase 2: call configureFlash() + configureClock(), then blink with the
//            exact same delay loop (should be much faster if the PLL works).
//
// How to read the result (scope or logic analyzer on PIN, or an LED):
//   - Phase 2 period ~ 1/20 of phase 1 (roughly; flash wait states make the
//     ratio a bit less than exactly 20)  -> clock switch worked.
//   - Blinking stops after phase 1       -> chip hung in configureFlash/
//                                            configureClock (check PLL setup,
//                                            wait states, lock/SWS loops).
//   - Phase 2 same speed as phase 1      -> clock never changed (or the
//                                            switch bits weren't set).

//#include "STM32L432KC_RCC.h"
//#include "STM32L432KC_FLASH.h"
//#include "STM32L432KC_GPIO.h"

//#define PIN 6  // PA6 (change to whatever pin you have wired up)

//// Crude software delay: same loop count in both phases, so any change in
//// blink rate comes from the clock, not the code.
//static void crudeDelay(void) {
//    for (volatile int i = 0; i < 400000; i++) { }
//}

//int main(void) {
//    // GPIOA's bus clock must be on before touching its registers.
//    // (Bit 0 of AHB2ENR is GPIOAEN -- confirm in RM0394.)
//    RCC->AHB2ENR |= (1 << 0);

//    pinMode(PIN, GPIO_OUTPUT);

//    // Phase 1: default 4 MHz clock, slow blink
//    for (int n = 0; n < 10; n++) {
//        togglePin(PIN);
//        crudeDelay();
//    }

//    // Raise the clock: flash wait states FIRST, then the PLL switch
//    configureFlash();
//    configureClock();

//    // Phase 2: same loop, should now run much faster
//    while (1) {
//        togglePin(PIN);
//        crudeDelay();
//    }
//}

// main_gpio_test.c
// Minimal GPIO sanity test: drive PA6 high and hold it there.
// No clock changes, no timers, no delay loops.
//
// Expected result: PA6 measures ~3.3 V (multimeter, or scope in DC coupling).
//   ~3.3 V -> GPIO clock enable, pinMode, and the GPIO macro are all fine.
//   ~0 V or floating/noisy -> problem in GPIO setup, pin number, or probe.

#include "STM32L432KC_RCC.h"
#include "STM32L432KC_GPIO.h"

#define PIN 5  // PA6

int main(void) {
    // Turn on GPIOA's bus clock (bit 0 of AHB2ENR; confirm in RM0394)
    RCC->AHB2ENR |= (1 << 0);

    pinMode(PIN, GPIO_OUTPUT);

    // Write ODR directly instead of digitalWrite, which ignores its 'val' argument
    GPIO->ODR |= (1 << PIN);

    while (1) { }
}
