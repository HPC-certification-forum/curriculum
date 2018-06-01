<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
<xsl:strip-space elements="*"/>

<xsl:param name="PersonalSpeech" select="'false'"/>

<!-- kh 15.02.18 use an identity rule as a basis to complete the Description Items for personal speech -->
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

<!-- kh 19.02.18 remove whitespace at the end of the text node -->
  <xsl:value-of select="replace(., '\s+$', '')"/>
</xsl:template> <!--  ... match="ShortBackground/Item/text()"> -->

<xsl:template match="Description/Item/text()">
  <xsl:param name="IndentationLevel" select="0"/>

<!-- kh 16.02.18 use speech prefix only for the first text node of an item node to support/preserve comments between text nodes -->
  <xsl:if test="count(../text()[1]|.) eq 1">
    <xsl:variable name="Prefix">
      <xsl:choose>
        <xsl:when test="(../@Type = 'Knowledge') and ($PersonalSpeech = 'false')">Knowledge of</xsl:when>
        <xsl:when test="(../@Type = 'Ability')   and ($PersonalSpeech = 'false')">Ability to</xsl:when>
        <xsl:when test="(../@Type = 'Knowledge') and ($PersonalSpeech = 'true')">You will learn about</xsl:when>
        <xsl:when test="(../@Type = 'Ability')   and ($PersonalSpeech = 'true')">You will learn to</xsl:when>
        <xsl:otherwise>*** undefined Description/Item/@Type ***</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="makeSpeechPrefix">
      <xsl:with-param name="IndentationLevel" select="$IndentationLevel"/>
      <xsl:with-param name="Prefix" select="$Prefix"/>
    </xsl:call-template>

  </xsl:if>

<!-- kh 13.02.18 remove whitespace at the end of the text node -->
  <xsl:value-of select="replace(., '\s+$', '')"/>
</xsl:template> <!-- ... match="Description/Item/text()"> -->

<xsl:template name="makeSpeechPrefix">
  <xsl:param name="IndentationLevel" select="0"/>
  <xsl:param name="Prefix" select="''"/>

  <xsl:text>&#xA;</xsl:text>
  <xsl:call-template name="makeIndentation">
    <xsl:with-param name="IndentationLevel" select="$IndentationLevel"/>
  </xsl:call-template>
  <xsl:value-of select="$Prefix"/>
</xsl:template>

<xsl:template name="makeIndentation">
  <xsl:param name="IndentationLevel" select="0"/>

  <xsl:if test="$IndentationLevel > 0">
    <xsl:text disable-output-escaping="yes">  </xsl:text>
    <xsl:call-template name="makeIndentation">
      <xsl:with-param name="IndentationLevel" select="$IndentationLevel - 1"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>
</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
  <scenarios>
    <scenario default="no" name="NonPersonalSpeechPrefix" userelativepaths="yes" externalpreview="no" url="SkillsBase.xml" htmlbaseurl="" outputurl="skills-non-personal-speech-auto-generated.xml" processortype="saxon8" useresolver="yes" profilemode="0"
              profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="yes"
              validator="custom" customvalidator="Saxonica Validator XSD 1.1">
      <parameterValue name="PersonalSpeech" value="'false'"/>
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
      <validatorSchema value="Skills.xsd"/>
    </scenario>
    <scenario default="yes" name="PersonalSpeechPrefix" userelativepaths="yes" externalpreview="no" url="SkillsBase.xml" htmlbaseurl="" outputurl="skills-personal-speech-auto-generated.xml" processortype="saxon8" useresolver="yes" profilemode="0"
              profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="yes"
              validator="custom" customvalidator="Saxonica Validator XSD 1.1">
      <parameterValue name="PersonalSpeech" value="'true'"/>
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
      <validatorSchema value="Skills.xsd"/>
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