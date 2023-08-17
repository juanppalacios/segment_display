# By Etienne Collin
# https://gist.github.com/etiennecollin/198f7520c4c58d545368a196e08f83ed
# Dependencies (on macOS, install via Homebrew (https://brew.sh/)):
#   ghdl:
#     Source: https://github.com/ghdl/ghdl/
#   gtkwave:
#     Source: https://gtkwave.sourceforge.net/

#### INPUT REQUIRED ####
ENTITIES = segment_pkg_tb
VHDL_EXTENSION = vhd
VHDL_MAIN_PATH = ./sim
VHDL_DEPENDENCIES_PATH = ./src
VHDL_ARGS = -fsynopsys --std=08 -frelaxed-rules
GHDL_PATH = ghdl
GTKWAVE_PATH = gtkwave
# GTKWAVE_ARGS = --vcd=waveform.vcd
########################

OUT_DIR = out
VHDL_MAIN := $(VHDL_MAIN_PATH)/*.$(VHDL_EXTENSION)
VHDL_DEPENDENCIES := $(VHDL_DEPENDENCIES_PATH)/*.$(VHDL_EXTENSION)
CF := $(OUT_DIR)/*.cf
GHW := $(OUT_DIR)/*.ghw
GHW_ENTITY = $(OUT_DIR)/$${GHW_ENTITY}.ghw
VCD_ENTITY = $(OUT_DIR)/$${GHW_ENTITY}.vcd

VHDL_MOD_TIME = $(OUT_DIR)/vhdl_last_modification_time.txt
CF_MOD_TIME = $(OUT_DIR)/cf_last_modification_time.txt

.PHONY: all simulate clear purge

all: $(GHW)

# Make this the dependency of $(CF) if the files are always compiled even when not modified
# $(VHDL_MOD_TIME): $(VHDL_DEPENDENCIES) $(VHDL_MAIN)
# 	@$(MAKE) checkstructure
# 	@[ -f "$(VHDL_MOD_TIME)" ] || touch $(VHDL_MOD_TIME)
# 	@find $(VHDL_DEPENDENCIES) $(VHDL_MAIN) -type f -exec stat -f "%m %N" {} \; | sort -nr | head -1 > $(VHDL_MOD_TIME)

$(CF): $(VHDL_DEPENDENCIES) $(VHDL_MAIN)
	@$(MAKE) checkstructure
	@echo "Analyzing $(VHDL_EXTENSION) files..."
	@${GHDL_PATH} -a $(VHDL_ARGS) --workdir=$(OUT_DIR) $(VHDL_DEPENDENCIES)
	@${GHDL_PATH} -a $(VHDL_ARGS) --workdir=$(OUT_DIR) $(VHDL_MAIN)
	@for GHW_ENTITY in $(ENTITIES); do \
		echo "Compiling GHW_ENTITY $${GHW_ENTITY}..."; \
		${GHDL_PATH} -e $(VHDL_ARGS) --workdir=$(OUT_DIR) $${GHW_ENTITY}; \
	done

# Make this the dependency of $(GHW) if the files are always compiled even when not modified
# $(CF_MOD_TIME): $(CF)
# 	@[ -f "$(CF_MOD_TIME)" ] || touch $(CF_MOD_TIME)
# 	@find $(CF) -type f -exec stat -f "%m %N" {} \; | sort -nr | head -1 > $(CF_MOD_TIME)

$(GHW): $(CF)
	@for GHW_ENTITY in $(ENTITIES); do \
		echo "Generating $${GHW_ENTITY}.ghw file..."; \
		${GHDL_PATH} -r $(VHDL_ARGS) --workdir=$(OUT_DIR) $${GHW_ENTITY} --wave=$(GHW_ENTITY) --vcd=${VCD_ENTITY}; \
	done


simulate: $(GHW)
	@for GHW_ENTITY in $(ENTITIES); do \
		echo "Opening $${GHW_ENTITY}.ghw in gtkwave..."; \
		${GTKWAVE_PATH} $(GHW_ENTITY); \
	done

checkstructure:
	@[ -d $(OUT_DIR) ] || ( echo "Creating output directory..."; mkdir -p $(OUT_DIR) )

clear:
	@echo "Cleaning auto-generated files from output directory..."
	@rm -rf $(OUT_DIR)/*

purge:
	@echo "Purging auto-generated file structure..."
	@rm -rf $(OUT_DIR)