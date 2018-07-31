$(call loadRules,skillTreeConversion)

#The instructions defining how files are to be renamed, and also which files are to be copied to the web deployment directory.
#Each word consists of two colon separated parts, the first part gives the source file path, the second part gives the web-server compatible name.
V_scriptRenameInstructions := js_libs/Treant.css|treant.css \
                              js_libs/Treant.js|treant.js \
                              js_libs/bootstrap.min.css|bootstrap.min.css \
                              js_libs/jquery.easing.js|jquery.easing.js \
                              js_libs/jquery.min.js|jquery.min.js \
                              js_libs/raphael.min.js|raphael.min.js \
                              skillTree.css|skill-tree.css \
                              skillTree.min.js|skill-tree.min.js
V_dataRenameInstructions := build/data/mergedSkills/domainDefinitions.json|domain-definitions.json \
                            build/data/mergedSkills/roleDefinitions.json|role-definitions.json \
                            build/data/mergedSkills/skillAuthors.json|skill-authors.json \
                            build/data/mergedSkills/skillBackgrounds.json|skill-backgrounds.json \
                            build/data/mergedSkills/skillData.json|skill-data.json \
                            build/data/mergedSkills/skillDescriptions.json|skill-descriptions.json \
                            build/data/mergedSkills/skillTreeStructure.json|skill-tree-structure.json

V_jsSources := $(addprefix $(curDir)/,utilities.js \
                                      hoverBox.js \
                                      menu.js \
                                      collapsable.js \
                                      skill.js \
                                      skillList.js \
                                      main.js)
V_compiledJsFile := $(curDir)/skillTree.min.js
V_mapFile := $(curDir)/skillTree.map
V_finalProductsDir := build/web-deployment
V_baseUrlConfigFile := $(curDir)/deployedBaseUrl
V_indexHtml := $(curDir)/index.html

$(V_finalProductsDir):
	mkdir -p $(V_finalProductsDir)

#Generate the rules for the renamings defined above.
$(foreach V_instruction, $(addprefix $(curDir)/,$(V_scriptRenameInstructions)) $(V_dataRenameInstructions), \
	$(eval V_instructionWords := $(subst |, ,$(V_instruction))) \
	$(eval V_source := $(word 1,$(V_instructionWords))) \
	$(eval V_dest := $(V_finalProductsDir)/$(word 2,$(V_instructionWords))) \
	\
	$(eval allTargets += $(V_dest)) \
	$(eval $(V_dest): $(V_source) Makefile | $(V_finalProductsDir); \
		cp $(V_source) $(V_dest)))

#Compute `sed` substitute commands that replace the paths with Fiona-adapted file names.
#In addition to the rename instructions, .js and .css files are prepended with the base URL for the deployment,
#while .json files have their directory part stripped from the source path, as that part is added via code in index.html.
V_scriptRenames = $(subst |,|$(shell head -n1 '$(V_baseUrlConfigFile)'), $(V_scriptRenameInstructions))
V_dataRenames := $(notdir $(V_dataRenameInstructions))
V_renameSubstitutions = $(addprefix s|, $(addsuffix |;, $(V_scriptRenames) $(V_dataRenames)))

#Rule to ask user for a deployment URL, and to cache that decision.
$(V_baseUrlConfigFile):
	@echo "https://my.cool.domain.org/some/dir/path/" > $(V_baseUrlConfigFile)
	@echo "" >> $(V_baseUrlConfigFile)
	@echo "# The first line of this file will be used as a prefix for all URLs to fetch data/scripts for the Skill-Tree visualization applet." >> $(V_baseUrlConfigFile)
	@echo "# You should change the dummy value above to the web location that you intend deploying the Skill-Tree viewer to." >> $(V_baseUrlConfigFile)
	@echo "# This is only relevant if you actually want to deploy the Skill-Tree visualizer yourself." >> $(V_baseUrlConfigFile)
	@echo "warning: no '$(V_baseUrlConfigFile)' file found, creating a dummy one" 1>&2
	@echo "note: if you actually want to deploy the Skill-Tree viewer, you should edit '$(V_baseUrlConfigFile)' to match your intended web location" 1>&2

#Special rule for index.html, because this needs sed to adjust the paths inside.
allTargets += $(V_finalProductsDir)/index.html
$(V_finalProductsDir)/index.html: $(V_indexHtml) Makefile $(V_baseUrlConfigFile) | $(V_finalProductsDir)
	sed '/url *=/d; s>dirname *=.*$$>dirname = "$(shell head -n1 '$(V_baseUrlConfigFile)')">; $(V_renameSubstitutions)' $(V_indexHtml) > $(V_finalProductsDir)/index.html

allTargets += $(V_compiledJsFile)
$(V_compiledJsFile) $(V_mapFile): $(V_jsSources) Makefile
	closure-compiler --language_in ECMASCRIPT5 $(addprefix --js , $(V_jsSources)) --js_output_file $@ --compilation_level SIMPLE_OPTIMIZATIONS --create_source_map $(V_mapFile)
