# Copyright 2018 Nathanael Hübbe
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

import xml.etree.ElementTree

import skill
import termColors

class SkillTreeFormatError(SyntaxError):
	pass
class DanglingSkillReferenceError(SkillTreeFormatError):
	pass
class DanglingParentSkillReferenceError(DanglingSkillReferenceError):
	pass
class CyclicSkillReferenceError(SkillTreeFormatError):
	pass
class MultipleSkillDefinitionError(SkillTreeFormatError):
	pass

class SkillList:
	"""Provides a dictionary of all defined skills.

	The dictionary is keyed with pairs of the skill name and its level `(name, level)`."""

	def __init__(self):
		self.skills = {}
		self.skillsById = {}

	def __iter__(self):
		return self.skills.values().__iter__()

	def __len__(self):
		return self.skills.__len__()

	def registerSkill(self, aSkill) -> None:
		key = aSkill.key()
		if key in self.skills:
			raise MultipleSkillDefinitionError("multiple definition of skill '" + aSkill.name + "' with level '" + aSkill.level + "'")
		if aSkill.id in self.skillsById:
			raise MultipleSkillDefinitionError("multiple definition of skill with ID '" + aSkill.id + "'")
		self.skills[key] = aSkill
		self.skillsById[aSkill.id] = aSkill

	def findSkill(self, name: str, level: str):
		try:
			return self.skills[(name, level)]
		except:
			return None

	def print(self):
		for skill in self:
			skill.print()

	def checkDag(self) -> None:
		"""Checks whether the skill list is complete (no references to skills not on the list) and acyclic (no skill is its own ancestor).

		Raises a DanglingSkillReferenceError if the skill list is incomplete.
		Raises a DanglingParentSkillReferenceError if a skill names a main parent that does not match a parent->child reference.
		Raises a CyclicSkillReferenceError if the graph is found to be cyclic."""

		#Build a dictionary of parent sets that record all parent->child links
		allParents = {}
		for skill in self:
			if not hasattr(skill, "children"): continue
			key = skill.key()
			for child in skill.children:
				parentSet = allParents.get(child, None)
				if parentSet == None:
					parentSet = set()
					allParents[child] = parentSet
				parentSet.add(key)

		#Check that all declared child->parent links are indeed matched by a parent->child link
		for skill in self:
			if skill.parent[0] != "NULL":
				if skill.parent not in allParents[skill.key()]:
					raise DanglingParentSkillReferenceError()

		#Check that all skills are reachable from the roots, and that there are no cyclic references.
		#The later condition is enforced by requiring all parents to be visited before adding a skill to the frontier.
		frontier = set(self.findRoots())
		visited = set()
		while True:
			try:
				curSkill = frontier.pop()
			except:
				break
			visited.add(curSkill)
			if hasattr(curSkill, "children"):
				for childKey in curSkill.children:
					if childKey not in self.skills:
						raise DanglingSkillReferenceError()
					child = self.skills[childKey]
					for childParent in allParents[child]:
						if childParent not in visited: break
					else:
						frontier.add(child)
		if len(visited) != len(self.skills):
			unvisited = set(self.skills.values()) - visited
			strings = [skill.name + " (" + skill.level + ")" for skill in unvisited]
			raise CyclicSkillReferenceError("\n".join(strings))

	def mergeLevels(self):
		skillClasses = {}
		for curSkill in self:
			reducedId = curSkill.reducedId()
			if not reducedId in skillClasses: skillClasses[reducedId] = set()
			skillClasses[reducedId].add(curSkill.id)
		result = SkillList()
		for curClass in skillClasses.values():
			curSkills = [self.skillsById[curId] for curId in curClass]
			result.registerSkill(skill.Skill.mergeSkills(*curSkills))
		return result

	def findRoots(self) -> list:
		"""Identify all skills without a parent."""
		result = []
		for skill in self:
			if skill.parent[0] == 'NULL':
				result.append(skill)
		return result

	def buildTree(self, root = None) -> dict:
		"""Walk the DAG of skills to turn it into a tree by replicating any skill that's visited multiple times.

		Returns a dictionary with the children of the given root skill as keys of the form ('skill name', 'level').
		Each child entry contains another dictionary with the child's skills as its value.
		If no root skill is given, the returned dictionary will contain all the root skills that are present in the SkillList."""

		result = {}
		if root != None:
			if hasattr(root, "children"):
				children = root.children
			else:
				children = []
		else:
			children = [skill.key() for skill in self.findRoots()]
		for child in children:
			childObject = self.findSkill(child[0], child[1])
			result[childObject.id] = self.buildTree(childObject)
		return result

	def listDomains(self) -> set:
		"""Compute the set of all domains to which a skill on this list is relevant."""

		result = set()
		for skill in self:
			if not hasattr(skill, "domains"): continue
			for domain in skill.domains:
				result.add(domain[0])
		return result

	def listRoles(self) -> set:
		"""Compute the set of all roles to which a skill on this list is relevant."""

		result = set()
		for skill in self:
			if not hasattr(skill, "roles"): continue
			for role in skill.roles:
				result.add(role[0])
		return result

	def skillsRelevantForDomain(self, domain: str) -> dict:
		"""Compute a dictionary that maps the ids of all skills that are relevant to the given domain to the respective relevance level.

		The resulting dictionary looks something like this:
		{
			K4.2-E: "High"
			U3.1.4-B: "Low"
		}"""

		result = {}
		for skill in self:
			if not hasattr(skill, "domains"): continue
			for (curDomain, relevance) in skill.domains:
				if curDomain == domain:
					result[skill.id] = relevance
		return result

	def skillsRelevantForRole(self, role: str) -> dict:
		"""Compute a dictionary that maps the ids of all skills that are relevant to the given role to the respective relevance level.

		The resulting dictionary looks something like this:
		{
			K4.2-E: "High"
			U3.1.4-B: "Low"
		}"""

		result = {}
		for skill in self:
			if not hasattr(skill, "roles"): continue
			for (curRole, relevance) in skill.roles:
				if curRole == role:
					result[skill.id] = relevance
		return result

	def readSkillList(xmlPath: str):
		"""Read a skill tree from an XML file and turn it into a list of Skill objects."""

		xmlRoot = xml.etree.ElementTree.parse(xmlPath).getroot()
		skills = SkillList()
		for xmlNode in xmlRoot.getchildren():
			skills.registerSkill(skill.Skill(xmlNode))
		return skills

	def addContents(self, contentElementsPath: str, urlPrefix: str = "") -> None:
		"""Reads the given ContentElements.xml file, and defines a "content" attribute for the respective skills.

		Parses the list of <ContentElement> tags and produces a single link to "urlPrefix/skill-name-level-sl-standalone.html" for each <Slides> tag
		and to "urlPrefix/skill-name-level-ch-standalone.html" for each <Chapters> tag."""

		def simplifyString(string: str) -> str:
			"""Return a copy of the string with only lowercase alphanumeric characters and dashes."""
			result = string.lower()

			for i in range(len(result)):
				if not result[i].isalnum():
					result = result[:i] + "-" + result[i+1:]
			return result

		xmlRoot = xml.etree.ElementTree.parse(contentElementsPath).getroot()
		for xmlNode in xmlRoot.getchildren():
			if xmlNode.tag == "ContentElement":
				skill = self.findSkill(xmlNode.attrib["Name"], xmlNode.attrib["Level"])
				if not skill:
					print(termColors.kBold + "warning: ignoring <ContentElement> tag for unknown skill: " +
						termColors.kBM + "'" + xmlNode.attrib["Name"] + "' (" + xmlNode.attrib["Level"] + ")" + termColors.kNormal)
					continue
				level = xmlNode.attrib["Level"]
				prefix = urlPrefix + simplifyString(xmlNode.attrib["Name"] + " " + level)

				haveSlides = False
				haveChapters = False
				for subtag in xmlNode.getchildren():
					if subtag.tag == "Slides": haveSlides = True
					if subtag.tag == "Chapters": haveChapters = True

				if haveSlides: skill.addContentLink("Slides (" + level + ")", prefix + "-sl-standalone.html")
				if haveChapters: skill.addContentLink("Chapters (" + level + ")", prefix + "-ch-standalone.html")
