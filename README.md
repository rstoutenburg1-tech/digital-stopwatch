# FPGA Digital Stopwatch

A Verilog digital stopwatch for a 100 MHz FPGA board with a four-digit,
seven-segment display. The display format is `M:SS.t` (minutes, seconds, and
tenths of a second).

## Features

- Count up or count down
- Start, stop, and clear controls
- Lap display hold while counting continues
- Time-setting mode with a faster adjustment tick
- Blinking display at the terminal count
- Multiplexed four-digit seven-segment output

## FSM logic

The stopwatch behavior is controlled by the finite-state machine in
`fsm_counter.v`:

| State | Purpose | Main transitions |
| --- | --- | --- |
| `IDLE` | Stopwatch is stopped; `clear` resets the stored time. | `start` enters `RUN_UP` or `RUN_DOWN`; `set_time` enters `SET`. |
| `RUN_UP` | Counts upward once per slow tick. | `stop` returns to `IDLE`; `lap` enters `S_L`; the terminal count enters `BLINK`. |
| `RUN_DOWN` | Counts downward once per slow tick. | `stop` returns to `IDLE`; zero enters `BLINK`. |
| `S_L` | Holds the displayed lap value while the internal counter continues upward. | `start` returns to `RUN_UP`; `stop` returns to `IDLE`. |
| `BLINK` | Signals the display module to flash the digits. | `start` resumes counting; `stop` returns to `IDLE`. |
| `SET` | Chooses the direction used to adjust the preset time. | Holding `start` enters `SET_UP` or `SET_DOWN`; releasing `set_time` returns to `IDLE`. |
| `SET_UP` | Increases the preset time using the fast tick. | Releasing `start` returns to `IDLE`. |
| `SET_DOWN` | Decreases the preset time using the fast tick. | Releasing `start` returns to `IDLE`. |

The time is stored as four BCD-style digits: one minute digit, tens of
seconds, seconds, and tenths. Carry and borrow logic rolls the display through
the valid ranges for each digit.

## Files

- `stopwatchtop.v` — top-level module connecting timing, FSM/counter, and display logic.
- `fsm_counter.v` — stopwatch state machine, BCD counters, lap hold, and blink-state output.
- `clockdivider.v` — divides the 100 MHz input clock into a 10 Hz tick for tenths of a second.
- `clockdivider2.v` — produces a 100 Hz tick for faster time adjustment.
- `display.v` — multiplexes the four digits, drives decimal points, and implements blinking.
- `sevensegdecoder.v` — converts decimal digit values to active-low seven-segment patterns.
- `Lab10_Constraint.xdc` — FPGA pin assignments and the 100 MHz clock constraint.
- `Lab10_Stopwatch_Level4.zip` — archive of the original submitted source files.

## Using the project

1. Create a Vivado RTL project and add all `.v` files as design sources.
2. Add `Lab10_Constraint.xdc` as the constraints file.
3. Select `stopwatch_top` as the top module.
4. Choose the FPGA board/device that matches the pin assignments in the XDC
   file, then run synthesis, implementation, and bitstream generation.

## Notes

- The clock-divider constants assume a 100 MHz input clock.
- The seven-segment outputs and digit enables are active low.
- Mechanical buttons and switches are connected directly; hardware debouncing
  or input synchronization can be added if required by the target board.

