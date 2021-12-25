COMMON = common
SINGLE_CYCLE = single_cycle
MULTICYCLE = multicycle
PIPELINE = pipeline

SIM = sim
TARGET = target

FILES = $(wildcard $(COMMON)/*.v $(SINGLE_CYCLE)/*.v)

.PHONY: $(FILES)

single_cycle: $(SIM)/testbench.v $(FILES)
	mkdir -p $(TARGET)/$(SINGLE_CYCLE)
	iverilog -o $(TARGET)/$(SINGLE_CYCLE)/sim.vvp -I $(COMMON) $^
	cd $(TARGET)/$(SINGLE_CYCLE) && vvp sim.vvp

clean:
	rm -rf $(TARGET)