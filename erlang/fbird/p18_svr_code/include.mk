####################################################################
## @description 公用makefile文件
####################################################################

.PHONY: all

ERL := erl
ERLC := $(ERL)c
EMULATOR := beam

INCLUDE_DIRS := include

EBIN_DIR := ./ebin
EBIN_LIB_DIR := ./ebin/lib

## 指定编译时查找头文件
ERLC_FLAGS := -Werror -I include +nowarn_export_all
# ## 打开检测代码中使用binary的优化信息
# ERLC_FLAGS += +bin_opt_info  
##这里可以通过 make debug_mode=true来达到打开debug_info选项的目的
ifdef debug_mode
  ERLC_FLAGS += +debug_info
  ERLC_FLAGS += -D debug -D debug_mode -D debug_pt 
endif


##所有的erl源码文件
ERL_SOURCES := $(wildcard $(SRC_DIRS))
ERL_SOURCES2 := $(addprefix $(EBIN_DIR)/,$(notdir $(ERL_SOURCES)))
##所有对应的erl beam文件
ERL_OBJECTS := $(ERL_SOURCES2:%.erl=%.$(EMULATOR))
##输出文件
EBIN_FILES = $(ERL_OBJECTS)


all: $(EBIN_FILES)
	  
hrl: 

clean:
	(rm -rf $(EBIN_DIR)/*)

