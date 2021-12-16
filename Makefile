INCLUDES = includes
COMMON = common
SINGLE_CYCLE = single_cycle
MULTICYCLE = multicycle
PIPELINE = pipeline
SIM = sim

COMMON_DIRS := $(shell find $(COMMON) -maxdepth 3 -type d)
COMMON_FILES = $(foreach dir, $(COMMON_DIRS), $(wildcard $(dir)/*.v))

# Make every time, avoid "* is up to date"
.PHONY: $(COMMON_FILES)

TARGET = target
SINGLE_CYCLE_TARGET = $(TARGET)/$(SINGLE_CYCLE)
MULTICYCLE_TARGET = $(TARGET)/$(MULTICYCLE)
PIPELINE_TARGET = $(TARGET)/$(PIPELINE)

all: single_cycle multicycle pipeline

single_cycle: $(SIM)/testbench.v $(COMMON_FILES) $(wildcard $(SINGLE_CYCLE)/*.v)
	mkdir -p $(SINGLE_CYCLE_TARGET)
	iverilog -o $(SINGLE_CYCLE_TARGET)/sim.vvp -I $(INCLUDES) $^
	cd $(SINGLE_CYCLE_TARGET) && vvp sim.vvp

multicycle: $(SIM)/testbench.v $(COMMON_FILES) $(wildcard $(MULTICYCLE)/*.v)
	mkdir -p $(MULTICYCLE_TARGET)
	iverilog -o $(MULTICYCLE_TARGET)/sim.vvp -I $(INCLUDES) $^
	cd $(MULTICYCLE_TARGET) && vvp sim.vvp

pipeline:

clean:
	rm -rf $(TARGET)