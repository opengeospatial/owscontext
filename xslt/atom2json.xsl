<?xml version="1.0" encoding="UTF-8" ?>
<!--
/*	     
 *    Copyright 2011-2013 Terradue srl
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *       http://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
-->

<!-- DEVELOPMENT VERSION try with care -->

<xsl:stylesheet version="1.0" 
		xmlns="http://www.w3.org/1999/xhtml" 
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:atom="http://www.w3.org/2005/Atom" 
      	xmlns:dc="http://purl.org/dc/elements/1.1/" 
      	xmlns:georss="http://www.georss.org/georss" 
      	xmlns:xlink="http://www.w3.org/1999/xlink"
      	xmlns:owc="http://www.opengis.net/owc/1.0" 
>
<xsl:output method="text" indent="yes"/>
<xsl:variable name="new-line" select="'&#10;'"/>
<xsl:variable name="tab" select="'    '"/>
<xsl:variable name="quotation" select="'&quot;'"/>
<xsl:variable name="apostrophe" select="''"/>

<xsl:strip-space elements="*"/>

<xsl:template match="/">{<xsl:apply-templates select="atom:feed"/>}</xsl:template>

<xsl:template match="atom:feed">
<xsl:apply-templates select="." mode="atomCommonAttributes"/>	
	<xsl:for-each select="atom:*[name()!='author' and name()!='category' and name()!='contributor' and name()!='link' and name()!='entry']"><xsl:apply-templates select="."/>,<xsl:if test="position() &lt; last()"><xsl:value-of select="concat($new-line,$tab)"/></xsl:if></xsl:for-each>
	"authors" : [<xsl:for-each select="atom:author">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>],
	"categories" : [<xsl:for-each select="atom:category">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>],
	"contributors" : [<xsl:for-each select="atom:contributor">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>],
	"links" : [<xsl:for-each select="atom:link">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>],
	"entries" : [<xsl:for-each select="atom:entry">{<xsl:apply-templates select="."/><xsl:value-of select="concat($tab,$tab)"/>}<xsl:if test="position() &lt; last()">,</xsl:if><xsl:value-of select="concat($new-line,$tab,$tab)"/></xsl:for-each>]
</xsl:template>

<xsl:template match="atom:*" mode="atomCommonAttributes"><xsl:apply-templates select="@xml:base | @xml:lang"/>
</xsl:template>

<xsl:template match="@* | atom:* " >"<xsl:value-of select="name(.)"/>" : "<xsl:call-template name="safestring"><xsl:with-param name="val" select="."/></xsl:call-template>"</xsl:template>

<xsl:template match="@xml:*">"<xsl:value-of select="local-name(.)"/>" : "<xsl:value-of select="."  />",</xsl:template>

<xsl:template match="atom:author | atom:category | atom:contributor | atom:link ">
<xsl:for-each select="@* | atom:*"><xsl:apply-templates select="."/><xsl:if test="position() &lt; last()">,<xsl:value-of select="concat($new-line,$tab,$tab,$tab)"/><xsl:if test="name(../..)='entry'"><xsl:value-of select="$tab"/></xsl:if></xsl:if></xsl:for-each></xsl:template>

<xsl:template match="atom:entry">
<xsl:for-each select="atom:*[name()!='author' and name()!='category' and name()!='contributor' and name()!='link']"><xsl:value-of select="concat($new-line,$tab,$tab,$tab)"/><xsl:apply-templates select="."/>,<xsl:if test="position() &lt; last()"><xsl:value-of select="''"/></xsl:if></xsl:for-each>
<xsl:value-of select="concat($new-line,$tab,$tab,$tab)"/>"categories" : [<xsl:for-each select="atom:categories">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>],
<xsl:value-of select="concat($tab,$tab,$tab)"/>"links" : [<xsl:for-each select="atom:link">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>]</xsl:template>


<xsl:template name="safestring">
	<xsl:param name="val" select="''"/>
	<xsl:call-template name="remove-quote">
		<xsl:with-param name="val"><xsl:call-template name="string-replace-all"><xsl:with-param name="text" select="$val"/><xsl:with-param name="replace" select="'\'"/><xsl:with-param name="by" select="'\\'"/></xsl:call-template></xsl:with-param>
	</xsl:call-template>
</xsl:template>


<xsl:template name="remove-quote">
	<xsl:param name="val" select="''"/>
	<xsl:call-template name="return-value">
		<xsl:with-param name="val"><xsl:call-template name="string-replace-all"><xsl:with-param name="text" select="$val"/><xsl:with-param name="replace" select="'&quot;'"/><xsl:with-param name="by" select="'\&quot;'"/></xsl:call-template></xsl:with-param>
	</xsl:call-template>
</xsl:template>

<xsl:template name="return-value">
	<xsl:param name="val" select="''"/>
	<xsl:value-of select="normalize-space($val)"/>
</xsl:template>

<xsl:template name="string-replace-all">
  <xsl:param name="text"/>
  <xsl:param name="replace"/>
  <xsl:param name="by"/>
  <xsl:choose>
    <xsl:when test="contains($text,$replace)">
      <xsl:value-of select="substring-before($text,$replace)"/>
      <xsl:value-of select="$by"/>
      <xsl:call-template name="string-replace-all">
        <xsl:with-param name="text" select="substring-after($text,$replace)"/>
        <xsl:with-param name="replace" select="$replace"/>
        <xsl:with-param name="by" select="$by"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>


</xsl:stylesheet>
