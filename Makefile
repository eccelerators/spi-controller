HTML_THEME ?= 'haiku'

PWD=$(shell pwd)
_types := docs vhdl c

all: $(_types) html

$(_types):
	hxsc --out-dir src-gen/$@ $@ hxs/SpiController.hxs
	
html: docs
ifeq (, $(shell which sphinx-build))
$(error "No Sphinx installed. Please install Sphinx for generate HTML Files. See: https://www.sphinx-doc.org/en/master/usage/installation.html")
endif
	rm -fr src/docs/src-gen
	ln -r -s src-gen/docs src/docs/src-gen
	sphinx-build \
		-b html \
		-C \
		-D html_theme=$(HTML_THEME) \
		-D html_static_path= \
		-D templates_path= \
		-D project='SpiController' \
		-D copyright='2022, eccelerators.com' \
		-D author='eccelerators.com' \
		-D version='1.0.0' \
		-D release='1.0.0' \
		src/docs \
		src-gen/html

clean:
	rm -fr src/docs/src-gen
	rm -fr src-gen

.PHONY: all html $(_types) clean html
