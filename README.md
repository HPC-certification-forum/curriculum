# HPC Certification Forum

Establishing an HPC Certification Program is a central part of the joint
Performance Conscious HPC (PeCoH) project that started in April 2017.

The three Hamburg compute centers involved in PeCoH, German Climate Computing
Center (DKRZ), Regional Computing Center at the Universit¨at Hamburg (RRZ),
and Computer Center at the Technische Universität Hamburg (TUHH RZ) started the
Hamburg HPC Competence Center ([HHCC](https://www.hhcc.uni-hamburg.de/)) as a
virtual institution and central contact point for their users.

More information on the project is available in the
[download area](https://www.hhcc.uni-hamburg.de/en/support/downloads.html)
on the HHCC website.

Our concept paper for the HPC Certification Program (Draft 0.91 -- June
2018) ([hpccp-paper.pdf](./hpccp-paper.pdf)) is also contained in this repository.

During the first year, it became apparent to broaden the scope and form
an independent governance entity to sustain the effort and gain acceptance.

For this purpose we establish a further website which focuses on the International
Certification Program:
[https://www.hpc-certification.org/](https://www.hpc-certification.org/)

# Technical Notes

The implementation of the skill tree is based on the Extensible Markup Language
[(XML)](https://www.w3.org/XML/) and corresponding XML Schema Definitions
[(XSD)](https://www.w3.org/2001/XMLSchema).

[SkillsBase.xml](./modeling/skill-tree/SkillsBase.xml) contains the list of
all skills we have identified for the HPC Certification Program so far.

First of all, [SkillsBase.xml](./modeling/skill-tree/SkillsBase.xml) contains all
the nodes of the skill tree in a flat data structure.
In order to describe the tree, each skill that depends on other
sub-skills has – besides its unique name, description, and further attributes – a
list of references to these sub-skills. This is similar to using a `Makefile` for
the well-known `make` build automation tool to define the dependencies of
compilation units (Stuart I. Feldmann
[Make -- A Program for Maintaining Computer
Programs](http://citeseerx.ist.psu.edu/viewdoc/summary?doi=10.1.1.39.7058).
Software Practice & Experience. Vol. 9 (1979):255-265).
Three levels of education (basic, intermediate, and expert) are used to further
subdivide each skill.

XSLT programs are used to transform the data in
[SkillsBase.xml](./modeling/skill-tree/SkillsBase.xml) to other formats and
 represenations.

We welcome your comments on the analysis and classification of HPC competences and
their value for scientists or any other input for the HPC Certification Program.

# After Downloading

Use `make` with the Makefile located in [./modeling/](./modeling/Makefile)
to build by the help of
[SkillsBase2SkillsWithSpeechPrefix.xsl](./modeling/skill-tree/SkillsBase2SkillsWithSpeechPrefix.xsl)
two copies of the SkillsBase.xml file with a) personal and b) non-personal speech
prefixes inserted to the description items of each skill and to build by the help of
[SkillTree2MindMap.xsl](./modeling/skill-tree/SkillTree2MindMap.xsl)
two corresponding mindmap files that can be viewed with the
[Freeplane](https://www.freeplane.org/wiki/index.php/Home) mindmap tool.
