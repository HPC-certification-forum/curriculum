import json

def dumpJsonFile(data, path: str, **args) -> None:
	"""Create a json file at 'path' that contains the given 'data' object.
	
	Any arguments after 'data' and 'path' are passed on to 'json.dump()'."""

	with open(path, 'w') as file:
		json.dump(data, file, **args)

def writeTreeStructure(skillList, path: str, **args) -> None:
	"""Output a file with a tree structure definition."""
	data = [{
		'define': 'tree',
		'tree': skillList.buildTree()
	}]
	dumpJsonFile(data, path, **args)

def writeCoreSkillData(skillList, path: str, **args) -> None:
	"""Output a file with the core data definitions for all skills."""
	skills = [skill.getCoreData() for skill in skillList]
	for skill in skills: skill['define'] = 'core data'
	dumpJsonFile(skills, path, **args)

def writeDomainLists(skillList, path: str, **args) -> None:
	"""Generate a JSON file that contains an array of domain definitions.

	The structure of the generated file is as follows:
	[
		{
			'define': 'relevance',
			'type': 'Domain',
			'name': 'Morphographic Ornito-Engineering',
			'skills': {
				'<skill-ID-1>': 'low',
				'<skill-ID-2>': 'high',
				...
			}
		},
		...
	]"""
	data = []
	for domain in skillList.listDomains():
		data.append({
			'define': 'relevance',
			'type': 'Domain',
			'name': domain,
			'skills': skillList.skillsRelevantForDomain(domain)
		})
	dumpJsonFile(data, path, **args)

def writeRoleLists(skillList, path: str, **args) -> None:
	"""Generate a JSON file that contains an array of role definitions.

	The structure of the generated file is as follows:
	[
		{
			'define': 'relevance',
			'type': 'Role',
			'name': 'Cyber-Ornito Engineer',
			'skills': {
				'<skill-ID-1>': 'intermediate',
				...
			}
		},
		...
	]"""
	data = []
	for role in skillList.listRoles():
		data.append({
			'define': 'relevance',
			'type': 'Role',
			'name': role,
			'skills': skillList.skillsRelevantForRole(role)
		})
	dumpJsonFile(data, path, **args)

def writeListAttribute(skillList, attributeName: str, path: str, **args) -> None:
	data = []
	for skill in skillList:
		if hasattr(skill, attributeName):
			data.append({
				'define': 'list items',
				'skill': skill.id,
				'attribute': attributeName,
				'value': getattr(skill, attributeName)
			})
	dumpJsonFile(data, path, **args)

def generateFiles(skillList, dirPath) -> None:
	if dirPath[-1] != '/': dirPath = dirPath + '/'
	writeTreeStructure(skillList, dirPath + 'skillTreeStructure.min.json')
	writeTreeStructure(skillList, dirPath + 'skillTreeStructure.json', indent = 4)
	writeCoreSkillData(skillList, dirPath + 'skillData.min.json')
	writeCoreSkillData(skillList, dirPath + 'skillData.json', indent = 4)
	writeDomainLists(skillList, dirPath + 'domainDefinitions.min.json')
	writeDomainLists(skillList, dirPath + 'domainDefinitions.json', indent = 4)
	writeRoleLists(skillList, dirPath + 'roleDefinitions.min.json')
	writeRoleLists(skillList, dirPath + 'roleDefinitions.json', indent = 4)
	writeListAttribute(skillList, 'authors', dirPath + 'skillAuthors.min.json')
	writeListAttribute(skillList, 'authors', dirPath + 'skillAuthors.json', indent = 4)
	writeListAttribute(skillList, 'description', dirPath + 'skillDescriptions.min.json')
	writeListAttribute(skillList, 'description', dirPath + 'skillDescriptions.json', indent = 4)
	writeListAttribute(skillList, 'background', dirPath + 'skillBackgrounds.min.json')
	writeListAttribute(skillList, 'background', dirPath + 'skillBackgrounds.json', indent = 4)
