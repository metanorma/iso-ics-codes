# This is necessary for the "process substitution" used in the `diff` command
SHELL=/bin/bash

ED7_YAML := $(wildcard yaml/**/*.yaml)
# ED7_YAML_NORM := $(subst yaml/,norm/,$(ED7_YAML))
ED7_JSON := $(subst yaml,json,$(ED7_YAML))

.PHONY: json-all norm-all

# Generates all JSON output under json/ed{x}/*.json
json-all: $(ED7_JSON)

check-normalize: normalize.diff
	@if [ "$(shell cat normalize.diff | wc -l | bc)" != "0" ]; then \
		echo "WARNING: YAML files committed should be first normalized with 'make normalize'"; \
		cat normalize.diff; \
	  exit 1; \
	fi

normalize:
	@for f in $(ED7_YAML); do \
	  yq -P --inplace 'sort_keys(..)' $$f; \
	done

normalize.diff: $(ED7_YAML)
	$(eval TEMP_DIR := $(shell mktemp -d))
	@echo -n > $@; \
	for f in $(ED7_YAML); do \
		mkdir -p $(TEMP_DIR)/$$(dirname $$f); \
		yq -P 'sort_keys(..)' $$f > $(TEMP_DIR)/$$f; \
		diff -u $$f $(TEMP_DIR)/$$f >> $@; \
	done; \
	rm -rf $(TEMP_DIR)

yaml/%.yaml:

json/%.json: yaml/%.yaml
	yq -P -j '.' $< > $@
