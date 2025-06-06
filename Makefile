ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

CH32V20X_DIR := $(ROOT_DIR)ch32v20x/EVT/EXAM/SRC
USER_DIR := .
BUILD_DIR := $(ROOT_DIR)build

MINICHLINK_DIR := $(ROOT_DIR)/minichlink
MINICHLINK_BIN := $(MINICHLINK_DIR)/minichlink
# Use your existing compiler
RISCV_GCC_DIR := $(ROOT_DIR)/riscv-none-elf-gcc/
CROSS_COMPILE := $(RISCV_GCC_DIR)/install/bin/riscv64-unknown-elf-

# Select ONLY ONE startup file (edit as needed)
STARTUP_FILE := Startup/startup_ch32v20x_D6.S

# All .c files from SDK (core, peripheral, debug, etc)
SDK_C_SRC := $(wildcard $(CH32V20X_DIR)/*/*.c) $(wildcard $(CH32V20X_DIR)/*/src/*.c)
# Only the chosen startup .S file
SDK_S_SRC := $(CH32V20X_DIR)/$(STARTUP_FILE)
SDK_SRC := $(SDK_C_SRC) $(SDK_S_SRC)

SDK_OBJ := $(patsubst $(CH32V20X_DIR)/%.c,$(BUILD_DIR)/%.o,$(filter %.c,$(SDK_SRC))) \
           $(patsubst $(CH32V20X_DIR)/%.S,$(BUILD_DIR)/%.o,$(filter %.S,$(SDK_SRC)))

USER_SRC := $(wildcard $(USER_DIR)/*.c) $(wildcard $(USER_DIR)/*.cpp)
USER_OBJ := $(patsubst $(USER_DIR)/%.c,$(BUILD_DIR)/user/%.o,$(filter %.c,$(USER_SRC))) \
            $(patsubst $(USER_DIR)/%.cpp,$(BUILD_DIR)/user/%.o,$(filter %.cpp,$(USER_SRC)))

# Use the correct linker script for your chip!
LDSCRIPT := $(CH32V20X_DIR)/Ld/Link.ld
TARGET := $(USER_DIR)/firmware.elf

INCLUDES := -I$(CH32V20X_DIR)/Core \
            -I$(CH32V20X_DIR)/Core/inc \
            -I$(CH32V20X_DIR)/Debug \
            -I$(CH32V20X_DIR)/Peripheral/inc \
            -I.

# Match the flags used in the working Makefile
CFLAGS += -march=rv32imac_zicsr -mabi=ilp32 -msmall-data-limit=8 -msave-restore -Os -ffunction-sections -fdata-sections -fno-common -Wunused -Wuninitialized -g
LDFLAGS += -march=rv32imac_zicsr -mabi=ilp32 -nostartfiles -Wl,--gc-sections --specs=nano.specs --specs=nosys.specs

.PHONY: all clean flash riscv-none-elf-gcc minichlink

all: riscv-none-elf-gcc minichlink $(TARGET)

$(BUILD_DIR)/%.o: $(CH32V20X_DIR)/%.c
	mkdir -p $(dir $@)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@ $(INCLUDES)

$(BUILD_DIR)/%.o: $(CH32V20X_DIR)/%.S
	mkdir -p $(dir $@)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@ $(INCLUDES)

$(BUILD_DIR)/user/%.o: $(USER_DIR)/%.c
	mkdir -p $(dir $@)
	$(CROSS_COMPILE)gcc $(CFLAGS) -c $< -o $@ $(INCLUDES)

$(BUILD_DIR)/user/%.o: $(USER_DIR)/%.cpp
	mkdir -p $(dir $@)
	$(CROSS_COMPILE)g++ $(CFLAGS) -c $< -o $@ $(INCLUDES)

$(TARGET): $(SDK_OBJ) $(USER_OBJ) $(LDSCRIPT)
	$(CROSS_COMPILE)gcc $(LDFLAGS) -T$(LDSCRIPT) -o $@ $(SDK_OBJ) $(USER_OBJ)

$(RISCV_GCC_DIR)/config.status:
	mkdir -p $(RISCV_GCC_DIR)/install
	cd $(RISCV_GCC_DIR) && ./configure --prefix=$(RISCV_GCC_DIR)/install --enable-multilib

# Build the toolchain
riscv-none-elf-gcc: $(RISCV_GCC_DIR)/config.status
	make -C $(RISCV_GCC_DIR)

# Build minichlink
minichlink:
	make -C $(MINICHLINK_DIR)

flash: all
	$(MINICHLINK_BIN) -E -w $(USER_DIR)/firmware.elf 0x08000000

clean:
	rm -rf $(BUILD_DIR) $(USER_DIR)/firmware.elf

