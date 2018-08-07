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

#define the possible estimated benefit strings and their relative values
kBenefitValues = {
	"Low": 0.0,
	"Medium": 0.5,
	"High": 1.0,
}

#build a reverse LUT for kBenefitValues
kBenefitStrings = {}
for key in kBenefitValues.keys():
	kBenefitStrings[kBenefitValues[key]] = key

def benefitToNumber(estimatedBenefit: str) -> float:
	if not estimatedBenefit in kBenefitValues:
		print('Fatal error: Unknown estimated benefit value of "' + estimatedBenefit + '" encountered.')
		print('Either use one of "' + '", "'.join(list(kBenefitValues.keys())) + '",')
		print('or add a line `"' + estimatedBenefit + '": <some-float-value>,` to the definition of the kBenefitValues constant.')
		sys.exit(1)
	return kBenefitValues[estimatedBenefit]

def benefitToString(estimatedBenefit: float) -> str:
	if not estimatedBenefit in kBenefitStrings:
		print('Fatal internal error: Cannot find an estimated benefit label for the value' + float)
		print('This really should not happen, it indicates that this value has not been obtained by translating an estimated benefit label to a numeric value.')
		print('You are in for some debugging...')
		sys.exit(1)
	return kBenefitStrings[estimatedBenefit]

class BenefitDict:
	"""This class is used to merge the relevance relations that are defined for skills at different skill levels.

	The approach is to first convert the different benefit levels into numerical values,
	and then to use the maximum benefit value encountered for a given role/domain/whatever as the benefit of the merged skill."""

	def __init__(self):
		self.benefits = {}
		self.isEmpty = True

	def __bool__(self):
		return not self.isEmpty

	def addBenefit(self, benefit: tuple) -> None:
		"""Add the given benefit to a benefit dictionary.

		benefit has the form `(target, estimatedBenefit)`, where both `target` and `estimatedBenefit` are strings.
		The former says what the skill is relevant for, the later is expected to contain one of the strings defined in `kBenefitValues`.
		If the provided benefit is already defined in the dictionary, the higher benefit value is used."""

		target = benefit[0]
		value = benefitToNumber(benefit[1])
		if not target in self.benefits or self.benefits[target] < value:
			self.benefits[target] = value
			self.isEmpty = False

	def addBenefitList(self, benefits: list) -> dict:
		"""Wrapper for addBenefit() that processes all benefit tuples in a given list."""

		if not benefits: return
		for benefit in benefits: self.addBenefit(benefit)

	def benefitDictToList(self) -> list:
		"""Convert a benefit dictionary to a list of (<name>, <benefit-label>) tuples."""

		return [(key, benefitToString(self.benefits[key])) for key in self.benefits.keys()]
