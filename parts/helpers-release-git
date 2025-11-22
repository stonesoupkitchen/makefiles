define increment_version
$(shell echo $(GIT_TAG) | sed 's/^v//' | awk -F. -v part=$(1) '{
	if (part == "major") { print ($$1+1) ".0.0" }
	else if (part == "minor") { print $$1 "." ($$2+1) ".0" }
	else if (part == "patch") { print $$1 "." $$2 "." ($$3+1) }
}')
endef

