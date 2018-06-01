<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:strip-space elements="*"/>

<xsl:param name="TargetName"             select="'Root'"/>
<xsl:param name="TargetLevel"            select="'Expert'"/>
<xsl:param name="ShowDefinitionUnfolded" select="'true'"/>
<xsl:param name="CreateLinksToContent"   select="'true'"/>

<xsl:variable name="FilenameSuffixStandalone" select ="'standalone'"/>
<xsl:variable name="FilenameSuffixEmbeddable" select ="'embedabble'"/>

<!-- kh 12.02.18 omit-xml-declaration (i.e. <?xml version="1.0" encoding="utf-8"?>) to avoid warning message from freemind at startup "... die eingelesene Mindmap 
wurde mit einem unbekannten Programm erzeugt. es kann sein, dass Freeplane dies inkorrekt öffnet, 
anzeigt oder abspeichert ... die Webseite ist unbekannt" -->
<!--
<xsl:output method="xml" indent="yes" encoding="UTF-8" omit-xml-declaration="yes"/>
-->

<!-- kh 20.03.18 encoding change for Saxon-HE 9.8.0.11J -->
<!--
<xsl:output method="xml" indent="yes" encoding="ISO-8859-1" omit-xml-declaration="yes"/>
-->

<!-- kh 08.05.18 use pure US-ASCII encoding for best results (Umlauts etc.) -->
<xsl:output method="xml" indent="yes" encoding="US-ASCII" omit-xml-declaration="yes"/>

<xsl:template match="/">

<!-- kh 23.01.18 place prologue here -->
<!--
<map version="freeplane 1.3.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="freeplane_1.3.x.xsd">
-->

<!-- kh 12.02.18 include schema validation (e.g. for debug purposes) -->
<!--
<map version="freeplane 1.3.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="freeplane_1.3.x.xsd">
-->
<!-- kh 12.02.18 omit schema validation to avoid warning message from freemind at startup "... die eingelesene Mindmap 
wurde mit einem unbekannten Programm erzeugt. es kann sein, dass Freeplane dies inkorrekt öffnet, 
anzeigt oder abspeichert ... die Webseite ist unbekannt" -->
<!-- -->
<map version="freeplane 1.3.0">
<!-- -->
<!--
  <xsl:attribute name="version">freeplane 1.3.0</xsl:attribute>
-->

<!--
  <xsl:namespace :attribute name="xmlns:xsi">http://www.w3.org/2001/XMLSchema-instance</xsl:attribute>
  <xsl:attribute name="xsi:noNamespaceSchemaLocation">freeplane_1.3.x.xsd</xsl:attribute>
-->

<xsl:comment>To view this file, download free mind mapping software Freeplane from http://freeplane.sourceforge.net</xsl:comment>

<!-- kh 07.02.18 select the root node in the (flat) list of skills with cross-references -->
<!--
  <xsl:variable name="RootNode" select=".//Skill[@Name = 'Root']"/>
-->

  <xsl:variable name="RootNode" select=".//Skill[(@Name = $TargetName) and (@Level = $TargetLevel)]"/>
  
  <xsl:apply-templates select="$RootNode">

<!-- kh 07.02.18 insert the root node as first node in the actual skill path -->
    <xsl:with-param name="SkillPath"  select="$RootNode"/>
    <xsl:with-param name="ParentSkill"/>
    <xsl:with-param name="Height" select="0"/>

  </xsl:apply-templates>

<!-- kh 23.01.18 place epilogue here -->
</map>

</xsl:template> <!-- ... match="/"> -->

<xsl:template match="Skill">
  <xsl:param name="SkillPath"/>
  <xsl:param name="ParentSkill"/>
  <xsl:param name="Height"/>

<node> 
  
  <xsl:choose>
    <xsl:when test="@Name = 'Root'">
<!--
      <xsl:attribute name="TEXT">Skill Tree</xsl:attribute>
-->
      <xsl:attribute name="TEXT">SKILLS</xsl:attribute>
    </xsl:when>
    <xsl:otherwise>
      <xsl:attribute name="TEXT">
        <xsl:value-of select="@Id"/>
        <xsl:value-of select="': '"/>
        <xsl:value-of select="@Name"/>

  <!-- kh 29.03.18 redundant information (already contained in Id attribute) -->
  <!--
        <xsl:value-of select="concat(' (', @Level, ')')"/>
  -->

        <!-- kh 19.02. for freeplane the main sort order is by category, so attribute for category is not appended here  -->

      </xsl:attribute>
    </xsl:otherwise>
  </xsl:choose>

<!--
  <xsl:attribute name="ID"> <xsl:value-of select="@Id"/> </xsl:attribute>
-->
  <xsl:attribute name="ID"> <xsl:value-of select="generate-id(.)"/> </xsl:attribute>

<!--<xsl:attribute name="CREATED"> <xsl:value-of select="current-dateTime()"/> </xsl:attribute>-->

<!-- kh 05.02.18 use "default" values here -->
  <xsl:attribute name="CREATED">1283093380553</xsl:attribute>
  <xsl:attribute name="MODIFIED">1283093380553</xsl:attribute>

<!-- kh 13.02.18 use freemind node Level 1 for the root -->
  <xsl:attribute name="LOCALIZED_STYLE_REF">AutomaticLayout.level,<xsl:value-of select="min(($Height + 1, 4))"/></xsl:attribute>

<!-- kh 12.02.18 context specific positions -->  
  <xsl:if test="@Name = 'HPC Knowledge'">
    <xsl:attribute name="POSITION">right</xsl:attribute>
    <edge COLOR="#00cc33"/>
  </xsl:if>

  <xsl:if test="@Name = 'Use of the HPC Environment'">
    <xsl:attribute name="POSITION">right</xsl:attribute>
    <edge COLOR="#ff9900"/>
  </xsl:if>

  <xsl:if test="@Name = 'Performance Engineering'">
    <xsl:attribute name="POSITION">left</xsl:attribute>
    <edge COLOR="#ff0000"/>
  </xsl:if>
  
  <xsl:if test="@Name = 'Software Engineering for HPC'">
    <xsl:attribute name="POSITION">left</xsl:attribute>
    <edge COLOR="#0000ff"/>
  </xsl:if>

  <xsl:if test="    (@Name = 'Root') 
                 or (@Name = 'Skill Tree')">
    <hook>
      <xsl:attribute name="NAME">MapStyle</xsl:attribute>
      <map_styles>
        <stylenode LOCALIZED_TEXT="styles.root_node">
          <stylenode LOCALIZED_TEXT="styles.predefined" POSITION="right">
            <stylenode LOCALIZED_TEXT="default" MAX_WIDTH="600" COLOR="#000000" STYLE="as_parent">
              <font NAME="SansSerif" SIZE="10" BOLD="false" ITALIC="false"/>
            </stylenode>
            <stylenode LOCALIZED_TEXT="defaultstyle.details"/>
	          <stylenode LOCALIZED_TEXT="defaultstyle.note"/>
            <stylenode LOCALIZED_TEXT="defaultstyle.floating">
	            <edge STYLE="hide_edge"/>
	            <cloud COLOR="#f0f0f0" SHAPE="ROUND_RECT"/>
	          </stylenode>
	        </stylenode>
          <stylenode LOCALIZED_TEXT="styles.user-defined" POSITION="right">
	          <stylenode LOCALIZED_TEXT="styles.topic" COLOR="#18898b" STYLE="fork">
	            <font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
	          </stylenode>
	          <stylenode LOCALIZED_TEXT="styles.subtopic" COLOR="#cc3300" STYLE="fork">
	            <font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
	          </stylenode>
	          <stylenode LOCALIZED_TEXT="styles.subsubtopic" COLOR="#669900">
	            <font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
	          </stylenode>
	          <stylenode LOCALIZED_TEXT="styles.important">
	            <icon BUILTIN="yes"/>
	          </stylenode>
	        </stylenode>
          <stylenode LOCALIZED_TEXT="styles.AutomaticLayout" POSITION="right">
            <stylenode LOCALIZED_TEXT="AutomaticLayout.level.root" COLOR="#000000">
              <font SIZE="18"/>
            </stylenode>
            <stylenode LOCALIZED_TEXT="AutomaticLayout.level,1" COLOR="#0033ff">
              <font SIZE="16"/>
            </stylenode>
            <stylenode LOCALIZED_TEXT="AutomaticLayout.level,2" COLOR="#00b439">
              <font SIZE="14"/>
            </stylenode>
            <stylenode LOCALIZED_TEXT="AutomaticLayout.level,3" COLOR="#990000">
              <font SIZE="12"/>
            </stylenode>
            <stylenode LOCALIZED_TEXT="AutomaticLayout.level,4" COLOR="#111111">
              <font SIZE="10"/>
            </stylenode>
          </stylenode>
        </stylenode>
      </map_styles>
    </hook>

  </xsl:if>

<!-- kh 19.02.18 a Skill is only expanded if it is referenced by its main parent, so IsCycle is never expected to be true -->
<!-- kh 07.02.18 $SkillPath contains the actual node at the last position, 
i.e. another entry in the path indicates a cyclic depedency -->
  <xsl:variable name="IsCycle" select="count($SkillPath[@Name = current()/@Name][@Level = current()/@Level]) > 1"/>
<!--  <xsl:variable name="IsCycle" select="count($SkillPath[@Name = current()/@Name[@Level = current()/@Level]]) > 1"/> -->

<!--  <xsl:copy-of select="$SkillPath//Skill"/> -->

<!-- kh 12.02.18 will never have an effect here, because each node is only fully expanded once -->
  <xsl:if test="$IsCycle = true()">

<!-- kh 12.02.18 todo for freeplane (e.g. mark with 3 * asterisk)-->

    <CyclicDependency>
      <xsl:for-each select="$SkillPath">
        <xsl:value-of select="./@Name"/>.<xsl:value-of select="./@Level"/>
        <xsl:if test="position() lt last()"> - </xsl:if>
      </xsl:for-each>
    </CyclicDependency>

  </xsl:if> <!-- test="IsCycle = 'true'" -->

  <xsl:if test="$IsCycle = false()">

<!--
    <xsl:if test="string-length(replace(/Definition/ShortBackground//Item, '^\s+|\s+$', '')) > 0">
-->

<!-- kh 29.03.18 skip root details -->  
<!--
    <xsl:if test="@Name != 'Root'">
-->

<!-- kh 16.04.18 check certificates here explicitly for the moment (use an attribute later) -->
    <xsl:if test="     (@Name != 'Root')
                   and (@Name != 'Skill Tree')
                   and (@Name != 'Test Certificate')">

      <xsl:variable name="RichContentElementLeadoutString" select="'&lt;/richcontent&gt;'"/>

      <xsl:variable name="RichContentElementLeadinString">
        <xsl:choose>
          <xsl:when test="$ShowDefinitionUnfolded='true'">
              <xsl:value-of select="'&lt;richcontent TYPE=&quot;DETAILS&quot;&gt;'"/>
          </xsl:when>
          <xsl:otherwise>
              <xsl:value-of select="'&lt;richcontent TYPE=&quot;DETAILS&quot; HIDDEN=&quot;true&quot;&gt;'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:text>&#xA;</xsl:text>
      <xsl:value-of select="$RichContentElementLeadinString" disable-output-escaping="yes"/>
        <html>
          <head>
          </head>
          <body>
            <p>
              <i>Relevant for: </i>
<!-- kh 28.03.18 non italics ":" looks awkward in freemind
               <xsl:value-of select="': '"/> 
-->
              <xsl:for-each select="./RelevantForRoles//Role">
                <xsl:if test="position() > 1">
                  <xsl:value-of select="', '"/>
                </xsl:if>
                <xsl:value-of select="@Name"/>
              </xsl:for-each>
            </p>

      <xsl:variable name="MessageCount" select="   count(Definition/ShortBackground//Item[string-length(replace(., '^\s+|\s+$', '')) > 0]) 
                                                 + count(Definition/Description//Item    [string-length(replace(., '^\s+|\s+$', '')) > 0])"/>
      <xsl:if test="$MessageCount > 0">

<!-- kh 27.03.18 
        <richcontent TYPE="DETAILS" HIDDEN="true">
          <html>
            <head>
            </head>
            <body>
-->

<!-- <xsl:copy-of select="Authors"/> -->
<!--
      <xsl:apply-templates select="Authors"/>
-->
      <xsl:apply-templates select="Definition"/>
<!--
      <xsl:apply-templates select="RelevantForDomains"/>

      <xsl:apply-templates select="RelevantForRoles"/>

      <xsl:apply-templates select="MainParentSkillRef"/>
 -->

<!-- kh 27.03.18
            </body>
          </html>
        </richcontent>
-->
      </xsl:if>

          </body>
        </html>
      <xsl:text>&#xA;</xsl:text>
      <xsl:value-of select="$RichContentElementLeadoutString" disable-output-escaping="yes"/>
    </xsl:if>

    <xsl:apply-templates select=".//SkillRef">
      <xsl:with-param name="SkillPath" select="$SkillPath"/>
      <xsl:with-param name="ParentSkill" select="."/>
      <xsl:with-param name="Height" select="$Height"/>
    </xsl:apply-templates>

<!--
    <xsl:variable name="SkillPathLength" select="count($SkillPath)"/>
-->
  </xsl:if> <!-- test="IsCycle = 'false'" -->
<!--
  <xsl:if test="@Name = 'Root'">
-->
  <xsl:if test="@Name = $TargetName">
    <hook NAME="AlwaysUnfoldedNode"/>
  </xsl:if>
</node>

<xsl:if test="$CreateLinksToContent = 'true'">
  <xsl:if test="count(//ContentElements/ContentElement[(@Name = current()/@Name) and (@Level = current()/@Level)]/Chapters/Chapter) > 0">
    <xsl:variable name="Path" select="'../content/auto-generated/'"/>
    <xsl:variable name="Filename" select="lower-case(replace(concat(@Name, '-', @Level), '\s', '-'))"/>
    <xsl:variable name="PathAndFilenameStandalone" select="concat($Path, $Filename, '-ch-', $FilenameSuffixStandalone)"/>

    <xsl:call-template name="createNodeWithHyperlinkToFile">
      <xsl:with-param name="IDExtension" select="'-ch-html'"/>
      <xsl:with-param name="PathAndFilename" select="$PathAndFilenameStandalone"/>
      <xsl:with-param name="FileExtension" select="'.html'"/>
      <xsl:with-param name="PromptString" select="'HTML'"/>
    </xsl:call-template>

<!--
    <xsl:call-template name="createNodeWithHyperlinkToFile">
      <xsl:with-param name="IDExtension" select="'-ch-tex'"/>
      <xsl:with-param name="PathAndFilename" select="$PathAndFilenameStandalone"/>
      <xsl:with-param name="FileExtension" select="'.tex'"/>
      <xsl:with-param name="PromptString" select="'LaTeX'"/>
    </xsl:call-template>
-->

    <xsl:call-template name="createNodeWithHyperlinkToFile">
      <xsl:with-param name="IDExtension" select="'-ch-pdf'"/>
      <xsl:with-param name="PathAndFilename" select="$PathAndFilenameStandalone"/>
      <xsl:with-param name="FileExtension" select="'.pdf'"/>
      <xsl:with-param name="PromptString" select="'PDF'"/>
    </xsl:call-template>

  </xsl:if>

  <xsl:if test="count(//ContentElements/ContentElement[(@Name = current()/@Name) and (@Level = current()/@Level)]/Slides/Slide) > 0">
    <xsl:variable name="Path" select="'../content/auto-generated/'"/>
    <xsl:variable name="Filename" select="lower-case(replace(concat(@Name, '-', @Level), '\s', '-'))"/>
    <xsl:variable name="PathAndFilenameStandalone" select="concat($Path, $Filename, '-sl-', $FilenameSuffixStandalone)"/>

    <xsl:call-template name="createNodeWithHyperlinkToFile">
      <xsl:with-param name="IDExtension" select="'-sl-html'"/>
      <xsl:with-param name="PathAndFilename" select="$PathAndFilenameStandalone"/>
      <xsl:with-param name="FileExtension" select="'.html'"/>
      <xsl:with-param name="PromptString" select="'HTML Slides'"/>
    </xsl:call-template>

<!--
    <xsl:call-template name="createNodeWithHyperlinkToFile">
      <xsl:with-param name="IDExtension" select="'-sl-tex'"/>
      <xsl:with-param name="PathAndFilename" select="$PathAndFilenameStandalone"/>
      <xsl:with-param name="FileExtension" select="'.tex'"/>
      <xsl:with-param name="PromptString" select="'LaTeX Slides'"/>
    </xsl:call-template>
-->

    <xsl:call-template name="createNodeWithHyperlinkToFile">
      <xsl:with-param name="IDExtension" select="'-sl-pdf'"/>
      <xsl:with-param name="PathAndFilename" select="$PathAndFilenameStandalone"/>
      <xsl:with-param name="FileExtension" select="'.pdf'"/>
      <xsl:with-param name="PromptString" select="'PDF Slides'"/>
    </xsl:call-template>

  </xsl:if>
</xsl:if>
</xsl:template> <!-- ... match="Skill"> -->

<xsl:template name="createNodeWithHyperlinkToFile">
  <xsl:param name="IDExtension"/>
  <xsl:param name="PathAndFilename"/>
  <xsl:param name="FileExtension"/>
  <xsl:param name="PromptString"/>

  <node>
    <xsl:attribute name="ID"> <xsl:value-of select="concat(generate-id(.), $IDExtension)"/></xsl:attribute>

  <!--<xsl:attribute name="CREATED"> <xsl:value-of select="current-dateTime()"/> </xsl:attribute>-->

  <!-- kh 05.02.18 use "default" values here -->
    <xsl:attribute name="CREATED">1283093380553</xsl:attribute>
    <xsl:attribute name="MODIFIED">1283093380553</xsl:attribute>

    <xsl:attribute name="TEXT"> <xsl:value-of select="$PromptString"/> </xsl:attribute>
    <xsl:attribute name="LINK"> <xsl:value-of select="concat($PathAndFilename, $FileExtension)"/> </xsl:attribute>

  </node>
</xsl:template>

<xsl:template match="SkillRef">
  <xsl:param name="SkillPath"/>
  <xsl:param name="ParentSkill"/>
  <xsl:param name="Height"/>

  <xsl:variable name="SkillDeref" select="//Skill[@Name = current()/@Name][@Level = current()/@Level]"/>

  <xsl:variable name="IsMainParent">
    <xsl:call-template name="isMainParent">

<!-- kh 16.04.18 append $SkillDeref for checks over the full path length -->
      <xsl:with-param name="SkillPath" select="$SkillPath, $SkillDeref"/>
      <xsl:with-param name="ParentSkill" select="$ParentSkill"/>
      <xsl:with-param name="SkillRef" select="."/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:if test = "$IsMainParent = true()">
    <xsl:apply-templates select="$SkillDeref">

<!-- kh 07.02.18 append current skill node to the actual skill path -->
      <xsl:with-param name="SkillPath" select="$SkillPath, $SkillDeref"/>

<!-- kh 12.02.18 pass-through current parent -->
      <xsl:with-param name="ParentSkill" select="$ParentSkill"/>

<!-- kh 13.02.18 set new height -->
      <xsl:with-param name="Height" select="$Height + 1"/>
    </xsl:apply-templates>

  </xsl:if>

  <xsl:if test = "$IsMainParent = false()">
    <node> 
  
      <xsl:attribute name="TEXT">
        <xsl:value-of select="$SkillDeref/@Id"/>
        <xsl:value-of select="': '"/>
        <xsl:value-of select="$SkillDeref/@Name"/>

<!-- kh 29.03.18 redundant information (already contained in Id attribute) -->
<!--
        <xsl:value-of select="concat(' (', @Level, ')')"/>
-->
      </xsl:attribute>

<!-- kh 12.02. todo for freeplane <xsl:attribute name="Level"> <xsl:value-of select="@Level"/> </xsl:attribute> -->
<!-- kh 12.02. todo for freeplane <xsl:attribute name="ID"> <xsl:value-of select="@Id"/> </xsl:attribute> -->
<!-- kh 12.02. todo for freeplane <xsl:attribute name="Category"> <xsl:value-of select="@Category"/> </xsl:attribute> -->

<!--
      <xsl:attribute name="ID"> <xsl:value-of select="$SkillDeref/@Id"/> </xsl:attribute>
-->
      <xsl:attribute name="ID"> <xsl:value-of select="generate-id(.)"/> </xsl:attribute>

<!--  <xsl:attribute name="CREATED"> <xsl:value-of select="current-dateTime()"/> </xsl:attribute>-->
<!-- kh 05.02.18 use "default" values here -->
      <xsl:attribute name="CREATED">1283093380553</xsl:attribute>
      <xsl:attribute name="MODIFIED">1283093380553</xsl:attribute>

<!-- kh 27.03.18 use a real Freemind link -->
      <xsl:attribute name="LINK"> <xsl:value-of select="concat('#', generate-id($SkillDeref))"/> </xsl:attribute>


<!-- kh 13.02.18 use freemind node Level 1 for the root and increment additionally for the next (not fully expanded) level here -->
      <xsl:attribute name="LOCALIZED_STYLE_REF">AutomaticLayout.level,<xsl:value-of select="min(($Height + 1 + 1, 4))"/></xsl:attribute>

<!-- kh 27.03.18 
      <icon BUILTIN="forward"/>
-->

    </node>
  </xsl:if>
</xsl:template> <!-- ... match="SkillRef"> -->

<xsl:template match="Authors">
  <Authors>
    <xsl:apply-templates select=".//Author"/>
  </Authors>
</xsl:template>
<xsl:template match="Author">
  <Author>
    <xsl:value-of select="normalize-space(.)"/>
  </Author>
</xsl:template>

<xsl:template match="Definition">
<!--
  <xsl:if test="../@Name != 'Root'">
-->

<!-- kh 16.04.18 check certificates here explicitly for the moment (use an attribute later) -->
  <xsl:if test="     (../@Name != 'Root')
                 and (../@Name != 'Skill Tree')
                 and (../@Name != 'Test Certificate')">

    <xsl:apply-templates select="ShortBackground"/>
    <xsl:apply-templates select="Description"/>
  </xsl:if>
</xsl:template>

<xsl:template match="ShortBackground">
  <xsl:for-each select="Item[string-length(replace(., '^\s+|\s+$', '')) > 0]">
    <p>
      <xsl:if test="position() = 1">
        <i>Short Background: </i>
      </xsl:if>

      <xsl:variable name="ItemEscapedString">
        <xsl:call-template name="escapeSpecialCharacters">
          <xsl:with-param name="Item" select="."/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:value-of select="replace($ItemEscapedString, '^\s+|\s+$', '')"/>
    </p>
  </xsl:for-each>
</xsl:template>

<xsl:template match="Description">
  <xsl:for-each select="Item[string-length(replace(., '^\s+|\s+$', '')) > 0]">
    <p>
      <xsl:if test="position() = 1">
        <i>Description: </i>
      </xsl:if>

      <xsl:variable name="ItemEscapedString">
        <xsl:call-template name="escapeSpecialCharacters">
          <xsl:with-param name="Item" select="."/>
         </xsl:call-template>
      </xsl:variable>

      <xsl:variable name="ItemPreBaseString">
        <xsl:choose>
          <xsl:when test="@IsGeneralPhrase = true()">
            <xsl:value-of select="concat(replace($ItemEscapedString, '^\s+|\s+$', ''), ' (according to the respective level)')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="replace($ItemEscapedString, '^\s+|\s+$', '')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:variable name="ItemBaseString">
        <xsl:choose>
          <xsl:when test="@IsBackgroundTopic = true()">
            <xsl:value-of select="concat($ItemPreBaseString, ' (background topic)')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$ItemPreBaseString"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="exists(@AssociatedSkillRefName)">
          <xsl:variable name="AssociatedSkillId" select="//Skill[./@Name = current()/@AssociatedSkillRefName][./@Level = current()/@AssociatedSkillRefLevel]/@Id"/>
          <xsl:variable name="ItemString" select="concat($ItemBaseString, ' (see also ', $AssociatedSkillId, ' ', replace(@AssociatedSkillRefName, '^\s+|\s+$', ''), ')')"/>
          <xsl:value-of select="$ItemString"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$ItemBaseString"/>
        </xsl:otherwise>
      </xsl:choose>
    </p>
  </xsl:for-each>
</xsl:template>

<xsl:template match="RelevantForDomains">
  <RelevantForDomains>
    <xsl:apply-templates select=".//Domain"/>
  </RelevantForDomains>
</xsl:template>
<xsl:template match="Domain">
  <Domain>
      <xsl:attribute name="Type"> <xsl:value-of select="@Type"/> </xsl:attribute>
      <xsl:attribute name="EstimatedBenefit"> <xsl:value-of select="@EstimatedBenefit"/> </xsl:attribute>
  </Domain>
</xsl:template>

<xsl:template match="RelevantForRoles">
  <RelevantForRole>
    <xsl:apply-templates select=".//Role"/>
  </RelevantForRole>
</xsl:template>
<xsl:template match="Role">
  <Domain>
      <xsl:attribute name="Type"><xsl:value-of select="@Type"/></xsl:attribute>
      <xsl:attribute name="EstimatedBenefit"><xsl:value-of select="@EstimatedBenefit"/></xsl:attribute>
  </Domain>
</xsl:template>

<xsl:template match="MainParentSkillRef">
  <MainParentSkillRef>
      <xsl:attribute name="Name"> <xsl:value-of select="@Name"/> </xsl:attribute>
      <xsl:attribute name="Level"> <xsl:value-of select="@Level"/> </xsl:attribute>
  </MainParentSkillRef>
</xsl:template>

<xsl:template name="isMainParent">
  <xsl:param name="SkillPath"/>
  <xsl:param name="ParentSkill"/>
  <xsl:param name="SkillRef"/>

  <xsl:variable name="SkillDeref" select="//Skill[@Name = $SkillRef/@Name][@Level = $SkillRef/@Level]"/>

<!-- kh 17.04.18 check if the parent skill is the real main parent or a logical main parent (e.g. 'Root' or
     $TargetName) -->
  <xsl:variable name="IsMainParentSimpleCheck" select="    (     ($ParentSkill/@Name  = $SkillDeref/MainParentSkillRef/@Name)
                                                             and ($ParentSkill/@Level = $SkillDeref/MainParentSkillRef/@Level))
                                                        or ($ParentSkill/@Name = 'Root')
            	  						                            or ($SkillDeref/MainParentSkillRef/@Name = 'Ignore')

                                                        or (     ($ParentSkill/@Name  = $TargetName)
                                                             and ($ParentSkill/@Level = $TargetLevel))"/>

  <xsl:variable name="IsMainParent">
    <xsl:choose>

      <xsl:when test="    ($IsMainParentSimpleCheck = true())
                       or ($TargetName = 'Root')
                       or (     ($TargetName  = 'Skill Tree') 
                            and ($TargetLevel = 'Expert'))">

<!-- kh 17.04.18 it is implied here that the $ParentSkill is either handled as a main parent or the main parent is contained in the subtree and will be found anywhere during expansion of the skill tree -->
        <xsl:copy-of select="$IsMainParentSimpleCheck"/>
      </xsl:when>

      <xsl:otherwise>

<!-- kh 17.04.18 it is implied here that the $ParentSkill is not handled as a main parent -->
        <xsl:variable name="RootNodeLocal" select="//Skill[(@Name = $TargetName) and (@Level = $TargetLevel)]"/>

<!-- kh 17.04.18 check if $RootNodeLocal will ne handled as the main parent during expansion -->
        <xsl:variable name="IsReferencedByTarget" select="count($RootNodeLocal//SkillRef[     (@Name  = $SkillDeref/@Name)
                                                                                          and (@Level = $SkillDeref/@Level)]) > 0"/>
        <xsl:choose>
          <xsl:when test="$IsReferencedByTarget = true()">
            <xsl:copy-of select="false()"/>
          </xsl:when>
          <xsl:otherwise>
           <xsl:variable name="ContainsMainParent">
              <xsl:call-template name="containsMainParent">
                <xsl:with-param name="Skill" select="$RootNodeLocal"/>
                <xsl:with-param name="SkillToSearch" select="$SkillDeref"/>
              </xsl:call-template>
            </xsl:variable>
            <xsl:choose>

<!-- kh 16.04.18 if the main parent is contained in the subtree with the relative root specified via $TargetName and $TargetLevel
         the current $SkillRef node will be expanded when it is encountered in the SubSkillRefs of its main parent
-->
              <xsl:when test="$ContainsMainParent = true()">
                <xsl:copy-of select="not($ContainsMainParent)"/>
              </xsl:when>
              <xsl:otherwise>

<!-- kh 16.04.18 check if $ParentSkill is the first skill node in the subtree with the relative root specified via $TargetName and $TargetLevel
                 that references the current $SkillRef node in its SubSkillRefs
-->
                <xsl:variable name="GetSkillPathSet">
                  <xsl:call-template name="getSkillPaths">
                    <xsl:with-param name="SkillPath" select="$RootNodeLocal"/>
                    <xsl:with-param name="Skill" select="$RootNodeLocal"/>
                    <xsl:with-param name="SkillToSearch" select="$SkillDeref"/>
                  </xsl:call-template>
                </xsl:variable>

                <xsl:variable name="PathString1">
                  <xsl:for-each select="$SkillPath">
                      <xsl:value-of select="concat(@Name, ' ', @Level)"/>
                  </xsl:for-each>
                </xsl:variable>

                <xsl:variable name="PathString2">
                  <xsl:for-each select="$GetSkillPathSet/Path[1]">
                    <xsl:for-each select="Skill">
                      <xsl:value-of select="concat(./@Name, ' ', ./@Level)"/>
                    </xsl:for-each>
                  </xsl:for-each>
                </xsl:variable>

                <xsl:choose>
                  <xsl:when test="$PathString1 = $PathString2">
                    <xsl:value-of select="true()"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:copy-of select="$IsMainParent"/>

</xsl:template> <!-- ... name="isMainParent"> -->

<xsl:template name="containsMainParent">
  <xsl:param name="Skill"/>
  <xsl:param name="SkillToSearch"/>

  <xsl:variable name="ContainsMainParent">
    <xsl:choose>
      <xsl:when test="(     ($Skill/@Name  = $SkillToSearch/MainParentSkillRef/@Name)
                        and ($Skill/@Level = $SkillToSearch/MainParentSkillRef/@Level))">
        <xsl:copy-of select="true()"/>
    </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="count($Skill//SkillRef) > 0">
            <xsl:for-each select="$Skill//SkillRef">
              <xsl:variable name="SkillDeref" select="//Skill[@Name = current()/@Name][@Level = current()/@Level]"/>
              <xsl:call-template name="containsMainParent">
                <xsl:with-param name="Skill" select="$SkillDeref"/>
                <xsl:with-param name="SkillToSearch" select="$SkillToSearch"/>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="false()"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="CountContainedMainParents">
    <xsl:choose>
      <xsl:when test="contains($ContainsMainParent, 'true')">
        <xsl:value-of select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
       </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:if test="$CountContainedMainParents > 1">
    <Error>
       <xsl:value-of select="concat('$CountContainedMainParents is ', $CountContainedMainParents, ' (max. 1 expected)')"/>
    </Error>
  </xsl:if>
  
  <xsl:variable name="ContainsMainParentReduced" select="$CountContainedMainParents > 0"/>

  <xsl:copy-of select="$ContainsMainParentReduced"/>
</xsl:template>

<xsl:template name="getSkillPaths">
  <xsl:param name="SkillPath"/>
  <xsl:param name="Skill"/>
  <xsl:param name="SkillToSearch"/>

  <xsl:choose>
    <xsl:when test="(     ($Skill/@Name  = $SkillToSearch/@Name)
                      and ($Skill/@Level = $SkillToSearch/@Level))">
      <Path>
        <xsl:copy-of select="$SkillPath"/>
      </Path>
  </xsl:when>
    <xsl:otherwise>
      <xsl:choose>
        <xsl:when test="count($Skill//SkillRef) > 0">
          <xsl:for-each select="$Skill//SkillRef">
            <xsl:variable name="SkillDeref" select="//Skill[@Name = current()/@Name][@Level = current()/@Level]"/>
            <xsl:call-template name="getSkillPaths">
              <xsl:with-param name="SkillPath" select="$SkillPath, $SkillDeref"/>
              <xsl:with-param name="Skill" select="$SkillDeref"/>
              <xsl:with-param name="SkillToSearch" select="$SkillToSearch"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<xsl:template name="escapeSpecialCharacters">
  <xsl:param name="Item"/>

<!-- ä &#xe4; ö &#xf6; ü &#xfc; Ä &#xc4; Ö &#xd6; Ü &#xdc; ß &#xdf; -->
<!--
  <xsl:copy-of select="replace(replace(replace(replace(replace(replace(replace($Item, 'ä', '&#xe4;'), 'ö', '&#xf6;'), 'ü', '&#xfc;'), 'Ä', '&#xc4;'), 'Ö', '&#xd6;'), 'Ü', '&#xdc;'),  'ß', '&#xdf;')"/>
-->

<!-- kh 08.05.18 nothing todo for actual encoding="US-ASCII" --> 
  <xsl:copy-of select="$Item"/>

</xsl:template>

</xsl:stylesheet>
<!-- Stylus Studio meta-information - (c) 2004-2009. Progress Software Corporation. All rights reserved.

<metaInformation>
  <scenarios>
    <scenario default="no" name="NonPSpeech" userelativepaths="yes" externalpreview="no" url="skills-non-personal-speech-auto-generated.xml" htmlbaseurl="" outputurl="skills-non-personal-speech-auto-generated.mm" processortype="saxon8" useresolver="yes"
              profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""
              validateoutput="yes" validator="custom" customvalidator="Saxonica Validator XSD 1.1">
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
      <validatorSchema value="freeplane_1.3.x.xsd"/>
    </scenario>
    <scenario default="no" name="PSpeech" userelativepaths="yes" externalpreview="no" url="skills-personal-speech-auto-generated.xml" htmlbaseurl="" outputurl="skills-personal-speech-auto-generated.mm" processortype="saxon8" useresolver="yes"
              profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""
              validateoutput="yes" validator="custom" customvalidator="Saxonica Validator XSD 1.1">
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
      <validatorSchema value="freeplane_1.3.x.xsd"/>
    </scenario>
    <scenario default="no" name="NonPSpeechSkillTreeIntermediate" userelativepaths="yes" externalpreview="no" url="skills-non-personal-speech-auto-generated.xml" htmlbaseurl="" outputurl="skills-non-personal-speech-auto-generated.mm" processortype="saxon8"
              useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath=""
              postprocessgeneratedext="" validateoutput="yes" validator="custom" customvalidator="Saxonica Validator XSD 1.1">
      <parameterValue name="TargetName" value="'Skill Tree'"/>
      <parameterValue name="TargetLevel" value="'Intermediate'"/>
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
      <validatorSchema value="freeplane_1.3.x.xsd"/>
    </scenario>
    <scenario default="no" name="NonPSpeechRoot" userelativepaths="yes" externalpreview="no" url="skills-non-personal-speech-auto-generated.xml" htmlbaseurl="" outputurl="skills-non-personal-speech-auto-generated.mm" processortype="saxon8"
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
      <validatorSchema value="freeplane_1.3.x.xsd"/>
    </scenario>
    <scenario default="no" name="NonPSpeechSkillTreeExpert" userelativepaths="yes" externalpreview="no" url="skills-non-personal-speech-auto-generated.xml" htmlbaseurl="" outputurl="skills-non-personal-speech-auto-generated.mm" processortype="saxon8"
              useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath=""
              postprocessgeneratedext="" validateoutput="yes" validator="custom" customvalidator="Saxonica Validator XSD 1.1">
      <parameterValue name="TargetName" value="'Skill Tree'"/>
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
      <validatorSchema value="freeplane_1.3.x.xsd"/>
    </scenario>
    <scenario default="yes" name="NonPSpeechWithContentTest" userelativepaths="yes" externalpreview="no" url="skills-and-content-non-personal-speech-auto-generated.xml" htmlbaseurl="" outputurl="skills-and-content-non-personal-speech-auto-generated.mm"
              processortype="saxon8" useresolver="yes" profilemode="0" profiledepth="" profilelength="" urlprofilexml="" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath=""
              postprocessgeneratedext="" validateoutput="yes" validator="custom" customvalidator="Saxonica Validator XSD 1.1">
      <parameterValue name="TargetName" value="'Test Certificate'"/>
      <parameterValue name="TargetLevel" value="'Basic'"/>
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
      <validatorSchema value="freeplane_1.3.x.xsd"/>
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