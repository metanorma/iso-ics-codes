ED7_YAML := $(wildcard yaml/ed7/*.yaml)
ED7_YAML_NORM := $(subst yaml/,norm/,$(ED7_YAML))
ED7_JSON := $(subst yaml,json,$(ED7_YAML))

.PHONY: json-all norm-all

# Generates all JSON output under json/ed{x}/*.json
json-all: $(ED7_JSON)

# Generates yaml/*.norm.yaml which are normalized YAML files
norm-all: $(ED7_YAML_NORM)

yaml/%.yaml:

norm/%.yaml: yaml/%.yaml
	yq -P 'sort_keys(..)' $< > $@

json/%.json: norm/%.yaml
	yq -P -j '.' $< > $@
