SHELL := /bin/bash

OPERATOR_NAME   := eqube-operator
TEMPLATE_FILE   := catalog-templates/basic_template.yaml
CATALOG_DIR     := ../../catalogs
CATALOG_VERSIONS := v4.19 v4.20 v4.21 v4.22

.PHONY: catalogs
catalogs:
	@for ver in $(CATALOG_VERSIONS); do \
		mkdir -p $(CATALOG_DIR)/$$ver/$(OPERATOR_NAME); \
		opm alpha render-template basic \
			-o yaml \
			--migrate-level bundle-object-to-csv-metadata \
			< $(TEMPLATE_FILE) \
			> $(CATALOG_DIR)/$$ver/$(OPERATOR_NAME)/catalog.yaml; \
		echo "Generated catalog for $$ver"; \
	done

.PHONY: validate
validate:
	@for ver in $(CATALOG_VERSIONS); do \
		echo "Validating $$ver..."; \
		opm validate $(CATALOG_DIR)/$$ver; \
	done

.PHONY: validate-catalogs
validate-catalogs: validate
