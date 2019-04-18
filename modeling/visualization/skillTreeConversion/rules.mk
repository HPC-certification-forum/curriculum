STC_dataSource := skill-tree/skills-non-personal-speech-auto-generated.xml
STC_contentElements := skill-tree/ContentElements.xml
STC_outputBaseDir := build/data
STC_baseNames := skillBackgrounds \
             skillDescriptions \
             skillContents \
             skillAuthors \
             domainDefinitions \
             roleDefinitions \
             skillData \
             skillTreeStructure
STC_dirNames := $(STC_outputBaseDir)/leveledSkills \
            $(STC_outputBaseDir)/mergedSkills

STC_fileNames := $(addsuffix .json, $(STC_baseNames) $(addsuffix .min, $(STC_baseNames)))
STC_generatedFiles := $(foreach dirName,$(STC_dirNames),$(addprefix $(dirName)/, $(STC_fileNames)))
STC_SKILL_TREE_CONVERTER := ./$(curDir)/convertSkillTree

allTargets += $(STC_generatedFiles)

$(STC_dirNames):
	mkdir -p '$@'

#XXX: Warning: Dirty trick ahead.
#
# The `$(STC_generatedFiles)` targets are all built in one go, but `make` does not have a syntax available to describe this.
# If we used `$(STC_generatedFiles)` directly as the target of a rule, `make` would think that it needed to execute the recipe for each file separately.
# Thus, it will execute the skill tree converter 28 times.
# Definitely not what we want.
#
# There is a trick for GNU-make to use a pattern rule like `$(addsuffix /%.json,$(STC_dirNames)): ...` in this case
# to force `make` to actually reconsider the timestamps before executing the recipe another time.
# This would work for sequential builds, but not with `make -j`:
# When building in parallel mode, make would still start some executions of the recipe concurrently.
# With all the dangers of concurrently writing to the same file included.
# Most definitely not what we want.
#
# The following works around this problem by introducing an intermediate target to force `make` to first execute our recipe at most once,
# and then "build" the real targets as a noop.
# The .INTERMEDIATE has the effect of `make` deleting the temp file after building it if it did not exist beforehand,
# and of directly considering the temp file's prerequisites when deciding whether one of the `$(STC_generatedFiles)` targets must be rebuilt.
#
# Known Bug:
# If a user touches the temp file after touching a prerequisite,
# `make` will only execute the empty recipes that it thinks are building the resulting files from the temp file.
# Afaik, there is no way of telling `make` to ignore the temp file's timestamp entirely, so we have to live with this.
# My mitigation for this is to use a temp file name with 96 bits of entropy, making the odds of a user accidentally creating it rather long.

.INTERMEDIATE: temp_L9JkwgVXGr0mypfE
$(STC_generatedFiles): temp_L9JkwgVXGr0mypfE
temp_L9JkwgVXGr0mypfE: $(curDir)/rules.mk $(STC_SKILL_TREE_CONVERTER) $(wildcard $(curDir)/*.py) $(STC_dataSource) $(wildcard $(STC_contentElements)) | $(STC_dirNames)
	@echo generating files...
	@$(STC_SKILL_TREE_CONVERTER) -o $(STC_outputBaseDir) -s $(STC_dataSource) $(and $(wildcard $(STC_contentElements)),-c $(STC_contentElements))
	@touch temp_L9JkwgVXGr0mypfE
