// timer.h
// Header for TIM15/TIM16 functions


#ifndef STM32L4_TIM_H
#define STM32L4_TIM_H

#include <stdint.h>

#define __IO volatile

///////////////////////////////////////////////////////////////////////////////
// Base addresses
///////////////////////////////////////////////////////////////////////////////

#define TIM15_BASE (0x40014000UL)
#define TIM16_BASE (0x40014400UL)

///////////////////////////////////////////////////////////////////////////////
// Bit position defines
///////////////////////////////////////////////////////////////////////////////

#define TIM_CR1_CEN  (1UL << 0)  // Counter enable, CR1 bit 0
#define TIM_DIER_UIE (1UL << 0)  // Update interrupt enable, DIER bit 0
#define TIM_SR_UIF   (1UL << 0)  // Update interrupt flag, SR bit 0
#define TIM_EGR_UG   (1UL << 0)  // Update generation, EGR bit 0

///////////////////////////////////////////////////////////////////////////////
// Register struct
///////////////////////////////////////////////////////////////////////////////

typedef struct {
    __IO uint32_t CR1;     // 0x00
    __IO uint32_t CR2;     // 0x04
    __IO uint32_t SMCR;    // 0x08
    __IO uint32_t DIER;    // 0x0C
    __IO uint32_t SR;      // 0x10
    __IO uint32_t EGR;     // 0x14
    __IO uint32_t CCMR1;   // 0x18
    __IO uint32_t CCMR2;   // 0x1C 
    __IO uint32_t CCER;    // 0x20
    __IO uint32_t CNT;     // 0x24
    __IO uint32_t PSC;     // 0x28
    __IO uint32_t ARR;     // 0x2C
} TIM_TypeDef;

#define TIM15 ((TIM_TypeDef *) TIM15_BASE)
#define TIM16 ((TIM_TypeDef *) TIM16_BASE)

///////////////////////////////////////////////////////////////////////////////
// Function prototypes
///////////////////////////////////////////////////////////////////////////////

void initTIM(TIM_TypeDef *tim);
void setFrequency(TIM_TypeDef *tim, uint32_t freq_hz);
void delay_ms(TIM_TypeDef *tim, uint32_t ms);

#endif