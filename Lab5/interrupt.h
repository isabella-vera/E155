// Isabella Vera
// ivera@g.hmc.edu
// interrupt.h
// Encoder interrupt setup for PA8 (channel B) and PA9 (channel A)

#ifndef INTERRUPT_H
#define INTERRUPT_H

#include "main.h"


// Custom defines
#define ENCODER_A_PIN   PA9    // 5V tolerant pins
#define ENCODER_B_PIN   PA8
#define EXTI9_5_IRQ_NUM 23     // EXTI lines 5-9 share IRQ 23 in the vector table
#define TIMESTAMP_TIM   TIM2   // Free-running timer


// Types
// A consistent copy of the encoder data, taken with interrupts briefly off
typedef struct {
    int32_t  count;          // Signed edge count (1632 per revolution)
    uint32_t last_edge_time; // Timer count at the most recent valid edge
    uint32_t last_interval;  // Timer ticks between the last two valid edges
    int8_t   direction;      // +1 or -1, direction of the most recent step
} EncoderSnapshot;


// Functions
void initEncoderInterrupts(void);
EncoderSnapshot getEncoderSnapshot(void);

#endif // INTERRUPT_H