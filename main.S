
# Use Cortex-M0+ assembly
.cpu cortex-m0plus
# 16 bit mode
.thumb

# Data section definition, used for linking
.data

# Delay between turning the led on or off in us.
.equ DELAY, 10000

# XOSC = Crystal Oscillator
# Base address of peripheral.
.equ XOSC_BASE_ADDR, 0x40024000
# Control register offset.
.equ XOSC_CTRL_OFFSET, 0
# Status register offset.
.equ XOSC_STATUS_OFFSET, 0x04
# Startup register offset.
.equ XOSC_STARTUP_OFFSET, 0x0c

# Frequency value, it translates to 1.15MHz and is the only currently supported value.
.equ XOSC_FREQ, 0xaa0
# Enable magic value, a magic value is used to prevent accidental shut off of the main
# oscillator while in use. Any value but the disable value enables the oscillator.
.equ XOSC_ENABLE_VAL, (0xfab << 12 | XOSC_FREQ)
# Pre calculated value from the documentation chapter: 2.16.3.
# With a 12 MHz crystal it equals about 1ms of wait time.
# Waiting is required for proper initialization due to the oscillators needing time
# to reach sufficient amplitude for the output frequency.
.equ XOSC_STATUP_DELAY, 47
# Status bit, tells the program if the oscillator is ready to be used.
.equ XOSC_STATUS_MASK, 1 << 31

# Control register memory address.
.equ XOSC_CTRL, (XOSC_BASE_ADDR + XOSC_CTRL_OFFSET)
# Startup register memory address.
.equ XOSC_STARTUP, (XOSC_BASE_ADDR + XOSC_STARTUP_OFFSET)
# Status register memory address.
.equ XOSC_STATUS, (XOSC_BASE_ADDR + XOSC_STATUS_OFFSET)

# Base address of peripheral.
.equ CLOCKS_BASE_ADDR, 0x40008000
# Reference clock control register offset.
# This is used to change clock sources during operation, with or without glitching.
.equ CLOCKS_REF_CTRL_OFFSET, 0x30

# Reference clock control register memory address.
.equ CLOCKS_REF_CTRL, (CLOCKS_BASE_ADDR + CLOCKS_REF_CTRL_OFFSET)

# Vlaue for setting the clock reference to the crystal oscillator
.equ CLOCKS_SET_XOSC_VAL, 0x2

# Base address of peripheral.
.equ WATCHDOG_BASE_ADDR, 0x40058000
# Watchdog Tick register offset.
# The watchdog peripheral has a tick generator used by the Timer peripheral.
# Without this being on the Timer won't function.
.equ WATCHDOG_TICK_OFFSET, 0x2c

# Watchdog Tick register memory address.
.equ WATCHDOG_TICK, (WATCHDOG_BASE_ADDR + WATCHDOG_TICK_OFFSET)

# Value used to enable the tick generator
.equ WATCHDOG_TICK_ENABLE, 1 << 9

# SIO = Software Input/Output, used for controlling GPIO output and input
# Base address of peripheral.
.equ SIO_BASE_ADDR, 0xd0000000
# Output register offset.
.equ SIO_OUTPUT_OFFSET, 0x010
# Output enable register offset.
# It is not sufficient for the output to be turned on, it must be enabled as well.
.equ SIO_OUTPUT_ENABLE_OFFSET, 0x020

# Software I/O output register memory address.
.equ SIO_OUTPUT, (SIO_BASE_ADDR + SIO_OUTPUT_OFFSET)
# Software I/O output enable register memory address.
.equ SIO_OUTPUT_ENABLE, (SIO_BASE_ADDR + SIO_OUTPUT_ENABLE_OFFSET)

# Value used for selecting pin 13 of the IO_BANK0 GPIO bank.
# On an Adafruit Feather RP2040 the 13th pin is connected to an led.
.equ SIO_GPIO_13_MASK, 1 << 13
# On a Raspberry Pi Pico the 25th pin is connected to an led.
.equ SIO_GPIO_25_MASK, 1 << 25

# GPIO = General Purpose Input/Output
# Base address of peripheral.
.equ GPIO_BASE_ADDR, 0x40014000
# GPIO pin 13 control register offset.
.equ GPIO_13_CTRL_OFFSET, 0x06c
# GPIO pin 25 control register offset. Used for the Raspberry Pi Pico
.equ GPIO_25_CTRL_OFFSET, 0x0cc

# Each GPIO pin can be configured to serve different purposes: UART, I2C, SIO etc.
# Software I/O is function number 5
.equ GPIO_FUNCSEL_SIO, 5

# GPIO pin 13 control register memory address.
.equ GPIO_13, (GPIO_13_CTRL_OFFSET + GPIO_BASE_ADDR)
# GPIO pin 25 control register memory address.
.equ GPIO_25, (GPIO_25_CTRL_OFFSET + GPIO_BASE_ADDR)

# Base address of peripheral.
# The timer is split into two 32bit registers, because the RP2040 does not have a 64bit bus.
.equ TIMER_BASE_ADDR, 0x40054000
# Time low raw read register offset. This register does not pause the timer until the high
# register is also read as opposed to the LREAD register.
.equ TIMER_LRAWREAD_OFFSET, 0x28
# Timer low write register offset. The value is not actually set until the high register is
# also written to. Documentation warns that this register should always be written to before
# the HWRITE register
# These registers are used for setting the value of the timer, but it is also set automatically
# by hardware as well.
.equ TIMER_LWRITE_OFFSET, 0x04
# Timer high write register offset.
.equ TIMER_HWRITE_OFFSET, 0x00

# Timer low raw read register memory address.
.equ TIMER_LRAWREAD, (TIMER_BASE_ADDR + TIMER_LRAWREAD_OFFSET)
# Timer low write register memory address.
.equ TIMER_LWRITE, (TIMER_BASE_ADDR + TIMER_LWRITE_OFFSET)
# Timer high write register memory address.
.equ TIMER_HWRITE, (TIMER_BASE_ADDR + TIMER_HWRITE_OFFSET)

# The reset peripheral is used to reset non-critical peripherals, it is set to all 1s at startup,
# therefor every peripherial must be cleared of the reset flag before use.
# Base address of peripheral.
.equ RESET_BASE_ADDR, 0x4000d000
# Applying this bit mask to a register turns it into a clear operation.
.equ ATOMIC_CLEAR_MASK, 0x3000

# Apply clear mask to reset register. Writing a 1 to this address will clear the bit that 1 was
# written to
.equ RESET_CLEAR, (RESET_BASE_ADDR | ATOMIC_CLEAR_MASK)
# Value used to clear the reset flag of the GPIO peripheral.
.equ RESET_CLEAR_GPIO, 1 << 5
# Value used to clear the reset flag of the Timer peripheral.
.equ RESET_CLEAR_TIMER, 1 << 21

# Combine above values so they may get cleared in the same operation.
.equ RESET_CLEAR_DEVS, (RESET_CLEAR_GPIO | RESET_CLEAR_TIMER)

# Text section, used for linking
.text


# Tell the assembler to create a 16bit function, this may be redundant.
.thumb_func
# Tell the assembler to expose this function to the linker.
.global _start
# The entry point of the program as defined in the linker script.
_start:
	# Clear reset flags for required devices.
    ldr r0, =RESET_CLEAR
	# ldr is used to load a value from an address into a register.
	# syntax: ldr <destination register>, <source address/symbol>
	# This processor is running in 16bit mode, it can not use immediate values larger than
	# its own instruction length, because immediate values are encoded directtly in the instruction,
	# so it relies on loading large values from memory.
	ldr r1, =RESET_CLEAR_DEVS
	# str is used to store a value from a register into an address.
	# syntax: ldr <source register>, <destination address/symbol>
    str r1, [r0]

	# Set crystal oscillator startup delay.
    ldr r0, =XOSC_STARTUP
	ldr r1, =XOSC_STATUP_DELAY
    str r1, [r0]

	# Set crystal oscillator frequency.
    ldr r0, =XOSC_CTRL
	ldr r1, =XOSC_FREQ
    str r1, [r0]

	# Enable crystal oscillator.
    ldr r0, =XOSC_CTRL
	ldr r1, =XOSC_ENABLE_VAL
    str r1, [r0]

	# Busy wait for crystal oscillator to come online.
# A label is used to control the flow of the program.
# sytnax: <label>:
_wait:
	ldr r0, =XOSC_STATUS_MASK
	ldr r1, =XOSC_STATUS
	# load the value at the address stored in r1 into r1.
	# Using square brackets on a register means accessing the address stored in that register.
	ldr r1, [r1]
	# and is used to perform a bitwise and operation on two registers or a register and an immediate.
	# syntax: and <destination> <source>
	and r1, r0
	# cmp is used to compare two registers or a register and an immediate, banch instructions decide
	# what is done with this comparison. The mechanism through which this is done is the flags register
	# inside the processor.
	# syntax: cmp <register> <register/immediate>
	cmp r1, #0
	# beq is used to branch if the previous comparison was equal. A branch instruction changes the flow
	# of the program by setting the program counter to a different value usually based on a previous comparison.
	# syntax: beq <label>
	beq _wait

	# Switch clock source to crystal oscillator.
    ldr r0, =CLOCKS_REF_CTRL
	ldr r1, =CLOCKS_SET_XOSC_VAL
    str r1, [r0]

	# Enable Watchdog tick generator, which is required for the timer to function.
    ldr r0, =WATCHDOG_TICK
	ldr r1, =WATCHDOG_TICK_ENABLE
    str r1, [r0]

	# Set GPIO 13 pin to function as Software I/O.
	ldr r0, =GPIO_13
	ldr r1, =GPIO_FUNCSEL_SIO
	str r1, [r0]

	# Enable outputing on GPIO 13 pin.
	ldr r0, =SIO_OUTPUT_ENABLE
	ldr r1, =SIO_GPIO_13_MASK
	str r1, [r0]

	# Reset timer.
	ldr r0, =TIMER_LWRITE
	# mov is used to store an immediate into a register or to copy a register to another.
	# syntax: mov <destination>, <source immediate/register>
	mov r1, #0
	str r1, [r0]
	ldr r0, =TIMER_HWRITE
	mov r1, #0
	str r1, [r0]

blink:
	# Set GPIO 13 pin to on.
	ldr r0, =SIO_OUTPUT
	ldr r1, =SIO_GPIO_13_MASK
	str r1, [r0]

	# bl is used to call a function, it sets the link register to the current address + 1 instruction
	# and then sets the program counter to the label
	# syntax: bl <label>
	bl delay

	# Set GPIO 13 pin to off.
	ldr r0, =SIO_OUTPUT
	mov r1, #0
	str r1, [r0]

	bl delay

	# b is used to set the program counter to a label unconditionally
	# syntax: b <label>
	b blink

# Tell the assembler to create a 16bit function, this may be redundant.
.thumb_func
# The delay function busy waits for a certain amount of time.
delay:
	# Compare the timer to the DELAY constant, if it is greater or equal reset the timer and return.
	ldr r2, =DELAY
	ldr r3, =TIMER_LRAWREAD
	ldr r3, [r3]
	cmp r3, r2
	# blt is used to branch if the left argument of the previous comparison was less than the right
	blt delay

	# Reset the timer
	ldr r0, =TIMER_LWRITE
	mov r1, #0
	str r1, [r0]
	ldr r0, =TIMER_HWRITE
	mov r1, #0
	str r1, [r0]

	# bx lr is used for returning from a function.
	bx lr 
