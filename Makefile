# LPC1xx Makefile
# #####################################
#
# Part of the uCtools project
# uctools.github.com
#
#######################################
# user configuration:
#######################################

# SOURCES: list of sources in the user application
SOURCES = main.c system_ARMCM0.c

# TARGET: name of the user application
TARGET = main

# BUILD_DIR: directory to place output files in
BUILD_DIR = build

# LD_SCRIPT: location of the linker script
LD_SCRIPT = lpc1xx.ld

# LPCOPEN_PATH: path to lpcopen files
LPCOPEN_PATH = /home/eric/code/lpc1xx-template/lpcopen

# USER_DEFS user defined macros
USER_DEFS =
# USER_INCLUDES: user defined includes
USER_INCLUDES =
# USER_CFLAGS: user C flags
USER_CFLAGS = -Wall
# USER_LDFLAGS:  user LD flags
USER_LDFLAGS =

# FAMILY: processor family (11xx or 13xx)
FAMILY = 11xx
# PART: processor part number (ie, CHIP_LPC11UXX)
PART = CHIP_LPC11CXX

#######################################
# end of user configuration
#######################################
#
#######################################
# binaries
#######################################
CC = arm-none-eabi-gcc-4.7.3
AR = ar
MKDIR = mkdir -p
#######################################

ifeq ($(FAMILY), 11xx)
# core and CPU type for Cortex M0
# ARM core type (CORE_M0, CORE_M3)
CORE = CORE_M0
# ARM CPU type (cortex-m0, cortex-m3)
CPU = cortex-m0
endif

ifeq ($(FAMILY), 13xx)
# core and CPU type for Cortex M0
# ARM core type (CORE_M0, CORE_M3)
CORE = CORE_M3
# ARM CPU type (cortex-m0, cortex-m3)
CPU = cortex-m3
endif

# where to build lpcopen
LPCOPEN_BUILD_DIR = $(BUILD_DIR)/lpcopen

# various paths within the lpcopen library
CMSIS_PATH = $(LPCOPEN_PATH)/software/CMSIS
CORE_PATH = $(LPCOPEN_PATH)/software/lpc_core
CHIP_PATH = $(CORE_PATH)/lpc_chip/chip_$(FAMILY)
CHIP_COMMON_PATH = $(CORE_PATH)/lpc_chip/chip_common
IP_PATH = $(CORE_PATH)/lpc_ip

# includes for gcc
INCLUDES = -I$(CMSIS_PATH)/CMSIS/Include
INCLUDES += -I$(CMSIS_PATH)/Device/ARM/ARMCM0/Include
INCLUDES += -I$(CHIP_COMMON_PATH)
INCLUDES += -I$(CHIP_PATH)
INCLUDES += -I$(IP_PATH)
INCLUDES += -Isrc
INCLUDES += $(USER_INCLUDES)

# macros for gcc
DEFS = -D$(CORE) -D$(PART) $(USER_DEFS)

# compile gcc flags
CFLAGS = $(DEFS) $(INCLUDES)
CFLAGS += -mcpu=$(CPU) -mthumb -std=c99
CFLAGS += $(USER_CFLAGS)

# default action: build the user application
all: $(BUILD_DIR)/$(TARGET).elf

#######################################
# build the lpcopen core library
# (lpc_chip, lpc_ip)
#######################################

LPCOPEN_CORE_LIB = $(LPCOPEN_BUILD_DIR)/liblpcopencore.a

# List of lpcopen core objects
LPCOPEN_CORE_OBJS = $(addprefix $(LPCOPEN_BUILD_DIR)/, $(patsubst %.c, %.o, $(notdir $(wildcard $(CHIP_PATH)/*.c))))
LPCOPEN_CORE_OBJS += $(addprefix $(LPCOPEN_BUILD_DIR)/, $(patsubst %.c, %.o, $(notdir $(wildcard $(IP_PATH)/*.c))))
LPCOPEN_CORE_OBJS += $(addprefix $(LPCOPEN_BUILD_DIR)/, $(patsubst %.c, %.o, $(notdir $(wildcard $(CHIP_COMMON_PATH)/*.c))))

# shortcut for building core library (make lpc_core)
lpc_core: $(LPCOPEN_CORE_LIB)

$(LPCOPEN_CORE_LIB): $(LPCOPEN_CORE_OBJS)
	$(AR) rv $@ $(LPCOPEN_CORE_OBJS)

$(LPCOPEN_BUILD_DIR)/%.o: $(CHIP_PATH)/%.c | $(LPCOPEN_BUILD_DIR)
	$(CC) -c $(CFLAGS) -o $@ $^

$(LPCOPEN_BUILD_DIR)/%.o: $(IP_PATH)/%.c | $(LPCOPEN_BUILD_DIR)
	$(CC) -c $(CFLAGS) -o $@ $^

$(LPCOPEN_BUILD_DIR)/%.o: $(CHIP_COMMON_PATH)/%.c | $(LPCOPEN_BUILD_DIR)
	$(CC) -c $(CFLAGS) -o $@ $^

$(LPCOPEN_BUILD_DIR):
	$(MKDIR) $@

#######################################
# build the user application
#######################################

# list of user program objects
OBJECTS = $(addprefix $(BUILD_DIR)/,$(notdir $(SOURCES:.c=.o)))
# add object for startup code
OBJECTS += $(BUILD_DIR)/startup_ARMCM0.o

# use the lpcopen core library, plus generic ones (libc, libm, libnosys)
LIBS = -llpcopencore -lc -lm -lnosys
LDFLAGS = -T $(LD_SCRIPT) -L $(LPCOPEN_BUILD_DIR) $(LIBS) $(USER_LDFLAGS)

$(BUILD_DIR)/$(TARGET).elf: $(OBJECTS) $(LPCOPEN_CORE_LIB)
	$(CC) -o $@ $(CFLAGS) $(OBJECTS) \
		-L$(LPCOPEN_BUILD_DIR) -static $(LIBS) -Xlinker \
		-Map=$(BUILD_DIR)/$(TARGET).map \
		-T $(LD_SCRIPT)
	size $@

$(BUILD_DIR)/%.o: src/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $^

$(BUILD_DIR)/%.o: src/%.S | $(BUILD_DIR)
	$(CC) $(CFLAGS) -c -o $@ $^

$(BUILD_DIR):
	$(MKDIR) $@

# delete all user application files, keep the libraries
clean:
		-rm $(BUILD_DIR)/*.o
		-rm $(BUILD_DIR)/*.elf
		-rm $(BUILD_DIR)/*.map

.PHONY: clean all lpc_core
