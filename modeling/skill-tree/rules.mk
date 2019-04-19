allTargets += $(curDir)/SkillFullyExpanded-auto-generated.xsd

allTargets += $(curDir)/skills-fully-expanded-auto-generated.xml
allTargets += $(curDir)/skills-fully-expanded-non-personal-speech-auto-generated.xml
allTargets += $(curDir)/skills-fully-expanded-personal-speech-auto-generated.xml

allTargets += $(curDir)/getting-started-with-hpc-clusters-basic-skills-non-personal-speech-auto-generated.mm
allTargets += $(curDir)/getting-started-with-hpc-clusters-basic-skills-personal-speech-auto-generated.mm
allTargets += $(curDir)/root-expert-skills-non-personal-speech-auto-generated.mm
allTargets += $(curDir)/root-expert-skills-personal-speech-auto-generated.mm
allTargets += $(curDir)/skill-tree-basic-skills-non-personal-speech-auto-generated.mm
allTargets += $(curDir)/skill-tree-basic-skills-personal-speech-auto-generated.mm
allTargets += $(curDir)/skill-tree-expert-skills-non-personal-speech-auto-generated.mm
allTargets += $(curDir)/skill-tree-expert-skills-personal-speech-auto-generated.mm
allTargets += $(curDir)/skill-tree-intermediate-skills-non-personal-speech-auto-generated.mm
allTargets += $(curDir)/skill-tree-intermediate-skills-personal-speech-auto-generated.mm

allTargets += $(curDir)/skills-non-personal-speech-auto-generated.xml
allTargets += $(curDir)/skills-personal-speech-auto-generated.xml

ST_directory := $(curDir)



# kh 17.05.18 expand the (flat) skill tree structure to create a fully expanded version of the tree (i.e. a tree with (many) "redundant nodes")
#             this is mainly used to detect cyclic dependencies (i.e. errors) in subskill references (e.g. Skill A -> Skill B -> Skill C -> Skill A)

# kh 17.05.18 copy the skill tree in SkillsBase.xml and insert non-personal speech prefixes to the description items of a skill (e.g. "Ability to ...", "Knowledge of ...")
# kh 24.05.18 dependency of skill-tree/skills-fully-expanded-auto-generated.xml is artificially inserted here to force an early expansion of the skill tree in order to detect cyclic dependencies
$(ST_directory)/skills-non-personal-speech-auto-generated.xml: $(ST_directory)/SkillsBase.xml $(ST_directory)/skills-fully-expanded-auto-generated.xml
	$(SAXON) -o:"$@" "$<" "$(ST_directory)/SkillsBase2SkillsWithSpeechPrefix.xsl" "PersonalSpeech=false"

# kh 17.05.18 copy the skill tree in SkillsBase.xml and insert personal speech prefixes to the description items of a skill (e.g. "You will learn to ...", "You will learn about ...")
# kh 24.05.18 dependency of skill-tree/skills-fully-expanded-auto-generated.xml is artificially (redundantly) inserted here to force an early expansion of the skill tree in order to detect cyclic dependencies
$(ST_directory)/skills-personal-speech-auto-generated.xml: $(ST_directory)/SkillsBase.xml $(ST_directory)/skills-fully-expanded-auto-generated.xml
	$(SAXON) -o:"$@" "$<" "$(ST_directory)/SkillsBase2SkillsWithSpeechPrefix.xsl" "PersonalSpeech=true"



# kh 17.05.18 create the slightly different schema description based on Skill.xsd for the validation of the fully expanded variants of the skill tree (e.g. skills-fully-expanded-non-personal-speech-auto-generated.xml)
$(ST_directory)/SkillFullyExpanded-auto-generated.xsd: $(ST_directory)/Skill.xsd
	$(SAXON) -o:"$@" "$<" "$(ST_directory)/SkillSchema2SkillFullyExpandedSchema.xsl"



$(ST_directory)/skills-fully-expanded-%.xml: $(ST_directory)/skills-%.xml $(ST_directory)/SkillFullyExpanded-auto-generated.xsd
	$(SAXON) -o:"$@" "$<" "$(ST_directory)/SkillTree2FullyExpanded.xsl"

$(ST_directory)/skills-fully-expanded-auto-generated.xml: $(ST_directory)/SkillsBase.xml $(ST_directory)/SkillFullyExpanded-auto-generated.xsd
	$(SAXON) -o:"$@" "$<" "$(ST_directory)/SkillTree2FullyExpanded.xsl"



# kh 17.05.18 create Mindmaps in the Freeplane-XML-format (without references to content files)
$(ST_directory)/getting-started-with-hpc-clusters-basic-%.mm: $(ST_directory)/%.xml
	$(SAXON) -o:"$@" "$<" "$(ST_directory)/SkillTree2MindMap.xsl" "TargetName=Getting Started with HPC Clusters" "TargetLevel=Basic" $(and $(findstring and-content,$@),"CreateLinksToContent=true")

$(ST_directory)/root-expert-%.mm: $(ST_directory)/%.xml
	$(SAXON) -o:"$@" "$<" "$(ST_directory)/SkillTree2MindMap.xsl" "TargetName=Root" "TargetLevel=Expert" $(and $(findstring and-content,$@),"CreateLinksToContent=true")

$(ST_directory)/skill-tree-basic-%.mm: $(ST_directory)/%.xml
	$(SAXON) -o:"$@" "$<" "$(ST_directory)/SkillTree2MindMap.xsl" "TargetName=Skill Tree" "TargetLevel=Basic" $(and $(findstring and-content,$@),"CreateLinksToContent=true")

$(ST_directory)/skill-tree-expert-%.mm: $(ST_directory)/%.xml
	$(SAXON) -o:"$@" "$<" "$(ST_directory)/SkillTree2MindMap.xsl" "TargetName=Skill Tree" "TargetLevel=Expert" $(and $(findstring and-content,$@),"CreateLinksToContent=true")

$(ST_directory)/skill-tree-intermediate-%.mm: $(ST_directory)/%.xml
	$(SAXON) -o:"$@" "$<" "$(ST_directory)/SkillTree2MindMap.xsl" "TargetName=Skill Tree" "TargetLevel=Intermediate" $(and $(findstring and-content,$@),"CreateLinksToContent=true")
