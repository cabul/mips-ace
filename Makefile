BUILD=out
TEST=test
TESTS=$(patsubst $(TEST)/%.txt, build/%, $(wildcard $(TEST)/*.txt))
SAVES=$(patsubst $(TEST)/%.log, $(TEST)/%, $(wildcard $(TEST)/*.log))

NC=\033[0m
RED=\033[0;31m
GREEN=\033[0;32m

all: $(TESTS)

tests: $(SAVES)

help:
	@echo "check          - Checks dependencies"
	@echo "list           - Lists all TESTS and SAVES"
	@echo "build/NAME     - Builds testbench NAME"
	@echo "all            - Builds all testbenches"
	@echo "run/NAME       - Runs testbench NAME"
	@echo "display/NAME   - Opens GTKWave for trace of NAME"
	@echo "test/NAME      - Runs testbench NAME against save"
	@echo "tests          - Runs all testbenchs against their saves"
	@echo "clean          - Cleans directory"
	@echo "todo           - Lists all TODOS and FIXMES in source files"
	@echo "module/NAME    - Initiates the new module NAME"
	@echo "testbench/NAME - Initiates the new testbench NAME"
	@echo "save/NAME      - Saves the log for testbench NAME"

todo:
	@grep --color -e TODO -e FIXME -n -H -s `find . -name "*.v"` || echo "Nothing to do"

list:
	@echo "TESTS"
	@echo "====="
	@for t in $(patsubst build/%, %, $(TESTS)); do echo "* $$t"; done
	@echo
	@echo "SAVES"
	@echo "====="
	@for t in $(patsubst $(TEST)/%, %, $(SAVES)); do echo "* $$t"; done

build/%: $(TEST)/%.txt
	@mkdir -p $(BUILD)
	@iverilog -c $< -o $(patsubst build/%, $(BUILD)/%, $@)

run/%: build/%
	@vvp $(patsubst build/%, $(BUILD)/%, $<)

test/%: $(TEST)/%.txt
	@mkdir -p $(BUILD)
	@make -s $(patsubst test/%, run/%, $@) > $(patsubst test/%, $(BUILD)/%.log, $@)
	@printf "* $(patsubst test/%,%,$@)\t"
	@diff $(patsubst %.txt, %.log, $<) $(patsubst $(TEST)/%.txt, $(BUILD)/%.log, $<) > /dev/null \
		&& echo "${GREEN}OK${NC}" \
		|| echo "${RED}Failed${NC}"

module/%:
	@test -f $(patsubst module/%, %.v, $@) && echo "File exists" || { \
		printf "\`ifndef _%s\n" $(patsubst module/%, %, $@) >> $(patsubst module/%, %.v, $@); \
		printf "\`define _%s\n" $(patsubst module/%, %, $@) >> $(patsubst module/%, %.v, $@); \
		echo >> $(patsubst module/%, %.v, $@); \
		printf "//TODO Write module %s\n" $(patsubst module/%, %, $@) >> $(patsubst module/%, %.v, $@); \
		printf "module %s;\n" $(patsubst module/%, %, $@) >> $(patsubst module/%, %.v, $@); \
		echo "endmodule" >> $(patsubst module/%, %.v, $@); \
		echo >> $(patsubst module/%, %.v, $@); \
		echo "\`endif" >> $(patsubst module/%, %.v, $@); \
		}

testbench/%:
	@test -f $(patsubst testbench/%, $(TEST)/%.v, $@) && echo "File exists" || { \
		printf "//TODO Write testbench %s\n" $(patsubst testbench/%, %, $@) >> $(patsubst testbench/%, $(TEST)/%.v, $@); \
		printf "module %s;\n" $(patsubst testbench/%, %, $@) >> $(patsubst testbench/%, $(TEST)/%.v, $@); \
		echo >> $(patsubst testbench/%, $(TEST)/%.v, $@); \
		echo "initial begin" $(patsubst testbench/%, %, $@) >> $(patsubst testbench/%, $(TEST)/%.v, $@); \
		printf "\t\$$dumpfile(\"%s\");\n" $(patsubst testbench/%, $(BUILD)/%.vcd, $@) >> $(patsubst testbench/%, $(TEST)/%.v, $@); \
		printf "\t\$$dumpvars(0, %s);\n" $(patsubst testbench/%, %, $@) >> $(patsubst testbench/%, $(TEST)/%.v, $@); \
		echo "end" $(patsubst testbench/%, %, $@) >> $(patsubst testbench/%, $(TEST)/%.v, $@); \
		echo >> $(patsubst testbench/%, $(TEST)/%.v, $@); \
		echo "endmodule" >> $(patsubst testbench/%, $(TEST)/%.v, $@); \
		echo $(patsubst testbench/%, $(TEST)/%.v, $@) > $(patsubst testbench/%, $(TEST)/%.txt, $@); \
		}

display/%: run/%
	@ps | grep -sq gtkwave || \
		gtkwave $(patsubst display/%, $(BUILD)/%.vcd, $@) >/dev/null  2>&1 &

save/%: $(TEST)/%.txt
	@make -s $(patsubst save/%, run/%, $@) > $(patsubst save/%, $(TEST)/%.log, $@)

check:
	@printf "* Icarus Verilog "
	@test `which iverilog` && echo "${GREEN}Yes${NC}" || echo "${RED}No${NC}"
	@printf "* GTKWave "
	@test `which gtkwave` && echo "${GREEN}Yes${NC}" || echo "${RED}No${NC}"

clean:
	@rm -rf $(BUILD) *.vcd
