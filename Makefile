COMMON = common
SINGLE_CYCLE = single_cycle
MULTICYCLE = multicycle
PIPELINE = pipeline

SIM = sim
TARGET = target

single_cycle: $(SIM)/testbench.v $(wildcard $(COMMON)/*.v $(SINGLE_CYCLE)/*.v)
	mkdir -p $(TARGET)/$(SINGLE_CYCLE)
	iverilog -o $(TARGET)/$(SINGLE_CYCLE)/sim.vvp -I $(COMMON) $^
	cd $(TARGET)/$(SINGLE_CYCLE) && vvp sim.vvp

multicycle:

pipeline:

clean:
	rm -rf $(TARGET)