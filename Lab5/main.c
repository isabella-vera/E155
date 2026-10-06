// Isabella Vera
// ivera@g.hmc.edu
// main.c
// Lab 5: Quadrature encoder velocity measurement

#include <stdio.h>
#include "main.h"
#include "interrupt.h"


// DEFINES
#define TIMER_TICK_HZ        1000000                  // timestamp tick rate (1 MHz = 1 us)
#define TIMER_MAX_COUNT      0xFFFFFFFF               // TIM2 is 32 bits wide
#define UPDATE_PERIOD_TICKS  (1 * TIMER_TICK_HZ)      // get it to update once per second

#define PULSES_PER_REV       408                      // from the motor spec (408 for 150 rpm or 120 for 600 rpm)
#define EDGES_PER_PULSE      4                        // rising and falling edges of both signals
#define COUNTS_PER_REV       (PULSES_PER_REV * EDGES_PER_PULSE)  // 1632 or 480

#define WINDOW_MIN_COUNTS    50                       // at or above this, use the window method
#define ZERO_TIMEOUT_TICKS   (2 * TIMER_TICK_HZ)      // no edge after this long means the motor is stopped

#define DIR_POSITIVE_LABEL   "CW"                     
#define DIR_NEGATIVE_LABEL   "CCW"


// from tutorial to set up printf
int _write(int file, char *ptr, int len) {
    int i;
    for (i = 0; i < len; i++) {
        ITM_SendChar(*ptr++);
    }
    return len;
}

// timestamp timer: always running, no interrupts
static void initTimestampTimer(void) {
    RCC->APB1ENR1 |= RCC_APB1ENR1_TIM2EN;                       // enable timer clock
    TIMESTAMP_TIM->PSC = (SystemCoreClock / TIMER_TICK_HZ) - 1; // prescale to 1 MHz tick
    TIMESTAMP_TIM->ARR = TIMER_MAX_COUNT;                       // use all 32 bits
    TIMESTAMP_TIM->EGR |= TIM_EGR_UG;                           // load the prescaler
    TIMESTAMP_TIM->CR1 |= TIM_CR1_CEN;                          // starts counting
}


// VELOCITY CALCULATIONS
// state carried from one update to the next
static int32_t  prev_count;
static uint32_t prev_time;

// computeSpeed to convert an encoder snapshot into a speed in rev/s with direction (CW/CCW)
//    input: snap is the snapshot taken just before "now" was read
//    input: now is the timer count read AFTER the snapshot
//    return: rev/s, positive when the direction is +1 

static float computeSpeed(EncoderSnapshot snap, uint32_t now) {
    int32_t  delta_count  = snap.count - prev_count;
    uint32_t window_ticks = now - prev_time;
    uint32_t since_edge   = now - snap.last_edge_time;
    float    speed;

    prev_count = snap.count;
    prev_time  = now;

    int32_t abs_delta = (delta_count < 0) ? -delta_count : delta_count;

    if (abs_delta >= WINDOW_MIN_COUNTS) {
        // frequency method: net counts over the measured window length
        // for HIGH speeds
        speed = (float)delta_count * TIMER_TICK_HZ /
                ((float)COUNTS_PER_REV * (float)window_ticks);
    } else if (snap.last_interval == 0 || since_edge > ZERO_TIMEOUT_TICKS) {
        // no valid interval yet, or no edge for too long: stopped
        // speed ZERO
        speed = 0.0f;
    } else {
        // period method: one step per interval. if the motor has slowed since
        // the last edge, the time since that edge is the better estimate
        // for LOW speeds
        uint32_t period = (since_edge > snap.last_interval) ? since_edge
                                                            : snap.last_interval;
        speed = (float)snap.direction * TIMER_TICK_HZ /
                ((float)COUNTS_PER_REV * (float)period);
    }
    return speed;
}


// main function
int main(void) {
  // initialize and verify
  printf("Before: SystemCoreClock = %lu Hz\n", (unsigned long)SystemCoreClock); // check default startup clk

  configureFlash();   // change waitstates to 4 so 80MHz doesn't make it all crash out
  configureClock();   // should get to 80 MHz

  printf("After:  SystemCoreClock = %lu Hz\n", (unsigned long)SystemCoreClock); // check that we configured the clk right

  // the timer must be running before the encoder interrupts are enabled
  initTimestampTimer();
  initEncoderInterrupts();

  // starting point for the first update window
  EncoderSnapshot start = getEncoderSnapshot();
  prev_count = start.count;
  prev_time  = TIMESTAMP_TIM->CNT;

  uint32_t last_update = prev_time;

  // always looping
  while (1) {
    if ((TIMESTAMP_TIM->CNT - last_update) >= UPDATE_PERIOD_TICKS) {
      EncoderSnapshot snap = getEncoderSnapshot();
      uint32_t now = TIMESTAMP_TIM->CNT;   // read AFTER the snapshot
      last_update = now;

      float speed = computeSpeed(snap, now);

      if (speed == 0.0f) {
          printf("STOPPED  0.000 rev/s\n");
      } else {
          const char *dir = (speed > 0.0f) ? DIR_POSITIVE_LABEL : DIR_NEGATIVE_LABEL;
          float mag = (speed > 0.0f) ? speed : -speed;
          printf("%s  %.3f rev/s\n", dir, mag);
      }
    }
  }
}