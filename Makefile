# This Makefile is dirty

.PHONY: todos clean help

todos:
	@grep --color -e TODO -e FIXME -n -H -s `find . -name "*.v"` \
		|| utils/log info Nothing to do

todo\:%:
	@test `sed -e 's/\./\//g' $(patsubst todo:%find . -wholename $(patsubst todo:%,%.v,$@)` \
		|| { utils/log error "$(patsubst todo:%,%.v,$@) not found"; exit 1; }
	@grep --color -e TODO -e FIXME -n -H -s \
		`utils/list-deps $(patsubst todo:%,%.v,$@)` \
		|| utils/log info "Nothing to do"

build\:%:
	@test `find . -name $(patsubst build:%,%.v,$@)` \
		|| { utils/log error "$(patsubst build:%,%.v,$@) not found"; exit 1; }
	@utils/log info "Building $(patsubst build:%,%,$@) `[ -z "$(CFLAGS)" ] || echo "[$(CFLAGS)]"`"
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

