# CH32V203 RISC-V Bare-Metal Firmware Project

This project is a bare-metal firmware template for the [WCH CH32V203](https://www.wch-ic.com/products/CH32V203.html) RISC-V microcontroller.  
It is designed for use with the official CH32V20x SDK, the RISC-V GCC toolchain with newlib/newlib-nano, and supports flashing via [minichlink](https://github.com/cnlohr/ch32fun/tree/master/minichlink).

## Features

- Minimal, portable Makefile for CH32V203
- Uses newlib-nano for standard C library support
- Clean separation of user and SDK code
- Ready for UART debugging (`_write` stub included)
- Flashing supported via minichlink and WCH-LinkE

## Tools Used

| Tool                    | Purpose                         | Reference / Install Link              |
|-------------------------|---------------------------------|---------------------------------------|
| riscv64-unknown-elf-gcc | RISC-V cross-compiler           | [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) |
| minichlink              | Flashing via WCH-Link           | [minichlink](https://github.com/cnlohr/ch32fun/tree/master/minichlink) |
| CH32V20x SDK            | MCU peripheral library           | [WCH official repo](https://github.com/openwch/ch32v20x/tree/6209b6e7f910e313eaa93354dc3b29608431f725) |

## Project Structure

```
project-root/
├── ch32v20x/EVT/EXAM/SRC/   # CH32V20x SDK source files
├── build/                   # Build output directory
├── User/                    # User application code
├── Makefile                 # Project Makefile
└── README.md                # This file
```

## User/Makefile Usage

This Makefile is a convenience wrapper that allows you to build, clean, or flash the entire project from within the `User/` directory.

### Example Usage
In the Project folder run:
```sh
git submodule update --init
```

From inside the `User/` directory, run:

```sh
make        # Builds the whole project
make clean  # Cleans all build artifacts
make flash  # Flashes the firmware to the device (if supported)
```

### How It Works

```makefile
MAKEFILE_PATH := ../../../../../../Makefile

all:
	$(MAKE) -f $(MAKEFILE_PATH) all

clean:
	$(MAKE) -f $(MAKEFILE_PATH) clean

flash:
	$(MAKE) -f $(MAKEFILE_PATH) flash

.PHONY: all clean flash
```

- `MAKEFILE_PATH` points to the main Makefile relative to the `User/` directory.
- Each target (`all`, `clean`, `flash`) simply calls the corresponding target in the main Makefile.

## Flashing the Firmware

Use minichlink to program your device:

1. Connect your WCH-LinkE programmer to your CH32V203 board and to your computer.
2. Flash the binary file to the MCU:
   ```
   minichlink -E -w firmware.elf 0x08000000
   ```
   - `-E` erases the chip before flashing.
   - `-w firmware.bin 0x08000000` writes the binary to the MCU's flash starting at address `0x08000000`.

3. If the board does not reset automatically after flashing, press the reset button or power-cycle the board.

## References

- [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain)
- [minichlink](https://github.com/cnlohr/ch32fun/tree/master/minichlink)
- [ch32v20x](https://github.com/openwch/ch32v20x/tree/6209b6e7f910e313eaa93354dc3b29608431f725)
- [CH32V203 Documentation (WCH)](https://www.wch-ic.com/products/CH32V203.html)

## License

This project is released under the MIT License.  
See [LICENSE](LICENSE) for details.
