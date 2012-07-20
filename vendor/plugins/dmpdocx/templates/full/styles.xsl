<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" omit-xml-declaration="no" version="1.0" encoding="UTF-8" indent="no" standalone="yes"/>
  <xsl:template match="/dmp">
    <w:styles xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships" xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main" xmlns:w14="http://schemas.microsoft.com/office/word/2010/wordml" mc:Ignorable="w14">
      <w:docDefaults>
        <w:rPrDefault>
          <w:rPr>
            <w:rFonts w:asciiTheme="minorHAnsi" w:eastAsiaTheme="minorHAnsi" w:hAnsiTheme="minorHAnsi" w:cstheme="minorBidi"/>
            <w:sz>
              <xsl:attribute name="w:val"><xsl:value-of select="2 * format/font_size"/></xsl:attribute>
            </w:sz>
            <w:szCs>
              <xsl:attribute name="w:val"><xsl:value-of select="2 * format/font_size"/></xsl:attribute>
            </w:szCs>
            <w:lang w:val="en-GB" w:eastAsia="en-US" w:bidi="ar-SA"/>
          </w:rPr>
        </w:rPrDefault>
        <w:pPrDefault>
          <w:pPr>
            <w:spacing w:before="60" w:after="120" w:line="276" w:lineRule="auto"/>
          </w:pPr>
        </w:pPrDefault>
      </w:docDefaults>
      <w:latentStyles w:defLockedState="0" w:defUIPriority="99" w:defSemiHidden="1" w:defUnhideWhenUsed="1" w:defQFormat="0" w:count="267">
        <w:lsdException w:name="Normal" w:semiHidden="0" w:uiPriority="0" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="heading 1" w:semiHidden="0" w:uiPriority="9" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="heading 2" w:uiPriority="9" w:qFormat="1"/>
        <w:lsdException w:name="heading 3" w:uiPriority="9" w:qFormat="1"/>
        <w:lsdException w:name="heading 4" w:uiPriority="9" w:qFormat="1"/>
        <w:lsdException w:name="heading 5" w:uiPriority="9" w:qFormat="1"/>
        <w:lsdException w:name="heading 6" w:uiPriority="9" w:qFormat="1"/>
        <w:lsdException w:name="heading 7" w:uiPriority="9" w:qFormat="1"/>
        <w:lsdException w:name="heading 8" w:uiPriority="9" w:qFormat="1"/>
        <w:lsdException w:name="heading 9" w:uiPriority="9" w:qFormat="1"/>
        <w:lsdException w:name="toc 1" w:uiPriority="39"/>
        <w:lsdException w:name="toc 2" w:uiPriority="39"/>
        <w:lsdException w:name="toc 3" w:uiPriority="39"/>
        <w:lsdException w:name="toc 4" w:uiPriority="39"/>
        <w:lsdException w:name="toc 5" w:uiPriority="39"/>
        <w:lsdException w:name="toc 6" w:uiPriority="39"/>
        <w:lsdException w:name="toc 7" w:uiPriority="39"/>
        <w:lsdException w:name="toc 8" w:uiPriority="39"/>
        <w:lsdException w:name="toc 9" w:uiPriority="39"/>
        <w:lsdException w:name="caption" w:uiPriority="35" w:qFormat="1"/>
        <w:lsdException w:name="Title" w:semiHidden="0" w:uiPriority="10" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Default Paragraph Font" w:uiPriority="1"/>
        <w:lsdException w:name="Subtitle" w:semiHidden="0" w:uiPriority="11" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Strong" w:semiHidden="0" w:uiPriority="22" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Emphasis" w:semiHidden="0" w:uiPriority="20" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Table Grid" w:semiHidden="0" w:uiPriority="59" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Placeholder Text" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="No Spacing" w:semiHidden="0" w:uiPriority="1" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Light Shading" w:semiHidden="0" w:uiPriority="60" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light List" w:semiHidden="0" w:uiPriority="61" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Grid" w:semiHidden="0" w:uiPriority="62" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 1" w:semiHidden="0" w:uiPriority="63" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 2" w:semiHidden="0" w:uiPriority="64" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 1" w:semiHidden="0" w:uiPriority="65" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 2" w:semiHidden="0" w:uiPriority="66" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 1" w:semiHidden="0" w:uiPriority="67" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 2" w:semiHidden="0" w:uiPriority="68" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 3" w:semiHidden="0" w:uiPriority="69" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Dark List" w:semiHidden="0" w:uiPriority="70" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Shading" w:semiHidden="0" w:uiPriority="71" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful List" w:semiHidden="0" w:uiPriority="72" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Grid" w:semiHidden="0" w:uiPriority="73" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Shading Accent 1" w:semiHidden="0" w:uiPriority="60" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light List Accent 1" w:semiHidden="0" w:uiPriority="61" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Grid Accent 1" w:semiHidden="0" w:uiPriority="62" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 1 Accent 1" w:semiHidden="0" w:uiPriority="63" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 2 Accent 1" w:semiHidden="0" w:uiPriority="64" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 1 Accent 1" w:semiHidden="0" w:uiPriority="65" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Revision" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="List Paragraph" w:semiHidden="0" w:uiPriority="34" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Quote" w:semiHidden="0" w:uiPriority="29" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Intense Quote" w:semiHidden="0" w:uiPriority="30" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Medium List 2 Accent 1" w:semiHidden="0" w:uiPriority="66" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 1 Accent 1" w:semiHidden="0" w:uiPriority="67" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 2 Accent 1" w:semiHidden="0" w:uiPriority="68" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 3 Accent 1" w:semiHidden="0" w:uiPriority="69" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Dark List Accent 1" w:semiHidden="0" w:uiPriority="70" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Shading Accent 1" w:semiHidden="0" w:uiPriority="71" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful List Accent 1" w:semiHidden="0" w:uiPriority="72" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Grid Accent 1" w:semiHidden="0" w:uiPriority="73" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Shading Accent 2" w:semiHidden="0" w:uiPriority="60" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light List Accent 2" w:semiHidden="0" w:uiPriority="61" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Grid Accent 2" w:semiHidden="0" w:uiPriority="62" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 1 Accent 2" w:semiHidden="0" w:uiPriority="63" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 2 Accent 2" w:semiHidden="0" w:uiPriority="64" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 1 Accent 2" w:semiHidden="0" w:uiPriority="65" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 2 Accent 2" w:semiHidden="0" w:uiPriority="66" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 1 Accent 2" w:semiHidden="0" w:uiPriority="67" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 2 Accent 2" w:semiHidden="0" w:uiPriority="68" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 3 Accent 2" w:semiHidden="0" w:uiPriority="69" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Dark List Accent 2" w:semiHidden="0" w:uiPriority="70" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Shading Accent 2" w:semiHidden="0" w:uiPriority="71" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful List Accent 2" w:semiHidden="0" w:uiPriority="72" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Grid Accent 2" w:semiHidden="0" w:uiPriority="73" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Shading Accent 3" w:semiHidden="0" w:uiPriority="60" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light List Accent 3" w:semiHidden="0" w:uiPriority="61" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Grid Accent 3" w:semiHidden="0" w:uiPriority="62" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 1 Accent 3" w:semiHidden="0" w:uiPriority="63" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 2 Accent 3" w:semiHidden="0" w:uiPriority="64" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 1 Accent 3" w:semiHidden="0" w:uiPriority="65" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 2 Accent 3" w:semiHidden="0" w:uiPriority="66" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 1 Accent 3" w:semiHidden="0" w:uiPriority="67" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 2 Accent 3" w:semiHidden="0" w:uiPriority="68" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 3 Accent 3" w:semiHidden="0" w:uiPriority="69" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Dark List Accent 3" w:semiHidden="0" w:uiPriority="70" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Shading Accent 3" w:semiHidden="0" w:uiPriority="71" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful List Accent 3" w:semiHidden="0" w:uiPriority="72" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Grid Accent 3" w:semiHidden="0" w:uiPriority="73" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Shading Accent 4" w:semiHidden="0" w:uiPriority="60" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light List Accent 4" w:semiHidden="0" w:uiPriority="61" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Grid Accent 4" w:semiHidden="0" w:uiPriority="62" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 1 Accent 4" w:semiHidden="0" w:uiPriority="63" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 2 Accent 4" w:semiHidden="0" w:uiPriority="64" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 1 Accent 4" w:semiHidden="0" w:uiPriority="65" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 2 Accent 4" w:semiHidden="0" w:uiPriority="66" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 1 Accent 4" w:semiHidden="0" w:uiPriority="67" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 2 Accent 4" w:semiHidden="0" w:uiPriority="68" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 3 Accent 4" w:semiHidden="0" w:uiPriority="69" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Dark List Accent 4" w:semiHidden="0" w:uiPriority="70" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Shading Accent 4" w:semiHidden="0" w:uiPriority="71" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful List Accent 4" w:semiHidden="0" w:uiPriority="72" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Grid Accent 4" w:semiHidden="0" w:uiPriority="73" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Shading Accent 5" w:semiHidden="0" w:uiPriority="60" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light List Accent 5" w:semiHidden="0" w:uiPriority="61" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Grid Accent 5" w:semiHidden="0" w:uiPriority="62" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 1 Accent 5" w:semiHidden="0" w:uiPriority="63" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 2 Accent 5" w:semiHidden="0" w:uiPriority="64" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 1 Accent 5" w:semiHidden="0" w:uiPriority="65" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 2 Accent 5" w:semiHidden="0" w:uiPriority="66" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 1 Accent 5" w:semiHidden="0" w:uiPriority="67" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 2 Accent 5" w:semiHidden="0" w:uiPriority="68" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 3 Accent 5" w:semiHidden="0" w:uiPriority="69" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Dark List Accent 5" w:semiHidden="0" w:uiPriority="70" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Shading Accent 5" w:semiHidden="0" w:uiPriority="71" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful List Accent 5" w:semiHidden="0" w:uiPriority="72" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Grid Accent 5" w:semiHidden="0" w:uiPriority="73" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Shading Accent 6" w:semiHidden="0" w:uiPriority="60" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light List Accent 6" w:semiHidden="0" w:uiPriority="61" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Light Grid Accent 6" w:semiHidden="0" w:uiPriority="62" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 1 Accent 6" w:semiHidden="0" w:uiPriority="63" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Shading 2 Accent 6" w:semiHidden="0" w:uiPriority="64" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 1 Accent 6" w:semiHidden="0" w:uiPriority="65" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium List 2 Accent 6" w:semiHidden="0" w:uiPriority="66" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 1 Accent 6" w:semiHidden="0" w:uiPriority="67" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 2 Accent 6" w:semiHidden="0" w:uiPriority="68" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Medium Grid 3 Accent 6" w:semiHidden="0" w:uiPriority="69" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Dark List Accent 6" w:semiHidden="0" w:uiPriority="70" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Shading Accent 6" w:semiHidden="0" w:uiPriority="71" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful List Accent 6" w:semiHidden="0" w:uiPriority="72" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Colorful Grid Accent 6" w:semiHidden="0" w:uiPriority="73" w:unhideWhenUsed="0"/>
        <w:lsdException w:name="Subtle Emphasis" w:semiHidden="0" w:uiPriority="19" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Intense Emphasis" w:semiHidden="0" w:uiPriority="21" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Subtle Reference" w:semiHidden="0" w:uiPriority="31" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Intense Reference" w:semiHidden="0" w:uiPriority="32" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Book Title" w:semiHidden="0" w:uiPriority="33" w:unhideWhenUsed="0" w:qFormat="1"/>
        <w:lsdException w:name="Bibliography" w:uiPriority="37"/>
        <w:lsdException w:name="TOC Heading" w:uiPriority="39" w:qFormat="1"/>
      </w:latentStyles>
      <w:style w:type="paragraph" w:default="1" w:styleId="Normal">
        <w:name w:val="Normal"/>
        <w:qFormat/>
        <w:rsid w:val="00844F3C"/>
        <w:rPr>
          <w:rFonts>
            <xsl:attribute name="w:ascii"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
            <xsl:attribute name="w:hAnsi"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
          </w:rFonts>
          <w:sz>
            <xsl:attribute name="w:val"><xsl:value-of select="2 * format/font_size"/></xsl:attribute>
          </w:sz>
        </w:rPr>
      </w:style>
      <w:style w:type="character" w:default="1" w:styleId="DefaultParagraphFont">
        <w:name w:val="Default Paragraph Font"/>
        <w:uiPriority w:val="1"/>
        <w:semiHidden/>
        <w:unhideWhenUsed/>
      </w:style>
      <w:style w:type="table" w:default="1" w:styleId="TableNormal">
        <w:name w:val="Normal Table"/>
        <w:uiPriority w:val="99"/>
        <w:semiHidden/>
        <w:unhideWhenUsed/>
        <w:tblPr>
          <w:tblInd w:w="0" w:type="dxa"/>
          <w:tblCellMar>
            <w:top w:w="0" w:type="dxa"/>
            <w:left w:w="108" w:type="dxa"/>
            <w:bottom w:w="0" w:type="dxa"/>
            <w:right w:w="108" w:type="dxa"/>
          </w:tblCellMar>
        </w:tblPr>
      </w:style>
      <w:style w:type="numbering" w:default="1" w:styleId="NoList">
        <w:name w:val="No List"/>
        <w:uiPriority w:val="99"/>
        <w:semiHidden/>
        <w:unhideWhenUsed/>
      </w:style>
      <w:style w:type="paragraph" w:styleId="BalloonText">
        <w:name w:val="Balloon Text"/>
        <w:basedOn w:val="Normal"/>
        <w:link w:val="BalloonTextChar"/>
        <w:uiPriority w:val="99"/>
        <w:semiHidden/>
        <w:unhideWhenUsed/>
        <w:rsid w:val="00B43521"/>
        <w:pPr>
          <w:spacing w:after="0" w:line="240" w:lineRule="auto"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:ascii="Tahoma" w:hAnsi="Tahoma" w:cs="Tahoma"/>
          <w:sz w:val="16"/>
          <w:szCs w:val="16"/>
        </w:rPr>
      </w:style>
      <w:style w:type="character" w:customStyle="1" w:styleId="BalloonTextChar">
        <w:name w:val="Balloon Text Char"/>
        <w:basedOn w:val="DefaultParagraphFont"/>
        <w:link w:val="BalloonText"/>
        <w:uiPriority w:val="99"/>
        <w:semiHidden/>
        <w:rsid w:val="00B43521"/>
        <w:rPr>
          <w:rFonts w:ascii="Tahoma" w:hAnsi="Tahoma" w:cs="Tahoma"/>
          <w:sz w:val="16"/>
          <w:szCs w:val="16"/>
        </w:rPr>
      </w:style>
      <w:style w:type="table" w:styleId="TableGrid">
        <w:name w:val="Table Grid"/>
        <w:basedOn w:val="TableNormal"/>
        <w:uiPriority w:val="59"/>
        <w:rsid w:val="002646F3"/>
        <w:pPr>
          <w:spacing w:after="0" w:line="240" w:lineRule="auto"/>
        </w:pPr>
        <w:tblPr>
          <w:tblInd w:w="0" w:type="dxa"/>
          <w:tblBorders>
            <w:top w:val="single" w:sz="4" w:space="0" w:color="auto"/>
            <w:left w:val="single" w:sz="4" w:space="0" w:color="auto"/>
            <w:bottom w:val="single" w:sz="4" w:space="0" w:color="auto"/>
            <w:right w:val="single" w:sz="4" w:space="0" w:color="auto"/>
            <w:insideH w:val="single" w:sz="4" w:space="0" w:color="auto"/>
            <w:insideV w:val="single" w:sz="4" w:space="0" w:color="auto"/>
          </w:tblBorders>
          <w:tblCellMar>
            <w:top w:w="0" w:type="dxa"/>
            <w:left w:w="108" w:type="dxa"/>
            <w:bottom w:w="0" w:type="dxa"/>
            <w:right w:w="108" w:type="dxa"/>
          </w:tblCellMar>
        </w:tblPr>
      </w:style>
      <w:style w:type="paragraph" w:customStyle="1" w:styleId="ProjectDetails">
        <w:name w:val="Project Details"/>
        <w:basedOn w:val="Normal"/>
        <w:link w:val="ProjectDetailsChar"/>
        <w:qFormat/>
        <w:rsid w:val="002646F3"/>
        <w:pPr>
          <w:ind w:left="3969"/>
        </w:pPr>
      </w:style>
      <w:style w:type="paragraph" w:customStyle="1" w:styleId="ProjectTitle">
        <w:name w:val="Project Title"/>
        <w:basedOn w:val="Normal"/>
        <w:link w:val="ProjectTitleChar"/>
        <w:qFormat/>
        <w:rsid w:val="002646F3"/>
        <w:pPr>
          <w:ind w:left="3969"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts>
            <xsl:attribute name="w:cs"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
          </w:rFonts>
          <w:b/>
          <w:noProof/>
          <w:sz>
            <xsl:attribute name="w:val"><xsl:value-of select="3 * format/font_size"/></xsl:attribute>
          </w:sz>
          <w:szCs>
            <xsl:attribute name="w:val"><xsl:value-of select="3 * format/font_size"/></xsl:attribute>
          </w:szCs>
          <w:lang w:eastAsia="en-GB"/>
        </w:rPr>
      </w:style>
      <w:style w:type="character" w:customStyle="1" w:styleId="ProjectDetailsChar">
        <w:name w:val="Project Details Char"/>
        <w:basedOn w:val="DefaultParagraphFont"/>
        <w:link w:val="ProjectDetails"/>
        <w:rsid w:val="002646F3"/>
        <w:rPr>
          <w:rFonts>
            <xsl:attribute name="w:ascii"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
            <xsl:attribute name="w:hAnsi"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
          </w:rFonts>
          <w:sz>
            <xsl:attribute name="w:val"><xsl:value-of select="2 * format/font_size"/></xsl:attribute>
          </w:sz>
        </w:rPr>
      </w:style>
      <w:style w:type="paragraph" w:styleId="Header">
        <w:name w:val="header"/>
        <w:basedOn w:val="Normal"/>
        <w:link w:val="HeaderChar"/>
        <w:uiPriority w:val="99"/>
        <w:unhideWhenUsed/>
        <w:rsid w:val="00603D2B"/>
        <w:pPr>
          <w:tabs>
            <w:tab w:val="center" w:pos="4513"/>
            <w:tab w:val="right" w:pos="9026"/>
          </w:tabs>
          <w:spacing w:after="0" w:line="240" w:lineRule="auto"/>
        </w:pPr>
      </w:style>
      <w:style w:type="character" w:customStyle="1" w:styleId="ProjectTitleChar">
        <w:name w:val="Project Title Char"/>
        <w:basedOn w:val="DefaultParagraphFont"/>
        <w:link w:val="ProjectTitle"/>
        <w:rsid w:val="002646F3"/>
        <w:rPr>
          <w:rFonts>
            <xsl:attribute name="w:ascii"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
            <xsl:attribute name="w:hAnsi"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
            <xsl:attribute name="w:cs"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
          </w:rFonts>
          <w:b/>
          <w:noProof/>
          <w:sz>
            <xsl:attribute name="w:val"><xsl:value-of select="3 * format/font_size"/></xsl:attribute>
          </w:sz>
          <w:szCs>
            <xsl:attribute name="w:val"><xsl:value-of select="3 * format/font_size"/></xsl:attribute>
          </w:szCs>
          <w:lang w:eastAsia="en-GB"/>
        </w:rPr>
      </w:style>
      <w:style w:type="character" w:customStyle="1" w:styleId="HeaderChar">
        <w:name w:val="Header Char"/>
        <w:basedOn w:val="DefaultParagraphFont"/>
        <w:link w:val="Header"/>
        <w:uiPriority w:val="99"/>
        <w:rsid w:val="00603D2B"/>
        <w:rPr>
          <w:rFonts>
            <xsl:attribute name="w:ascii"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
            <xsl:attribute name="w:hAnsi"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
          </w:rFonts>
          <w:sz>
            <xsl:attribute name="w:val"><xsl:value-of select="2 * format/font_size"/></xsl:attribute>
          </w:sz>
        </w:rPr>
      </w:style>
      <w:style w:type="paragraph" w:styleId="Footer">
        <w:name w:val="footer"/>
        <w:basedOn w:val="Normal"/>
        <w:link w:val="FooterChar"/>
        <w:uiPriority w:val="99"/>
        <w:unhideWhenUsed/>
        <w:rsid w:val="00603D2B"/>
        <w:pPr>
          <w:tabs>
            <w:tab w:val="center" w:pos="4513"/>
            <w:tab w:val="right" w:pos="9026"/>
          </w:tabs>
          <w:spacing w:after="0" w:line="240" w:lineRule="auto"/>
        </w:pPr>
      </w:style>
      <w:style w:type="character" w:customStyle="1" w:styleId="FooterChar">
        <w:name w:val="Footer Char"/>
        <w:basedOn w:val="DefaultParagraphFont"/>
        <w:link w:val="Footer"/>
        <w:uiPriority w:val="99"/>
        <w:rsid w:val="00603D2B"/>
        <w:rPr>
          <w:rFonts>
            <xsl:attribute name="w:ascii"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
            <xsl:attribute name="w:hAnsi"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
          </w:rFonts>
          <w:sz>
            <xsl:attribute name="w:val"><xsl:value-of select="2 * format/font_size"/></xsl:attribute>
          </w:sz>
        </w:rPr>
      </w:style>
      <w:style w:type="paragraph" w:customStyle="1" w:styleId="HeaderEven">
        <w:name w:val="Header Even"/>
        <w:basedOn w:val="NoSpacing"/>
        <w:qFormat/>
        <w:rsid w:val="00603D2B"/>
        <w:pPr>
          <w:pBdr>
            <w:bottom w:val="single" w:sz="4" w:space="1" w:color="4F81BD" w:themeColor="accent1"/>
          </w:pBdr>
        </w:pPr>
        <w:rPr>
          <w:rFonts w:asciiTheme="minorHAnsi" w:hAnsiTheme="minorHAnsi">
            <xsl:attribute name="w:cs"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
          </w:rFonts>
          <w:b/>
          <w:color w:val="1F497D" w:themeColor="text2"/>
          <w:sz w:val="20"/>
          <w:szCs w:val="20"/>
          <w:lang w:val="en-US" w:eastAsia="ja-JP"/>
        </w:rPr>
      </w:style>
      <w:style w:type="paragraph" w:styleId="NoSpacing">
        <w:name w:val="No Spacing"/>
        <w:uiPriority w:val="1"/>
        <w:qFormat/>
        <w:rsid w:val="00603D2B"/>
        <w:pPr>
          <w:spacing w:after="0" w:line="240" w:lineRule="auto"/>
        </w:pPr>
        <w:rPr>
          <w:rFonts>
            <xsl:attribute name="w:ascii"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
            <xsl:attribute name="w:hAnsi"><xsl:choose>
              <xsl:when test="format/font_face = 'serif'">Times New Roman</xsl:when>
              <xsl:otherwise>Arial</xsl:otherwise>
            </xsl:choose></xsl:attribute>
          </w:rFonts>
          <w:sz>
            <xsl:attribute name="w:val"><xsl:value-of select="2 * format/font_size"/></xsl:attribute>
          </w:sz>
        </w:rPr>
      </w:style>
    </w:styles>
  </xsl:template>
</xsl:stylesheet>