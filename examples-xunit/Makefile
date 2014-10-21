###
# Build all projects

###
# Directory Structure
BDIRS=$(shell find . -mindepth 1 -maxdepth 1 -type d)
TDIRS=sim

###
# Build Rules
.PHONY: all check clean test-clean

all:
	for d in $(BDIRS); do $(MAKE) -C $$d; done

check:
	for d in $(TDIRS); do $(MAKE) -C $$d check; done

clean:
	for d in $(BDIRS); do $(MAKE) -C $$d clean; done

test-clean:
	for d in $(TDIRS); do $(MAKE) -C $$d test-clean; done
