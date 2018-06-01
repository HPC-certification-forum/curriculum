all: \
     ./skill-tree/skill-tree-expert-skills-non-personal-speech-auto-generated.mm \
     ./skill-tree/skill-tree-expert-skills-personal-speech-auto-generated.mm
	@echo "done all"

# kh 01.06.18 copy the skill tree in SkillsBase.xml and insert non-personal speech prefixes to the description items of a skill (e.g. "Ability to ...", "Knowledge of ...")
./skill-tree/skills-non-personal-speech-auto-generated.xml: ./skill-tree/SkillsBase.xml
	java -jar "./tools/saxon/saxon9he.jar" -o:"./skill-tree/skills-non-personal-speech-auto-generated.xml" "./skill-tree/SkillsBase.xml" "./skill-tree/SkillsBase2SkillsWithSpeechPrefix.xsl" "PersonalSpeech=false"

# kh 01.06.18 copy the skill tree in SkillsBase.xml and insert personal speech prefixes to the description items of a skill (e.g. "You will learn to ...", "You will learn about ...")
./skill-tree/skills-personal-speech-auto-generated.xml: ./skill-tree/SkillsBase.xml
	java -jar "./tools/saxon/saxon9he.jar" -o:"./skill-tree/skills-personal-speech-auto-generated.xml" "./skill-tree/SkillsBase.xml" "./skill-tree/SkillsBase2SkillsWithSpeechPrefix.xsl" "PersonalSpeech=true"

./skill-tree/skill-tree-expert-skills-non-personal-speech-auto-generated.mm: ./skill-tree/skills-non-personal-speech-auto-generated.xml
	java -jar "./tools/saxon/saxon9he.jar" -o:"./skill-tree/skill-tree-expert-skills-non-personal-speech-auto-generated.mm" "./skill-tree/skills-non-personal-speech-auto-generated.xml" "./skill-tree/SkillTree2MindMap.xsl" \
                  "TargetName=Skill Tree" "TargetLevel=Expert"

./skill-tree/skill-tree-expert-skills-personal-speech-auto-generated.mm: ./skill-tree/skills-personal-speech-auto-generated.xml
	java -jar "./tools/saxon/saxon9he.jar" -o:"./skill-tree/skill-tree-expert-skills-personal-speech-auto-generated.mm" "./skill-tree/skills-personal-speech-auto-generated.xml" "./skill-tree/SkillTree2MindMap.xsl" \
                  "TargetName=Skill Tree" "TargetLevel=Expert"

clean:
	rm \
	   ./skill-tree/skills-non-personal-speech-auto-generated.xml \
	   ./skill-tree/skills-personal-speech-auto-generated.xml \
	   ./skill-tree/skill-tree-expert-skills-non-personal-speech-auto-generated.mm \
	   ./skill-tree/skill-tree-expert-skills-personal-speech-auto-generated.mm
