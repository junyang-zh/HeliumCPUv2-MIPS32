INCLUDES = includes
COMMON = common
SINGLE_CYCLE = single_cycle
MULTICYCLE = multicycle
PIPELINE = pipeline
PIPELINE_BP = pipeline_bp
SIM = sim

COMMON_DIRS := $(shell find $(COMMON) -maxdepth 3 -type d)
COMMON_FILES = $(foreach dir, $(COMMON_DIRS), $(wildcard $(dir)/*.v))

# Make every time, avoid "* is up to date"
.PHONY: $(COMMON_FILES)

TARGET = target
SINGLE_CYCLE_TARGET = $(TARGET)/$(SINGLE_CYCLE)
MULTICYCLE_TARGET = $(TARGET)/$(MULTICYCLE)
PIPELINE_TARGET = $(TARGET)/$(PIPELINE)
PIPELINE_BP_TARGET = $(TARGET)/$(PIPELINE_BP)

all: single_cycle multicycle pipeline pipeline_bp

single_cycle: $(SIM)/testbench.v $(COMMON_FILES) $(wildcard $(SINGLE_CYCLE)/*.v)
	mkdir -p $(SINGLE_CYCLE_TARGET)
	iverilog -o $(SINGLE_CYCLE_TARGET)/sim.vvp -I $(INCLUDES) $^
	cd $(SINGLE_CYCLE_TARGET) && vvp sim.vvp

multicycle: $(SIM)/testbench.v $(COMMON_FILES) $(wildcard $(MULTICYCLE)/*.v)
	mkdir -p $(MULTICYCLE_TARGET)
	iverilog -o $(MULTICYCLE_TARGET)/sim.vvp -I $(INCLUDES) $^
	cd $(MULTICYCLE_TARGET) && vvp sim.vvp

pipeline: $(SIM)/testbench.v $(COMMON_FILES) $(wildcard $(PIPELINE)/*.v)
	mkdir -p $(PIPELINE_TARGET)
	iverilog -o $(PIPELINE_TARGET)/sim.vvp -I $(INCLUDES) $^
	cd $(PIPELINE_TARGET) && vvp sim.vvp

pipeline_bp: $(SIM)/testbench.v $(COMMON_FILES) $(wildcard $(PIPELINE_BP)/*.v)
	mkdir -p $(PIPELINE_BP_TARGET)
	iverilog -o $(PIPELINE_BP_TARGET)/sim.vvp -I $(INCLUDES) $^
	cd $(PIPELINE_BP_TARGET) && vvp sim.vvp

clean:
	rm -rf $(TARGET)