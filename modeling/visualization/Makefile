V_jsSources := $(addprefix ./,license.js \
                                      utilities.js \
                                      hoverBox.js \
                                      menu.js \
                                      collapsable.js \
                                      skill.js \
                                      skillList.js \
                                      main.js)

skill-tree.min.js: $(V_jsSources) Makefile
	closure-compiler --language_in ECMASCRIPT5 --charset UTF-8 $(V_jsSources) --js_output_file skill-tree.min.js
