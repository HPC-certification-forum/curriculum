defaultTarget:

SAXON := java -jar "./tools/saxon/saxon9he.jar"



####################################################################################################
# allTargets #######################################################################################
####################################################################################################
#
# Adding a file to the `allTargets` variable has two effects:
#   * The file is added to the default target, so that a simple `make` will build it.
#   * The file is added to the clean target, so that `make clean` will remove it.
#
# Included 'rules.mk' files are supposed to add their targets to this variable.
#
####################################################################################################

allTargets := skill-tree/SkillFullyExpanded-auto-generated.xsd

allTargets += skill-tree/skills-fully-expanded-auto-generated.xml
allTargets += skill-tree/skills-fully-expanded-non-personal-speech-auto-generated.xml
allTargets += skill-tree/skills-fully-expanded-personal-speech-auto-generated.xml

allTargets += skill-tree/root-expert-skills-non-personal-speech-auto-generated.mm
allTargets += skill-tree/root-expert-skills-personal-speech-auto-generated.mm
allTargets += skill-tree/skill-tree-basic-skills-non-personal-speech-auto-generated.mm
allTargets += skill-tree/skill-tree-basic-skills-personal-speech-auto-generated.mm
allTargets += skill-tree/skill-tree-expert-skills-non-personal-speech-auto-generated.mm
allTargets += skill-tree/skill-tree-expert-skills-personal-speech-auto-generated.mm
allTargets += skill-tree/skill-tree-intermediate-skills-non-personal-speech-auto-generated.mm
allTargets += skill-tree/skill-tree-intermediate-skills-personal-speech-auto-generated.mm
allTargets += skill-tree/test-certificate-basic-skills-non-personal-speech-auto-generated.mm
allTargets += skill-tree/test-certificate-basic-skills-personal-speech-auto-generated.mm

allTargets += skill-tree/skills-non-personal-speech-auto-generated.xml
allTargets += skill-tree/skills-personal-speech-auto-generated.xml






####################################################################################################
# Rules to generate 'rules.mk' files, and their includes. ##########################################
####################################################################################################
#
# A rules.mk file is expected to:
#   * Define additional rules.
#   * Add the targets of these additional rules to the `allTargets` make variable.
#
####################################################################################################

curDir := .
loadRules = $(eval curDir := $(curDir)/$(1)) \
            $(eval include $(curDir)/rules.mk) \
            $(eval curDir := $(shell dirname $(curDir)))

$(call loadRules,visualization)



####################################################################################################
# other rules ######################################################################################
####################################################################################################

# kh 17.05.18 expand the (flat) skill tree structure to create a fully expanded version of the tree (i.e. a tree with (many) "redundant nodes")
#             this is mainly used to detect cyclic dependencies (i.e. errors) in subskill references (e.g. Skill A -> Skill B -> Skill C -> Skill A)

# kh 17.05.18 copy the skill tree in SkillsBase.xml and insert non-personal speech prefixes to the description items of a skill (e.g. "Ability to ...", "Knowledge of ...")
# kh 24.05.18 dependency of skill-tree/skills-fully-expanded-auto-generated.xml is artificially inserted here to force an early expansion of the skill tree in order to detect cyclic dependencies
skill-tree/skills-non-personal-speech-auto-generated.xml: skill-tree/SkillsBase.xml skill-tree/skills-fully-expanded-auto-generated.xml
	$(SAXON) -o:"$@" "$<" "skill-tree/SkillsBase2SkillsWithSpeechPrefix.xsl" "PersonalSpeech=false"

# kh 17.05.18 copy the skill tree in SkillsBase.xml and insert personal speech prefixes to the description items of a skill (e.g. "You will learn to ...", "You will learn about ...")
# kh 24.05.18 dependency of skill-tree/skills-fully-expanded-auto-generated.xml is artificially (redundantly) inserted here to force an early expansion of the skill tree in order to detect cyclic dependencies
skill-tree/skills-personal-speech-auto-generated.xml: skill-tree/SkillsBase.xml skill-tree/skills-fully-expanded-auto-generated.xml
	$(SAXON) -o:"$@" "$<" "skill-tree/SkillsBase2SkillsWithSpeechPrefix.xsl" "PersonalSpeech=true"



# kh 17.05.18 create the slightly different schema description based on Skill.xsd for the validation of the fully expanded variants of the skill tree (e.g. skills-fully-expanded-non-personal-speech-auto-generated.xml)
skill-tree/SkillFullyExpanded-auto-generated.xsd: skill-tree/Skill.xsd
	$(SAXON) -o:"$@" "$<" "skill-tree/SkillSchema2SkillFullyExpandedSchema.xsl"

skill-tree/skills-fully-expanded-%.xml: skill-tree/skills-%.xml skill-tree/SkillFullyExpanded-auto-generated.xsd
	$(SAXON) -o:"$@" "$<" "skill-tree/SkillTree2FullyExpanded.xsl"

skill-tree/skills-fully-expanded-auto-generated.xml: skill-tree/SkillsBase.xml skill-tree/SkillFullyExpanded-auto-generated.xsd
	$(SAXON) -o:"$@" "$<" "skill-tree/SkillTree2FullyExpanded.xsl"



# kh 17.05.18 create Mindmaps in the Freeplane-XML-format (without references to content files)
skill-tree/root-expert-%.mm: skill-tree/%.xml
	$(SAXON) -o:"$@" "$<" "skill-tree/SkillTree2MindMap.xsl" "TargetName=Root" "TargetLevel=Expert" $(and $(findstring and-content,$@),"CreateLinksToContent=true")

skill-tree/skill-tree-basic-%.mm: skill-tree/%.xml
	$(SAXON) -o:"$@" "$<" "skill-tree/SkillTree2MindMap.xsl" "TargetName=Skill Tree" "TargetLevel=Basic" $(and $(findstring and-content,$@),"CreateLinksToContent=true")

skill-tree/skill-tree-expert-%.mm: skill-tree/%.xml
	$(SAXON) -o:"$@" "$<" "skill-tree/SkillTree2MindMap.xsl" "TargetName=Skill Tree" "TargetLevel=Expert" $(and $(findstring and-content,$@),"CreateLinksToContent=true")

skill-tree/skill-tree-intermediate-%.mm: skill-tree/%.xml
	$(SAXON) -o:"$@" "$<" "skill-tree/SkillTree2MindMap.xsl" "TargetName=Skill Tree" "TargetLevel=Intermediate" $(and $(findstring and-content,$@),"CreateLinksToContent=true")

skill-tree/test-certificate-basic-%.mm: skill-tree/%.xml
	$(SAXON) -o:"$@" "$<" "skill-tree/SkillTree2MindMap.xsl" "TargetName=Test Certificate" "TargetLevel=Basic" $(and $(findstring and-content,$@),"CreateLinksToContent=true")



####################################################################################################
# defaultTarget and clean targets ##################################################################
####################################################################################################
#
# Should be last to ensure that `allTargets` is complete at this point.
#
####################################################################################################

defaultTarget: $(allTargets)

clean:
	rm -f $(allTargets)
