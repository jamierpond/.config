# Jamie's dotfiles - Nix edition
# Usage: make <target>

HOSTNAME := $(shell hostname)
USERNAME := $(shell whoami)
SYSTEM := $(shell uname -s)

# Detect architecture
ifeq ($(SYSTEM),Darwin)
	ARCH := $(shell uname -m)
	ifeq ($(ARCH),arm64)
		NIX_SYSTEM := aarch64-darwin
	else
		NIX_SYSTEM := x86_64-darwin
	endif
	DARWIN_HOST ?= macbook
else
	NIX_SYSTEM := x86_64-linux
endif

.PHONY: help setup switch update clean gc test docker-build docker-test docker-run ci info darwin-build darwin-activate darwin-switch darwin-switch-debug edit edit-darwin shells

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# ============================================================================
# Setup
# ============================================================================

setup: ## First-time setup (requires nix to be installed)
	@command -v nix >/dev/null 2>&1 || { echo "Error: Nix is not installed. Install it first: https://nixos.org/download"; exit 1; }
ifeq ($(SYSTEM),Darwin)
	@$(MAKE) install-darwin
else
	@$(MAKE) install-hm
endif

install-darwin: ## Bootstrap nix-darwin (macOS)
ifeq ($(SYSTEM),Darwin)
	@echo "Bootstrapping nix-darwin..."
	@$(MAKE) darwin-switch
else
	@echo "nix-darwin is macOS only"
	@exit 1
endif

install-hm: ## Bootstrap home-manager (Linux)
	@echo "Bootstrapping home-manager for $(USERNAME)@$(HOSTNAME)..."
	nix run home-manager -- switch --flake .#$(USERNAME)@$(HOSTNAME)

# ============================================================================
# Daily use
# ============================================================================

switch: ## Apply config for current machine
ifeq ($(SYSTEM),Darwin)
	@$(MAKE) darwin-switch
else
	home-manager switch --flake .#$(USERNAME)@$(HOSTNAME)
endif

switch-debug: ## Apply config with verbose output
ifeq ($(SYSTEM),Darwin)
	@$(MAKE) darwin-switch-debug
else
	home-manager switch --flake .#$(USERNAME)@$(HOSTNAME) --show-trace
endif

# Darwin-specific targets (build as user, activate as root)
darwin-build: ## Build darwin config without activating
ifeq ($(SYSTEM),Darwin)
	nix build .#darwinConfigurations.$(DARWIN_HOST).system
else
	@echo "darwin-build is macOS only"
	@exit 1
endif

darwin-activate: ## Activate darwin config (requires sudo)
ifeq ($(SYSTEM),Darwin)
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(DARWIN_HOST)
else
	@echo "darwin-activate is macOS only"
	@exit 1
endif

darwin-switch: darwin-build darwin-activate ## Build and activate darwin config

darwin-switch-debug: ## Build and activate darwin config with verbose output
ifeq ($(SYSTEM),Darwin)
	nix build .#darwinConfigurations.$(DARWIN_HOST).system --show-trace
	sudo ./result/sw/bin/darwin-rebuild switch --flake .#$(DARWIN_HOST) --show-trace
else
	@echo "darwin-switch-debug is macOS only"
	@exit 1
endif

update: ## Update all flake inputs
	nix flake update

update-nixpkgs: ## Update only nixpkgs
	nix flake lock --update-input nixpkgs

update-home-manager: ## Update only home-manager
	nix flake lock --update-input home-manager

# ============================================================================
# Maintenance
# ============================================================================

gc: ## Garbage collect old generations (keeps 7 days)
	nix-collect-garbage --delete-older-than 7d

gc-all: ## Aggressive garbage collection (deletes everything unused)
	nix-collect-garbage -d
	nix-store --optimise

generations: ## List home-manager generations
	home-manager generations

rollback: ## Rollback to previous generation
ifeq ($(SYSTEM),Darwin)
	darwin-rebuild --rollback
else
	home-manager generations | head -2 | tail -1 | awk '{print $$NF}' | xargs -I {} home-manager switch --flake {}
endif

# ============================================================================
# Quick edit
# ============================================================================

edit: ## Edit packages in $EDITOR, then rebuild
	$${EDITOR:-nvim} home/default.nix && $(MAKE) switch

edit-darwin: ## Edit darwin config in $EDITOR, then rebuild
	$${EDITOR:-nvim} darwin/default.nix && $(MAKE) darwin-switch

# ============================================================================
# Search & explore
# ============================================================================

search: ## Search nixpkgs (usage: make search q=ripgrep)
	nix search nixpkgs $(q)

repl: ## Open nix repl with flake
	nix repl .

shells: ## List available dev shells
	@nix flake show --json 2>/dev/null | jq -r '.devShells | to_entries[] | "\(.key): \(.value | keys | join(", "))"'

why: ## Show why a package is installed (usage: make why p=gcc)
	nix why-depends ~/.nix-profile $(p)

# ============================================================================
# Testing
# ============================================================================

check: ## Validate flake without building
	nix flake check

build: ## Build config without activating
ifeq ($(SYSTEM),Darwin)
	nix build .#darwinConfigurations.$(DARWIN_HOST).system
else
	nix build .#homeConfigurations.$(USERNAME)@$(HOSTNAME).activationPackage
endif

test: ## Run setup tests
	@bash ./test_setup.sh

docker-build: ## Build Docker test image (x86_64)
	DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -t dotfiles-test .

docker-test: ## Run full test in Docker container (x86_64)
	DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -t dotfiles-test .
	docker run --platform linux/amd64 --rm dotfiles-test

docker-shell: ## Interactive shell in test container (x86_64)
	DOCKER_BUILDKIT=1 docker build --platform linux/amd64 -t dotfiles-test .
	docker run --platform linux/amd64 --rm -it dotfiles-test

docker-run: ## Run container without rebuilding
	docker run --platform linux/amd64 --rm -it dotfiles-test

# ============================================================================
# CI
# ============================================================================

ci: ## Run CI checks (used by GitHub Actions)
	@echo "==> Checking flake..."
	nix flake check
	@echo "==> Building home-manager config..."
	nix build .#homeConfigurations.jamie@ci.activationPackage --no-link
	@echo "==> All checks passed!"

# ============================================================================
# Info
# ============================================================================

info: ## Show current system info
	@echo "System:   $(SYSTEM)"
	@echo "Arch:     $(NIX_SYSTEM)"
	@echo "Hostname: $(HOSTNAME)"
	@echo "Username: $(USERNAME)"
	@echo ""
	@echo "Nix version:"
	@nix --version 2>/dev/null || echo "  (not installed)"
	@echo ""
	@echo "Flake inputs:"
	@nix flake metadata 2>/dev/null | grep -A 100 "Inputs:" || echo "  (flake not initialized)"
