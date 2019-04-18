/*
Copyright (c) 2018 Nathanael Hübbe

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

function Skill(skillId) {
	this.id = skillId;
	this.lists = {};
	this.relevances = {};
	this.isDummy = true;
};

Skill.prototype = {
	constructor: Skill(),

	//When a skill is created, it contains nothing more than an ID.
	//This method supplies the core data that every skill should have.
	//May only be called once per skill.
	//
	//Returns a string with an error message in case of an error, otherwise a falsy value is returned.
	setCoreData: function(name, level, category) {
		if(!this.isDummy) return "attempt to redefine core data of skill '" + this.name + "' (" + this.id + ")";
		if(typeof name != "string") return "name of skill '" + this.id + "' is not a string value";
		if(typeof level != "string") return "level of skill '" + this.id + "' is not a string value";
		if(typeof category != "string") return "category of skill '" + this.id + "' is not a string value";

		this.name = name;
		this.level = level;
		this.category = category;
		this.isDummy = false;

		return "";
	},

	//Define a list attribute if not already defined, and add the data item(s) to it.
	//data may either be a string or an array of strings.
	//
	//Cannot fail.
	addToListAttribute: function(name, data) {
		if(!this.lists[name]) this.lists[name] = [];
		if(Array.isArray(data)) {
			this.lists[name] = this.lists[name].concat(data);
		} else {
			this.lists[name].push(data);
		}
	},

	//Define the relevance of a skill for a given role/domain/whatever.
	//All arguments must be strings, relevanceLevel should be either "Low", "Medium", or "High".
	//
	//Returns a string with an error message in case of an error, otherwise a falsy value is returned.
	addRelevance: function(relevanceClass, relevanceObject, relevanceLevel) {
		if(typeof relevanceClass != "string") return "relevance class is not a string";
		if(typeof relevanceObject != "string") return "relevance object is not a string";
		if(typeof relevanceLevel != "string") return "relevance level is not a string";

		if(!this.relevances[relevanceClass]) this.relevances[relevanceClass] = {};
		if(this.relevances[relevanceClass][relevanceObject]) {
			if(this.relevances[relevanceClass][relevanceObject] != relevanceLevel) {
				return "conflicting relevance definitions for '" + relevanceClass + "'/'" + relevanceObject + "' for skill '" + this.id + "'";
			} else {
				return "";	//redefinition with same value is not fatal
			}
		}
		this.relevances[relevanceClass][relevanceObject] = relevanceLevel;

		return "";
	},

	//Get the name that should be used for display.
	//
	//Returns a string with the name or a falsy value in case of an error.
	getName: function() {
		if(this.isDummy) return "";
		return this.id + ": " + this.name;
	},

	//Produce an HTML string which contains the contents of the given attribute for this skill.
	//Returns an empty string if the given attribute has not been set for this kill.
	listAttributeHtmlDescription: function(definitionMember, displayTitle) {
		if(this.lists[definitionMember]) {
			var result = '<p class="Heading">' + displayTitle + ':</p>\n<ul class="Text">\n';
			for(var i in this.lists[definitionMember]) {
				result += '\t<li>' + this.lists[definitionMember][i] + '</li>\n';
			}
			result += "</ul>\n";
		}
		return result;
	},

	//Produce an HTML string which describes a relevance relation for this skill.
	//Returns an empty string if the skill is not defined to be relevant for anything in the given relevanceClass.
	relevanceAttributeHtmlDescription: function(relevanceClass, displayTitle) {
		if(!this.relevances[relevanceClass]) return "";
		var result = '<p class="Heading">Relevant for ' + displayTitle + ':</p>\n<p class="Text">'
		var firstItem = true;
		for(var key in this.relevances[relevanceClass]) {
			if(!firstItem) {
				result += ", ";
			} else {
				firstItem = false;
			}
			result += key + " (" + this.relevances[relevanceClass][key] + ")";
		}
		return firstItem ? "" : result;
	},

	//Produce an array of strings of the format "<relevanceClass>_<relevanceObject>_<importance>", one for each relevance that the skill has.
	listRelevances: function() {
		var result = [];
		for(var relevanceClass in this.relevances) {
			for(var relevanceObject in this.relevances[relevanceClass]) {
				result.push(relevanceClass + "_" + relevanceObject + "_" + this.relevances[relevanceClass][relevanceObject]);
			}
		}
		return result;
	},

	//Produce a details description of the skill in HTML format.
	skillHtmlDescription: function() {
		var sections = [];

		//Definition
		pushIfTruthy(sections, this.listAttributeHtmlDescription("background", "Background"));
		pushIfTruthy(sections, this.listAttributeHtmlDescription("description", "Description"));
		pushIfTruthy(sections, this.relevanceAttributeHtmlDescription("Domain", "Domains"));
		pushIfTruthy(sections, this.relevanceAttributeHtmlDescription("Role", "Roles"));
		pushIfTruthy(sections, this.listAttributeHtmlDescription("content", "Content"));

		//Put the sections together, inserting dividers as needed
		var result = "";
		for(var i in sections) {
			if(i != 0) {
				result += '<hr class="Divider">\n';
			}
			result += sections[i];
		}
		return result;
	},
};
