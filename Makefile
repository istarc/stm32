###
# Build all projects

###
# Directory Structure
BDIRS='examples'
TDIRS='examples-xunit'

###
# Build Rules
.PHONY: all clean

all:
	for d in $(BDIRS); do $(MAKE) -C $$d; done
	for d in $(TDIRS); do $(MAKE) -C $$d; done

check:
	for d in $(TDIRS); do $(MAKE) -C $$d check; done

clean:
	for d in $(BDIRS); do $(MAKE) -C $$d clean; done
	for d in $(TDIRS); do $(MAKE) -C $$d clean; done

test-clean:
	for d in $(TDIRS); do $(MAKE) -C $$d test-clean; done
