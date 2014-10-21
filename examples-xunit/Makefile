###
# Build all projects

###
# Directory Structure
BDIRS=$(shell find . -mindepth 1 -maxdepth 1 -type d)
TDIRS=sim

###
# Build Rules
.PHONY: all clean $(BDIRS)

all: $(BDIRS)

check: $(TDIRS)

$(BDIRS):
	$(MAKE) -C $@

$(TDIRS):
	$(MAKE) -C $@ check

clean:
	for d in $(BDIRS); do $(MAKE) -C $$d clean; done
	for d in $(TDIRS); do $(MAKE) -C $$d clean; done
