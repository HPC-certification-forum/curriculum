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

import benefitDict
import termColors

import difflib
import re
import sys

####################################################################################################
# utilities ########################################################################################
####################################################################################################

def normalizeString(string):
	"""Make a copy of the string with any leading/trailing whitespace removed on all lines, and runs of empty lines reduced to a single empty line."""
	try:
		if string.isspace():	#this also ensures that we get an exception if `string` is not a string, in both cases we return nothing
			return
	except:
		return

	#strip each line of leading/trailing whitespace
	#and reduce any run of empty lines to a single empty line
	lines = string.splitlines()
	stripEmptyLines = True
	for i in range(len(lines)-1, -1, -1):
		lines[i] = lines[i].strip()
		if len(lines[i]) == 0:
			if stripEmptyLines:
				del lines[i]
			stripEmptyLines = True
		else:
			stripEmptyLines = False

	#the code above may leave a single empty line at the beginning, strip that if it exists
	while len(lines) > 0 and len(lines[0]) == 0:
		del lines[0]

	#reassemble the string from its lines
	return "\n".join(lines)

class SkillMismatchError(BaseException):
	def __init__(self, skillA, skillB):
		print("The skill")
		skillA.print()
		print("does not match the skill")
		skillB.print()

####################################################################################################
# the Skill class itself ###########################################################################
####################################################################################################

class Skill:
	"""A Skill represents a single node of a skill tree."""

	def __init__(self, xmlNode = None):
		"""Create a Skill object.

		External code should always supply the xmlNode argument, passing `None` is for internal use only."""

		#Create an empty dummy skill if no XML data is passed in.
		#This is used by the mergeSkills() factory function to create the object for its return value.
		if not xmlNode: return

		def addAttribute(self: Skill, variable: str, value) -> None:
			if hasattr(self, variable):
				raise SkillTreeFormatError
			setattr(self, variable, value)

		for child in xmlNode.getchildren():
			if child.tag == "Authors":
				addAttribute(self, "authors", [normalizeString(author.text) for author in child.getchildren()])
			elif child.tag == "Definition":
				for definitionElement in child.getchildren():
					if definitionElement.tag == "Description":
						addAttribute(self, "description", Skill._readXmlItemList(definitionElement))
					elif definitionElement.tag == "ShortBackground":
						addAttribute(self, "background", Skill._readXmlItemList(definitionElement))
			elif child.tag == "RelevantForDomains":
				addAttribute(self, "domains", [(domain.attrib["Name"], domain.attrib["EstimatedBenefit"]) for domain in child.getchildren()])
			elif child.tag == "RelevantForRoles":
				addAttribute(self, "roles", [(role.attrib["Name"], role.attrib["EstimatedBenefit"]) for role in child.getchildren()])
			elif child.tag == "MainParentSkillRef":
				addAttribute(self, "parent", (child.attrib["Name"], child.attrib["Level"]))
			elif child.tag == "SubSkillRefs":
				addAttribute(self, "children", [(ref.attrib["Name"], ref.attrib["Level"]) for ref in child.getchildren()])

		self.name = xmlNode.attrib["Name"]
		self.id = xmlNode.attrib["Id"]
		self.level = xmlNode.attrib["Level"]
		self.category = xmlNode.attrib["Category"]

	def print(self) -> None:
		print(self.name, "(", self.id, "), Level =", self.level, ", Category =", self.category)
		if hasattr(self, "authors"): print("\tauthors =", self.authors)
		if hasattr(self, "description"): print("\tdescription =", self.description)
		if hasattr(self, "background"): print("\tbackground =", self.background)
		if hasattr(self, "content"): print("\tbackground =", self.content)
		if hasattr(self, "domains"): print("\tdomains =", self.domains)
		if hasattr(self, "roles"): print("\troles =", self.roles)
		if hasattr(self, "parent"): print("\tparent =", self.parent)
		if hasattr(self, "children"): print("\tchildren =", self.children)

	def key(self) -> tuple:
		return (self.name, self.level)

	def getCoreData(self) -> dict:
		"""Generate a JSON code-able description of the skill.

		The returned description contains the required core information about the skill, only.
		All other information, like descriptions, sub-skill references, and relevance classification are left out."""

		result = {
			"name": self.name,
			"id": self.id,
			"level": self.level,
			"category": self.category
		}
		return result

	def reducedId(self) -> str:
		"""Produces a skill ID that is independent of the skill's level.

		Technically, this strips the skill ID of any suffix that starts with a '-' letter."""
		return re.sub('-.*$', '', self.id)

	def mergeSkills(*skills):
		name = None
		parent = None
		for skill in skills:
			if not name:
				name = skill.name
				skillId = skill.reducedId()
				category = skill.category
			if name != skill.name: raise SkillMismatchError(skill, skills[0])
			if skillId != skill.reducedId(): raise SkillMismatchError(skill, skills[0])
			if category != skill.category: raise SkillMismatchError(skill, skills[0])
			if hasattr(skill, "parent"):
				curParent = skill.parent[0] if skill.parent[0] != name else None
				if not parent:
					parent = curParent
				elif curParent and parent != curParent:
					raise SkillMismatchError(skill, skills[0])
		if not name: return None	#no input, no output

		result = Skill()
		result.name = name
		result.id = skillId
		result.level = "Merged"
		result.category = category

		def colorizedDiff(stringA: str, stringB: str) -> str:
			matcher = difflib.SequenceMatcher(None, stringA, stringB)
			lastPositionA, lastPositionB = 0, 0
			result = ""
			for positionA, positionB, count in matcher.get_matching_blocks():
				changeA = positionA != lastPositionA
				changeB = positionB != lastPositionB
				if changeA or changeB:
					result = result + termColors.kBB + "{"
					if changeA: result = result + termColors.kBR + stringA[lastPositionA:positionA]
					if changeA and changeB: result = result + termColors.kBB + "|"
					if changeB: result = result + termColors.kBG + stringB[lastPositionB:positionB]
					result = result + termColors.kBB + "}" + termColors.kNormal
				result = result + stringA[positionA:positionA + count]
				lastPositionA = positionA + count
				lastPositionB = positionB + count
			return result

		def warnOnCloseMatch(string: str, stringList: list) -> None:
			"""Output a warning if the string is very similar to an element of the stringList."""

			kSimilarityThreshold = 0.9

			matcher = difflib.SequenceMatcher(None, string)
			for secondString in stringList:
				matcher.set_seq2(secondString)
				if matcher.real_quick_ratio() > kSimilarityThreshold and matcher.quick_ratio() > kSimilarityThreshold and matcher.ratio() > kSimilarityThreshold:
					print()
					print(termColors.kBold + "warning: very similar strings encountered:" + termColors.kNormal)
					print('"' + colorizedDiff(string, secondString) + '"')
					print("Are these two strings meant to be the same? Typo? Copy-Paste error?")

		def mergeStringLists(firstList: list, secondList: list) -> list:
			"""Append all elements of the second list to the first list, unless they already exist there.

			Checks whether near matches exist in the first list, and prints warnings accordingly.
			Handles all cases in which one or two parameters are None:
			If provided, firstList is modified and returned;
			if not provided and secondList is given, a copy of secondList is returned."""

			if not secondList: return firstList	#nothing to add
			if not firstList: return [i for i in secondList]	#return copy of secondList

			for curString in secondList:
				if not curString in firstList:
					warnOnCloseMatch(curString, firstList)
					firstList.append(curString)
			return firstList

		authors = None
		description = None
		background = None
		content = None
		domains = benefitDict.BenefitDict()
		roles = benefitDict.BenefitDict()
		children = None
		for skill in skills:
			if hasattr(skill, "authors"): authors = mergeStringLists(authors, skill.authors)
			if hasattr(skill, "description"): description = mergeStringLists(description, skill.description)
			if hasattr(skill, "background"): background = mergeStringLists(background, skill.background)
			if hasattr(skill, "content"): content = mergeStringLists(content, skill.content)
			if hasattr(skill, "domains"): domains.addBenefitList(skill.domains)
			if hasattr(skill, "roles"): roles.addBenefitList(skill.roles)
			if hasattr(skill, "children"): children = mergeStringLists(children, [child[0] for child in skill.children])

		#remove any recursive references from the list of children
		realChildren = []
		if children:
			for child in children:
				if child != name: realChildren.append(child)

		if authors: result.authors = authors
		if description: result.description = description
		if background: result.background = background
		if content: result.content = content
		if domains: result.domains = domains.benefitDictToList()
		if roles: result.roles = roles.benefitDictToList()
		if parent: result.parent = (parent, "Merged")
		if realChildren: result.children = [(child, "Merged") for child in realChildren]

		return result

	def addContentLink(self, displayName: str, url: str) -> None:
		"""Add an item to the "content" attribute of the skill.

		The link will be of the form '<a href="url">displayName</a>'."""

		link = '<a href="' + url + '">' + displayName + '</a>'
		if not hasattr(self, "content"): self.content = []
		self.content.append(link)

	def __hash__(self):
		return self.key().__hash__()

	def __eq__(self, other):
		return self.key().__eq__(other)

	def _readXmlItemList(definitionElement) -> list:
		return [normalizeString(item.text) for item in definitionElement.getchildren()]
