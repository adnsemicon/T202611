YA = \033[1;33m>\033[0m

SRCS := $(wildcard source/*.c)
OBJS := $(patsubst source/%.c,build/%.o, $(SRCS))

print:
	@echo "$(SRCS)"
	@echo ""
	@echo "$(OBJS)"

build log:
	@mkdir -p $@
	@echo "*" > $@/.gitignore
	@echo -e "$(YA) Created $@ directory"

.PHONY: clean
clean:
	@rm -rf build
	@echo -e "$(YA) Removed build directory"

.PHONY: clean_full
clean_full:
	@make -s clean
	@rm -rf log
	@echo -e "$(YA) Removed log directory"

build/%.o: source/%.c | build
	@gcc -c $< -o $@ -I include
	@echo -e "$(YA) Created $@"

.PHONY: all
all: $(OBJS) log
	@gcc $(OBJS) -o build/run.exe
	@./build/run.exe | tee log/$(shell date +%Y%m%d_%H%M%S).log
