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

function SkillList() {
	this.list = {};
	this.tree = null;
	this.initialTreantDepth = 2;
};

SkillList.prototype = {
	constructor: SkillList(),

	//Load the data in the provided JSON files.
	//
	//urls is an array of strings that contain the URLs of the files that are to be loaded.
	//Returns immediately, the error status is passed as a string to the provided callback (`callback(errorMessage)`).
	loadFiles: function(callback, urls) {
		(function(me) {	//capture `this` in closure
			var outstandingRequests = urls.length;
			var errors = "";

			var registerResult = function(error) {
				if(error) errors += error + "\n";
				outstandingRequests--;
				if(outstandingRequests == 0) callback(errors);
			};

			for(var i in urls) {
				(function(curUrl) {
					$.ajax({
						url: curUrl,
						dataType: "json",
						mimeType: "application/json",
						success: function(data) { registerResult(me.ingestData(data)); },
						error: function(jqXHR, textStatus, error) {
							registerResult("error while loading file from '" + curUrl + "':\nstatus = " + textStatus + "\nerror = " + error + "\n");
						}
					});
				})(urls[i]);
			}
		})(this);
	},

	//Produce a hierarchical object structure that is suitable as a Treant node tree.
	//Call without any arguments, they are for internal use only.
	//
	//On success, this returns a Treant node tree,
	//on error, a string with an error message is returned instead.
	makeTreantNodeStructure: function(skillId, tree, level) {
		if(!tree) {
			if(!this.tree) return "tree structure of skills has not been defined yet";
			skillId = this.tree.keys().next().value;
			tree = this.tree.get(skillId);
			level = 0;
		}

		var skill = this.produceSkill(skillId);
		var skillName = skill.getName();
		if(!skillName) return "no data for skill ID '" + skillId + "' found";
		var skillClasses = skill.listRelevances();
		var classes = skillClasses.join(" ");

		//variables for passing data into/out-of the forEach loop
		var children = [];
		var result = null;
		var me = this;
		tree.forEach(
			function(child, childId) {
				if(typeof result != "string") result = me.makeTreantNodeStructure(childId, child, level + 1);
				if(typeof result != "string") children.push(result);
			}
		);

		if(typeof result == "string") return result;
		return {
			text: {
				name: skill.getName(),
			},
			meta: skill,
			children: children,
			collapsed: level >= this.initialTreantDepth,
			HTMLclass: classes,
		};
	},

	//Produce a skill object for a given skill ID, either by returning an existing skill object, or by creating a new one
	//(which will be returned by any subsequent calls with the same argument).
	//
	//Cannot fail.
	produceSkill: function(skillId) {
		if(!this.list[skillId]) this.list[skillId] = new Skill(skillId);
		return this.list[skillId];
	},

	//Ingest some skill description object.
	//The object may be either a single object with a member called 'define' and other members matching the data format identified by the value of 'define',
	//or an array of such objects.
	//In the later case, ingestData() will call itself recursively on the elements of the array, aborting immediately upon encountering an error.
	//Thus, recursive arrays would be handled recursively,
	//but the intended use case is a single flat array of skill description objects which are transported in a single JSON file.
	//
	//Returns a string with an error message in case of an error, otherwise a falsy value is returned.
	ingestData: function(data) {
		if(Array.isArray(data)) {
			for(var item in data) {
				var error = this.ingestData(data[item]);
				if(error) return error;
			}
			return "";
		}
		if(!data.define) return "missing 'define' attribute";
		switch(data.define) {
			case "list items":
				return this.ingestListItems(data);
			case "core data":
				return this.ingestCoreData(data);
			case "relevance":
				return this.ingestRelevance(data);
			case "tree":
				return this.ingestTree(data);
		}
		return "unknown 'define' attribute: '" + data.define + "'";
	},

	//Helper for ingestData() that handles `"define": "list items"` objects.
	//The recognized data format is as follows:
	//{
	//    "define": "list items",
	//    "skill": <skill-id>,
	//    "attribute": <list-attribute-name>,
	//    "value": [
	//        <item-strings>
	//    ]
	//}
	//The value of the "value" key may also be a single <item-string>.
	//
	//Returns an error message string or a falsy value.
	ingestListItems: function(data) {
		if(!data.skill) return "'list items' skill descriptor is missing 'skill' attribute";
		if(!data.attribute) return "'list items' skill descriptor is missing 'attribute' attribute";
		if(!data.value) return "'list items' skill descriptor is missing 'value' attribute";

		skill = this.produceSkill(data.skill).addToListAttribute(data.attribute, data.value);
		return "";
	},

	//Helper for ingestData() that handles `"define": "core data"` objects.
	//The recognized data format is as follows:
	//{
	//    "define": "core data",
	//    "id": <skill-id>,
	//    "name": <skill-name>,
	//    "level": <skill-level>,
	//    "category": <skill-category>
	//}
	//
	//Returns an error message string or a falsy value.
	ingestCoreData: function(data) {
		if(!data.id) return "'core data' skill descriptor is missing 'id' attribute";
		if(!data.name) return "'core data' skill descriptor is missing 'name' attribute";
		if(!data.level) return "'core data' skill descriptor is missing 'level' attribute";
		if(!data.category) return "'core data' skill descriptor is missing 'category' attribute";

		skill = this.produceSkill(data.id);
		return skill.setCoreData(data.name, data.level, data.category);
	},

	//Helper for ingestData() that handles `"define": "relevance"` objects.
	//The recognized data format is as follows:
	//{
	//    "define": "relevance",
	//    "type": <class-of-what-the-skills-are-relevant-for>,
	//    "name": <what-the-skills-are-relevant-for>,
	//    "skills": {
	//        <skill-id>: <relevance-level>,
	//        ...
	//    }
	//}
	//
	//Returns an error message string or a falsy value.
	ingestRelevance: function(data) {
		if(!data.type) return "'relevance' skill descriptor is missing 'type' attribute";
		if(!data.name) return "'relevance' skill descriptor is missing 'name' attribute";
		if(!data.skills) return "'relevance' skill descriptor is missing 'skills' attribute";

		for(var i in data.skills) {
			skill = this.produceSkill(i);
			relevanceLevel = data.skills[i];
			error = skill.addRelevance(data.type, data.name, relevanceLevel);
			if(error) return error;
		}
		return "";
	},

	//Helper for ingestData() that handles `"define": "tree"` objects.
	//The recognized data format is as follows:
	//{
	//    "define": "tree",
	//    "tree": {
	//        <root-id>: {
	//            <subtree-id>: {
	//                ...
	//            },
	//            ...
	//        }
	//    }
	//}
	//
	//Returns an error message string or a falsy value.
	ingestTree: function(data) {
		if(!data.tree) return "'tree' skill descriptor is missing 'tree' attribute";
		if(this.tree) return "redefinition of skill tree structure";
		this.tree = this.sortTree(data.tree);	//TODO: check the object structure of the tree
		return "";
	},

	//Helper for ingestTree() that turns a tree of unordered objects into a tree of ordered maps.
	//
	//Returns a map with the same parent-child relationships as the given object tree,
	//where all children of any node are sorted by their keys.
	sortTree: function(tree) {
		var children = [];
		for(var key in tree) {
			children.push([key, this.sortTree(tree[key])]);
		}
		children.sort(
			function(a, b) {
				return a[0].localeCompare(b[0]);
			}
		);
		return new Map(children);
	},
};
