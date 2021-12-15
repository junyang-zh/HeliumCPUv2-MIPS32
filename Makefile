INCLUDES = includes
COMMON = common
SINGLE_CYCLE = single_cycle
MULTICYCLE = multicycle
PIPELINE = pipeline
SIM = sim

COMMON_DIRS := $(shell find $(COMMON) -maxdepth 3 -type d)
COMMON_FILES = $(foreach dir, $(COMMON_DIRS), $(wildcard $(dir)/*.v))

TARGET = target
SINGLE_CYCLE_TARGET = $(TARGET)/$(SINGLE_CYCLE)

single_cycle: $(SIM)/testbench.v $(COMMON_FILES) $(wildcard $(SINGLE_CYCLE)/*.v)
	mkdir -p $(SINGLE_CYCLE_TARGET)
	iverilog -o $(SINGLE_CYCLE_TARGET)/sim.vvp -I $(INCLUDES) $^
	cd $(SINGLE_CYCLE_TARGET) && vvp sim.vvp

multicycle:

pipeline:

clean:
	rm -rf $(TARGET)