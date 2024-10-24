.PHONY: all clean README.md new

PYTHON := python3
PYTHON_VERSION := $(shell $(PYTHON) -c "import sys; print(f'python{sys.version_info.major}.{sys.version_info.minor}')")
VENV := .venv
VENV_BIN := $(VENV)/bin
VENV_LIB := $(VENV)/lib
VENV_SITE_PACKAGES := $(VENV_LIB)/$(PYTHON_VERSION)/site-packages
VENV_PYTHON := $(VENV_BIN)/python
VENV_PIP := $(VENV_BIN)/pip

all: README.md

clean:
	$(RM) README.md

README.md:
	> README.md
	printf "# 雑記帳\n\n" > README.md
	for file in articles/*/README.md; do \
	    title=$$(grep -m 1 "^## " "$$file" | sed "s/^## //"); \
	    echo "- [$$title]($$file)" >> README.md; \
	done
	printf "\n---\n\n" >> README.md
	ls articles/*/README.md | awk '{ if (NR > 1) printf "\n"; system("cat " $$0) }' >> README.md

$(VENV):
	$(PYTHON) -m venv $(VENV)

$(VENV_SITE_PACKAGES)/uuid6: $(VENV)
	$(VENV_PIP) install uuid6

new: $(VENV_SITE_PACKAGES)/uuid6
	$(VENV_PYTHON) -c "import os, uuid6; path = os.path.join('articles', str(uuid6.uuid7())); os.makedirs(path); open(os.path.join(path, 'README.md'), 'w').close()"
