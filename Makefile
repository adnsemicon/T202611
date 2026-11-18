export SHELL=/bin/bash

BUILD_DIR := $(CURDIR)/build
LOG_DIR := $(CURDIR)/log

TOP = test

FILES += -i $(CURDIR)/include
FILES += $(shell find $(CURDIR)/interface -type f -name "*.sv")
FILES += $(shell find $(CURDIR)/source -type f -name "*.sv")
FILES += $(shell find $(CURDIR)/testbench -type f -name "*.sv")

YA := \033[1;33m>\033[0m

.PHONY: clean
clean:
	@rm -rf $(BUILD_DIR)
	@echo -e "$(YA) Removed build directory"

.PHONY: clean_full
clean_full:
	@make -s clean
	@rm -rf $(LOG_DIR)
	@echo -e "$(YA) Removed log directory"

$(BUILD_DIR) $(LOG_DIR):
	@mkdir -p $@
	@echo "*" > $@/.gitignore
	@echo -e "$(YA) Created $@ directory"

# COMPILE
$(BUILD_DIR)/compilation_done:
	@rm -rf $(BUILD_DIR)/*.elaboration_done
	@make -s $(BUILD_DIR)
	@make -s $(LOG_DIR)
	@cd $(BUILD_DIR) && xvlog -sv $(FILES) -log $(LOG_DIR)/xvlog_$(shell date +%Y%m%d_%H%M%S).log
	@echo -e "$(YA) Compilation Done"
	@touch $(BUILD_DIR)/compilation_done

# Elaborate
$(BUILD_DIR)/$(TOP).elaboration_done:
	@make -s $(BUILD_DIR)/compilation_done
	@cd $(BUILD_DIR) && xelab $(TOP) -s snap_$(TOP) -log $(LOG_DIR)/xelab_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log
	@echo -e "$(YA) Elaboration Done for $(TOP)"
	@touch $(BUILD_DIR)/$(TOP).elaboration_done

# Simulate
.PHONY: simulate
simulate:
	@make -s $(LOG_DIR)
	@make -s $(BUILD_DIR)/$(TOP).elaboration_done
	@cd $(BUILD_DIR) && xsim snap_$(TOP) -runall -log $(LOG_DIR)/xsim_$(TOP)_$(shell date +%Y%m%d_%H%M%S).log
	@echo -e "$(YA) Simulation Done for $(TOP)"

.PHONY: all
all:
	@make -s clean
	@echo "----------------------------------------"
	@make -s compile
	@echo "----------------------------------------"
	@make -s elaborate TOP=$(TOP)
	@echo "----------------------------------------"
	@make -s simulate TOP=$(TOP)
	@echo "----------------------------------------"
