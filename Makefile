# This Makefile is dirty

.PHONY: todos docs clean help

help:
	@echo "Commands"
	@echo "========"
	@echo "todos"
	@echo "todo:NAME"
	@echo "\tLists TODO and FIXME for source files"
	@echo "docs"
	@echo "doc:NAME"
	@echo "\tGenerates documentation for source files"
	@echo "build:NAME"
	@echo "\tCompiles target and its dependencies"
	@echo "run:NAME"
	@echo "\tCompiles and runs target"
	@echo "display:NAME"
	@echo "\tOpens waveform for target"
	@echo "create:NAME"
	@echo "\tCreates new module or testbench (ends on _tb)"
	@echo "help"
	@echo "\tShows this help"
	@echo "clean"
	@echo "\tCleans build directory"
	@echo "dist-clean"
	@echo "\tCleans all generated directories (build, docs, traces)"
	@echo
	@echo "Variables"
	@echo "========="
	@echo "VERBOSE"
	@echo "\tHides messages if set to 0"
	@echo "CFLAGS"
	@echo "\tExtra flags for compiler"
	@echo

todos:
	@grep --color -e TODO -e FIXME -n -H -s `find . -name "*.v"` \
		|| utils/log info Nothing to do

todo\:%:
	@test `find . -name $(patsubst todo:%,%.v,$@)` \
		|| { utils/log error "$(patsubst todo:%,%.v,$@) not found"; exit; }
	@grep --color -e TODO -e FIXME -n -H -s \
		`utils/list-deps $(patsubst todo:%,%.v,$@)` \
		|| utils/log info "Nothing to do"

docs:
	@for src in `find . -name "*.v"`; do utils/gen-doc $$src; done

doc\:%:
	@test `find . -name $(patsubst doc:%,%.v,$@)` \
		|| { utils/log error "$(patsubst doc:%,%.v,$@) not found"; exit; }
	@utils/gen-doc `find . -name $(patsubst doc:%,%.v,$@)`

build\:%:
	@test `find . -name $(patsubst build:%,%.v,$@)` \
		|| { utils/log error "$(patsubst build:%,%.v,$@) not found"; exit; }
	@utils/log info Building $(patsubst build:%,%,$@)
	@mkdir -p build
	@iverilog -o $(patsubst build:%,build/%,$@) $(CFLAGS) -Isrc -Itest \
		`utils/list-deps $(patsubst build:%,%.v,$@)`

run\:%: 
	@make -s $(patsubst run:%,build:%,$@)
	@utils/log info Running $(patsubst run:%,%,$@)
	@vvp $(patsubst run:%,build/%,$@)

display\:%:
	@make -s $(patsubst display:%,run:%,$@)
	@utils/display-wave $(patsubst display:%,%.vcd,$@)

create\:%:
	@utils/boilerplate $(patsubst create:%,%,$@)

clean:
	@utils/log info Cleaning build directory
	@rm -rf build

dist-clean:
	@utils/log info Cleaning everything
	@rm -rf build docs traces
