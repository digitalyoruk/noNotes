PREFIX ?= $(HOME)/.local
BINDIR = $(PREFIX)/bin
BUILD_DIR = build

.PHONY: all build install uninstall clean

all: build

build:
	@mkdir -p $(BUILD_DIR)
	clang -Wall -Wextra -O2 -framework Foundation -framework AppKit \
		-o $(BUILD_DIR)/nonotes src/nonotes.m

install: build
	@./scripts/install.sh

uninstall:
	@./scripts/uninstall.sh

clean:
	rm -rf $(BUILD_DIR)
