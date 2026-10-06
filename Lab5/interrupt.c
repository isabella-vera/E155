// Isabella Vera
// ivera@g.hmc.edu
// interrupt.c
// Encoder interrupt setup and handler for PA8 (channel B) and PA9 (channel A)

#include "interrupt.h"

#define ENCODER_EXTI_MASK ((1 << gpioPinOffset(ENCODER_A_PIN)) | (1 << gpioPinOffset(ENCODER_B_PIN))) // create mask


static const int8_t transition_table[16] = {
     0, +1, -1, 0,   // previous 00
    -1,  0, 0, +1,   // previous 01
    +1,  0, 0, -1,   // previous 10
     0, -1, +1, 0    // previous 11
};

// shared with main (accessed only through getEncoderSnapshot)
static volatile int32_t  encoder_count    = 0;
static volatile uint32_t last_edge_time   = 0;
static volatile uint32_t last_interval    = 0;
static volatile int8_t   last_direction   = 0;

// used only by the ISR
static uint8_t prev_state = 0;

static uint8_t readEncoderState(void) {
    uint32_t idr = GPIOA->IDR; // read both pins
    uint8_t a = (idr >> gpioPinOffset(ENCODER_A_PIN)) & 1;
    uint8_t b = (idr >> gpioPinOffset(ENCODER_B_PIN)) & 1;
    return (a << 1) | b;
}

void initEncoderInterrupts(void) {
    // enable encoder channels as inputs
    gpioEnable(GPIO_PORT_A);
    pinMode(ENCODER_A_PIN, GPIO_INPUT);
    pinMode(ENCODER_B_PIN, GPIO_INPUT);

    // start from the real pin state 
    prev_state = readEncoderState();
    last_edge_time = TIMESTAMP_TIM->CNT;

    // 1. Enable SYSCFG clock domain in RCC
    RCC->APB2ENR |= (1 << 0); // SYSCFGEN

    // 2. EXTI8 is bits 3:0 and EXTI9 is bits 7:4 of EXTICR[2]; port A is 0b0000
    SYSCFG->EXTICR[2] &= ~(0b1111 << 0);
    SYSCFG->EXTICR[2] &= ~(0b1111 << 4);

    // Rising and falling edges on both pins 
    EXTI->IMR1  |= ENCODER_EXTI_MASK;
    EXTI->RTSR1 |= ENCODER_EXTI_MASK;
    EXTI->FTSR1 |= ENCODER_EXTI_MASK;
    NVIC->ISER[0] |= (1 << EXTI9_5_IRQ_NUM);

    __enable_irq();
}

// EXTI lines 5-9 share this handler, so PA8 and PA9 both land here
void EXTI9_5_IRQHandler(void) {
    uint32_t pending = EXTI->PR1 & ENCODER_EXTI_MASK; // nonzero when at least one of the pins is triggered
    if (pending) {
        EXTI->PR1 = pending;                          // clear first (write 1 to reset)
        uint32_t now = TIMESTAMP_TIM->CNT;            // timestamp at this edge
        uint8_t curr_state = readEncoderState();      // get current pin values
        int8_t step = transition_table[(prev_state << 2) | curr_state]; // get step value from the table

        if (step != 0) {
            encoder_count += step;
            last_direction = step;
            last_interval = now - last_edge_time; // unsigned math handles wraparound
            last_edge_time = now;
        }
        prev_state = curr_state;
    }
}


EncoderSnapshot getEncoderSnapshot(void) {  // to turn off interrupts while we get values
    EncoderSnapshot snap;
    __disable_irq();                        // keep the ISR from changing data mid-copy
    snap.count          = encoder_count;
    snap.last_edge_time = last_edge_time;
    snap.last_interval  = last_interval;
    snap.direction      = last_direction;
    __enable_irq();
    return snap;
}