Parts and Purpose
=================

This repository contains several distinct parts:

  * The Skill Tree in XML format.
  * Tools to convert the Skill Tree into other formats.
  * A visualizer for the Skill Tree.

The Skill Tree itself provides a categorization of the different skills that are relevant to HPC users.
This is the core of this publication, and we hope to get feedback, bug reports, and feature requests on this.

The conversion tools are provided to ease understanding of the Skill Tree.
Also, one of these conversion tools is essential to produce the input data for the visualizer.

The visualizer is a JavaScript program that is aimed at being embedded in any websites
that wish to provide a graphical, interactive view of the Skill Tree.
As such, the visualizer is heavily customizable; how is described below.
While the visualizer is aimed at being deployed on the web, it can also be used locally to browse the Skill Tree.



Licenses
========

The different parts of this repository are released under different licenses.
Please check the license notices in the source files for details.



Building
========

Generating the derived files from the Skill Tree,
as well as a deployable version of the Skill Tree visualizer,
can be done by executing:

    $ make

This will create a directory "build" which contains the JSON files describing the Skill Tree,
as well as a subdirectory that contains everything necessary to deploy the Skill Tree viewer.

This will also generate a configuration file at "visualization/deployedBaseUrl"
which contains the base URL used for the links in the deployable version of the Skill Tree viewer.
So, if you want to actually deploy the viewer, you need to do:

    $ vim visualization/deployedBaseUrl
    $ make

Nevertheless, there are some dependencies to this process:

  * closure-compiler
  * java
  * pandoc
  * python 3

(Please report a bug if the list above should prove incomplete.)



Configuring for deployment
==========================

When the Skill Tree viewer is built, it needs to place URLs to its resources into the "index.html" file.
This URL is provided by the file "visualization/deployedBaseUrl" at build time.
On its first invocation, `make` will generate this file with a dummy URL,
and you should change it to provide the prefix under which you want to deploy the Skill Tree viewer.

Apart from this, the viewer is quite flexible in the data that it parses.

  * At the top-level, you define a list of views.
    A view consists of just a name and an array of URLs.

  * The URLs point to JSON files containing the Skill Tree data.
    The format of these JSON files is self-describing in such a way that order, content, and file decomposition are entirely up to you.

  * Usually, the different JSON files contain different aspects of the Skill Tree data,
    at least that is the case for the JSON files that are built by default.
    This allows an administrator to configure out the background information of the skills, for instance,
    by just removing the URL to the file with the background data from the view.
    This is exactly what has been done for the reduced view in the default build.



Data Format
-----------

The data format that is used to configure the Skill Tree viewer is defined in source code and comments in "visualization/skillList.js".
The following replicates this information.
Please be aware that any documentation might get out of date, so the reference information source is the source code.

All JSON files contain an array of objects, all of which must provide the attribute `"define"`.
The value of the `"define"` attribute defines the meaning and data type of the object.
Currently, legal values for the `"define"` attribute are:

  * `"tree"`
  * `"core data"`
  * `"list items"`
  * `"relevance"`


### Tree data

An object with `"define": "tree"` defines the tree structure of the skills.

Apart from the `"define"` attribute, these objects contain exactly one more attribute `"tree"`:

  * `"tree"` (dictionary: string -> dictionary): The keys are skill IDs,
    and the values are dictionaries that recursively list the respective skill's children in the same format.

    The top-level dictionary (the value of the `"tree"` attribute) should contain only a single entry which has the root skill's ID as its key.
    The dictionaries below this level can have an arbitrary number of entries, according to the number of children to their respective skills.

The recognized data format is as follows:

    {
        "define": "tree",
        "tree": {
            <root-id>: {
                <subtree-id>: {
                    ...
                },
                ...
            }
        }
    }

There should be exactly one tree data object in the configuration.


### Core data

An object with `"define": "core data"` sets the basic information associated with a skill.

Apart from the `"define"` attribute, these objects contain the following four attributes:

  * `"id"` (string): The skill ID of the skill.

  * `"name"` (string): The name that should be displayed for this skill.

  * `"level"` (string): The level for which this skill is defined.

  * `"category"` (string): Classification of the skill into a broad category.

The recognized data format is as follows:

    {
        "define": "core data",
        "id": <skill-id>,
        "name": <skill-name>,
        "level": <skill-level>,
        "category": <skill-category>
    }

There should be exactly one `"core data"` object for each skill.


### List items

An object with `"define": "list items"` adds bullet point list information to a skill.

Apart from the `"define"` attribute, these objects contain the following three attributes:

  * `"skill"` (string): The skill ID of the skill to which the data is to be added.

  * `"attribute"` (string): The title of the section in the hover-box under which the list items should be displayed.

  * `"value"` (array of strings): The list of bullet points to add to this skill.
    If `"value"` is not an array, it must be a string.
    In this case, only a single bullet point is added.

The recognized data format is as follows:

    {
        "define": "list items",
        "skill": <skill-id>,
        "attribute": <list-attribute-name>,
        "value": [
            <item-strings>
        ]
    }

Or:

    {
        "define": "list items",
        "skill": <skill-id>,
        "attribute": <list-attribute-name>,
        "value": <item-string>
    }


### Relevance relations

An object with `"define": "relevance"` defines a relevance relation.

A relevance relation names something that skills may be relevant for (like the role tester),
with its name ("tester") and a classification of that name ("role").
Other imaginable examples would be the domain of climate science (type = "domain", name = "climate science"),
or the pursuit of happiness (type = "pursuit", name = "happiness").
Each skill is assigned a relevance level (usually "Low", "Medium", or "High").

Thus, apart from the `"define"` attribute, these objects contain the following three attributes:

  * `"type"` (string): Class of the thing that the skills may be relevant for.

  * `"name"` (string): Name of the thing that the skills may be relevant for.

  * `"skills"` (dictionary: string -> string): Dictionary that maps the skill IDs of the skills to their respective relevance to the <type> of <name>.

The recognized data format is as follows:

    {
        "define": "relevance",
        "type": <class-of-what-the-skills-are-relevant-for>,
        "name": <what-the-skills-are-relevant-for>,
        "skills": {
            <skill-id>: <relevance-level>,
            ...
        }
    }

There should be exactly one `"relevance"` object for each relevance relation.
