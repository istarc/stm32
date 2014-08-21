###
# Build all projects

###
# Directory Structure
BDIRS='examples'

###
# Build Rules
.PHONY: all clean $(BDIRS)

all: $(BDIRS) 

$(BDIRS):
	$(MAKE) -C $@

clean:
	for d in $(BDIRS); do $(MAKE) -C $$d clean; done
