<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
<xsl:strip-space elements="*"/>

<xsl:template match="/">

<!-- kh 23.01.18 place prologue here -->
<SkillsFullyExpanded xsi:noNamespaceSchemaLocation="SkillsFullyExpanded.xsd" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<!-- kh 07.02.18 select the root node in the (flat) list of skills with cross-references -->
<xsl:variable name="RootNode" select=".//Skill[@Name = 'Root']"/>

<xsl:apply-templates select="$RootNode">

<!-- kh 07.02.18 insert the root node as first node in the actual skill path -->
  <xsl:with-param name="SkillPath"  select="$RootNode"/>

<!-- kh 07.02.18 SkillsFullyExpanded is at level 0 -->
  <xsl:with-param name="IndentationLevel" select="1"/>

</xsl:apply-templates>

<!-- kh 23.01.18 place epilogue here -->
</SkillsFullyExpanded>

</xsl:template> <!-- ... match="/"> -->

<xsl:template match="Skill">
  <xsl:param name="SkillPath"/>
  <xsl:param name="IndentationLevel" select="0"/>

  <xsl:copy>

  <xsl:attribute name="Name"> <xsl:value-of select="@Name"/> </xsl:attribute>
  <xsl:attribute name="Level"> <xsl:value-of select="@Level"/> </xsl:attribute>
  <xsl:attribute name="Id"> <xsl:value-of select="@Id"/> </xsl:attribute>
  <xsl:attribute name="Category"> <xsl:value-of select="@Category"/> </xsl:attribute>

<!-- kh 07.02.18 $SkillPath contains the actual node at the last position, 
i.e. another entry in the path indicates a cyclic depedency -->
  <xsl:variable name="IsCycle" select="count($SkillPath[@Name = current()/@Name][@Level = current()/@Level]) > 1"/>
<!--  <xsl:variable name="IsCycle" select="count($SkillPath[@Name = current()/@Name[@Level = current()/@Level]]) > 1"/> -->

  <xsl:if test="$IsCycle = true()">
    <CyclicDependency>
      <xsl:for-each select="$SkillPath">
        <xsl:value-of select="./@Name"/>.<xsl:value-of select="./@Level"/>
        <xsl:if test="position() lt last()"> - </xsl:if>
      </xsl:for-each>
    </CyclicDependency>
  </xsl:if> <!-- test="IsCycle = 'true'" -->

  <xsl:if test="$IsCycle = false()">

    <xsl:copy-of select="Authors" copy-namespaces="no"/>

<!--
    <xsl:copy-of select="Definition" copy-namespaces="no"/>
-->
    <xsl:apply-templates select="Definition">
      <xsl:with-param name="IndentationLevel" select="$IndentationLevel + 1"/>
    </xsl:apply-templates>

    <xsl:copy-of select="RelevantForDomains" copy-namespaces="no"/>
    <xsl:copy-of select="RelevantForRoles" copy-namespaces="no"/>
    <xsl:copy-of select="MainParentSkillRef" copy-namespaces="no"/>

    <xsl:apply-templates select=".//SkillRef">
      <xsl:with-param name="SkillPath" select="$SkillPath"/>
      <xsl:with-param name="IndentationLevel" select="$IndentationLevel"/>
    </xsl:apply-templates>
  </xsl:if> <!-- test="IsCycle = 'false'" -->
  </xsl:copy>
</xsl:template> <!-- ... match="Skill"> -->

<xsl:template match="SkillRef">
  <xsl:param name="SkillPath"/>
  <xsl:param name="IndentationLevel"/>

  <xsl:variable name="SkillDeref" select="//Skill[@Name = current()/@Name][@Level = current()/@Level]"/>
  <xsl:apply-templates select="$SkillDeref">

<!-- kh 07.02.18 append current skill node to the actual skill path -->
    <xsl:with-param name="SkillPath" select="$SkillPath, $SkillDeref"/>
    <xsl:with-param name="IndentationLevel" select="$IndentationLevel + 1"/>
  </xsl:apply-templates>
</xsl:template> <!-- ... match="SkillRef"> -->

<xsl:template name="check-cycle">
  <xsl:param name="SkillNodeInPath"/>
  <xsl:param name="SkillNodeToCheck"/>
</xsl:template> 

<xsl:template match="Definition">
  <xsl:param name="IndentationLevel" select="0"/>

  <xsl:copy>
    <xsl:apply-templates select="node()|@*">
      <xsl:with-param name="IndentationLevel" select="$IndentationLevel + 1"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<!-- kh 15.02.18 use an identity rule as default -->
<xsl:template match="node()|@*">
  <xsl:param name="IndentationLevel" select="0"/>

  <xsl:copy>
    <xsl:apply-templates select="node()|@*">
      <xsl:with-param name="IndentationLevel" select="$IndentationLevel + 1"/>
    </xsl:apply-templates>
  </xsl:copy>
</xsl:template>

<xsl:template match="ShortBackground/Item/text()">
  <xsl:param name="IndentationLevel" select="0"/>

  <xsl:call-template name="indentItem">
    <xsl:with-param name="Item" select="."/>
    <xsl:with-param name="IndentationLevel" select="$IndentationLevel"/>
  </xsl:call-template>
</xsl:template> <!-- ... match="ShortBackground/Item/text()"> -->

<xsl:template match="Description/Item/text()">
  <xsl:param name="IndentationLevel" select="0"/>

  <xsl:call-template name="indentItem">
    <xsl:with-param name="Item" select="."/>
    <xsl:with-param name="IndentationLevel" select="$IndentationLevel"/>
  </xsl:call-template>
</xsl:template> <!-- ... match="Description/Item/text()"> -->

<xsl:template name="indentItem">
  <xsl:param name="Item" select="''"/>
  <xsl:param name="IndentationLevel" select="0"/>

  <xsl:for-each select="tokenize($Item, '&#xA;')">
    <xsl:if test="not ((position() = last()) and (string-length(replace(., '^\s+|\s+$', '')) = 0))">
      <xsl:if test="position() > 1">
        <xsl:text>&#xA;</xsl:text>
      </xsl:if>

      <xsl:call-template name="makeIndentation">
        <xsl:with-param name="IndentationLevel" select="$IndentationLevel"/>
      </xsl:call-template>
      <xsl:value-of select="replace(., '^\s+|\s+$', '')"/>
    </xsl:if>
  </xsl:for-each>
</xsl:template> <!-- ... name="indentItem"> -->

<xsl:template name="makeIndentation">
  <xsl:param name="IndentationLevel" select="0"/>

  <xsl:if test="$IndentationLevel > 0">
    <xsl:text>  </xsl:text>
    <xsl:call-template name="makeIndentation">
      <xsl:with-param name="IndentationLevel" select="$IndentationLevel - 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template> <!-- ... name="makeIndentation"> -->
</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
  <scenarios>
    <scenario default="no" name="NonPersonalSpeechPrefix" userelativepaths="yes" externalpreview="no" url="skills-non-personal-speech-auto-generated.xml" htmlbaseurl="" outputurl="skills-fully-expanded-non-personal-speech-auto-generated.xml"
              processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath=""
              postprocessgeneratedext="" validateoutput="yes" validator="custom" customvalidator="Saxonica Validator XSD 1.1">
      <advancedProp name="bSchemaAware" value="true"/>
      <advancedProp name="xsltVersion" value="2.0"/>
      <advancedProp name="schemaCache" value="||"/>
      <advancedProp name="iWhitespace" value="0"/>
      <advancedProp name="bWarnings" value="true"/>
      <advancedProp name="bXml11" value="false"/>
      <advancedProp name="bUseDTD" value="false"/>
      <advancedProp name="bXsltOneIsOkay" value="true"/>
      <advancedProp name="bTinyTree" value="true"/>
      <advancedProp name="bGenerateByteCode" value="true"/>
      <advancedProp name="bExtensions" value="true"/>
      <advancedProp name="iValidation" value="0"/>
      <advancedProp name="iErrorHandling" value="fatal"/>
      <advancedProp name="sInitialTemplate" value=""/>
      <advancedProp name="sInitialMode" value=""/>
      <validatorSchema value="SkillsFullyExpanded.xsd"/>
    </scenario>
    <scenario default="no" name="PersonalSpeech" userelativepaths="yes" externalpreview="no" url="skills-personal-speech-auto-generated.xml" htmlbaseurl="" outputurl="skills-fully-expanded-personal-speech-auto-generated.xml" processortype="saxon8"
              useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath=""
              postprocessgeneratedext="" validateoutput="yes" validator="custom" customvalidator="Saxonica Validator XSD 1.1">
      <advancedProp name="bSchemaAware" value="true"/>
      <advancedProp name="xsltVersion" value="2.0"/>
      <advancedProp name="schemaCache" value="||"/>
      <advancedProp name="iWhitespace" value="0"/>
      <advancedProp name="bWarnings" value="true"/>
      <advancedProp name="bXml11" value="false"/>
      <advancedProp name="bUseDTD" value="false"/>
      <advancedProp name="bXsltOneIsOkay" value="true"/>
      <advancedProp name="bTinyTree" value="true"/>
      <advancedProp name="bGenerateByteCode" value="true"/>
      <advancedProp name="bExtensions" value="true"/>
      <advancedProp name="iValidation" value="0"/>
      <advancedProp name="iErrorHandling" value="fatal"/>
      <advancedProp name="sInitialTemplate" value=""/>
      <advancedProp name="sInitialMode" value=""/>
      <validatorSchema value="SkillsFullyExpanded.xsd"/>
    </scenario>
    <scenario default="yes" name="Test_180605a" userelativepaths="yes" externalpreview="no" url="SkillsBase_SE7.2-E_Test_todo_180531a.xml" htmlbaseurl="" outputurl="SkillsBaseFullyExpanded.xml" processortype="saxon8" useresolver="yes" profilemode="0"
              profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="yes"
              validator="custom" customvalidator="Saxonica Validator XSD 1.1">
      <advancedProp name="bSchemaAware" value="true"/>
      <advancedProp name="xsltVersion" value="2.0"/>
      <advancedProp name="schemaCache" value="||"/>
      <advancedProp name="iWhitespace" value="0"/>
      <advancedProp name="bWarnings" value="true"/>
      <advancedProp name="bXml11" value="false"/>
      <advancedProp name="bUseDTD" value="false"/>
      <advancedProp name="bXsltOneIsOkay" value="true"/>
      <advancedProp name="bTinyTree" value="true"/>
      <advancedProp name="bGenerateByteCode" value="true"/>
      <advancedProp name="bExtensions" value="true"/>
      <advancedProp name="iValidation" value="0"/>
      <advancedProp name="iErrorHandling" value="fatal"/>
      <advancedProp name="sInitialTemplate" value=""/>
      <advancedProp name="sInitialMode" value=""/>
      <validatorSchema value="SkillsFullyExpanded.xsd"/>
    </scenario>
  </scenarios>
  <MapperMetaTag>
    <MapperInfo srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
    <MapperBlockPosition></MapperBlockPosition>
    <TemplateContext></TemplateContext>
    <MapperFilter side="source"></MapperFilter>
  </MapperMetaTag>
</metaInformation>
-->