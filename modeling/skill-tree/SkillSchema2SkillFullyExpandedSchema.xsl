<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsd="http://www.w3.org/2001/XMLSchema" >

<xsl:output method="xml" indent="yes" encoding="UTF-8"/>
<xsl:strip-space elements="*"/>

<!-- kh 09.05.18 use an identity rule as a basis to auto generate the schema for the fully expanded skill structure -->
<xsl:template match="node()|@*">
  <xsl:copy>
    <xsl:apply-templates select="node()|@*"/>
  </xsl:copy>
</xsl:template>

<!-- kh 09.05.18 see original schema (i.e. Skill.xsd) for comments -->
<xsl:template match="xsd:schema//comment()">
</xsl:template> <!--  ... match="xsd:schema//comment()"> -->

<xsl:template match="xsd:assert">
</xsl:template> <!--  ... match="assert"> -->

<xsl:template match="xsd:element[@name='Skill']/xsd:complexType/xsd:sequence">
    <xsd:choice>
      <xsd:element name="CyclicDependency"/>
      <xsd:sequence>

        <xsl:apply-templates select="node()|@*"/>

      </xsd:sequence>
    </xsd:choice>
</xsl:template> <!--  ... match="xsd:element[@name='Skill']"> -->

<xsl:template match="xsd:element[@name='SubSkillRefs']">
  <xsd:element ref="Skill" minOccurs="0"  maxOccurs="unbounded"/>
</xsl:template> <!--  ... match="xsd:element[@name='SubSkillRefs']"> -->

<xsl:template match="xsd:attribute[@name='Id']">
  <xsd:attribute name="Id" type="xsd:string" use="required"/>
</xsl:template> <!--  ... match="xsd:element[@name='SubSkillRefs']"> -->

<xsl:template match="xsd:key[@name='SubSkillRefsKey']">
</xsl:template> <!--  ... match="xsd:key[@name='SubSkillRefsKey']"> -->

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
  <scenarios>
    <scenario default="yes" name="DefaultScenario" userelativepaths="yes" externalpreview="no" url="Skill.xsd" htmlbaseurl="" outputurl="SkillFullyExpanded-auto-generated.xsd" processortype="saxon8" useresolver="yes" profilemode="0" profiledepth=""
              profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext="" validateoutput="yes" validator="custom"
              customvalidator="Saxonica Validator XSD 1.1">
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
      <validatorSchema value="XMLSchema.xsd"/>
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