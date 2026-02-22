<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

This design uses SPI inputs ncs, sclk, and copi to write five internal registers.
These registers control 16 outputs across uo_out and uio_out, including per-channel PWM
enable bits and one shared 8-bit duty-cycle value.

Each channel either:
- stays at its configured register value, or
- is gated by the shared PWM signal when PWM is enabled for that channel.

All uio pins are configured and driven as outputs.

## How to test

Run the cocotb testbench from the test folder:

```sh
make
```

No external hardware is required.

## External hardware

None.
