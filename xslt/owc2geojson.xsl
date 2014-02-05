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
      	xmlns:gml="http://www.opengis.net/gml"
      	xmlns:exsl="http://exslt.org/common"
>

<xsl:import href="atom2json.xsl"/>
<xsl:include href="xml-to-string.xsl"/>
<xsl:output method="text" indent="yes"/>

<!-- ************************************** -->
<!-- GeoRSS to GeoJson transformation block -->
<xsl:template name="gml2coord">
	<xsl:param name="string" select="."/>
	<xsl:variable name="other" select="substring-after(substring-after($string,' '),' ')"/>
	<xsl:variable name="point"><xsl:choose>
	<xsl:when test="$other!=''"><xsl:value-of select="substring-before(substring-after($string,' '),' ')"/>,<xsl:value-of select="substring-before($string,' ')"/></xsl:when>
	<xsl:otherwise><xsl:value-of select="substring-after($string,' ')"/>,<xsl:value-of select="substring-before($string,' ')"/></xsl:otherwise>	
	</xsl:choose></xsl:variable>[<xsl:value-of select="$point"/>]<xsl:if test="$other!=''">,<xsl:call-template name="gml2coord"><xsl:with-param name="string" select="$other"/></xsl:call-template></xsl:if></xsl:template>

<xsl:template match="gml:Point | georss:point">
              "type" : "Point",
              "coordinates" : [[<xsl:call-template name="gml2coord"><xsl:with-param name="string" select="."/></xsl:call-template>]]</xsl:template>  

<xsl:template match="gml:LineString | georss:Line">
              "type" : "LineString",
              "coordinates" : [[<xsl:call-template name="gml2coord"><xsl:with-param name="string" select="."/></xsl:call-template>]]</xsl:template>  

<xsl:template match="gml:Polygon | georss:polygon">"type" : "Polygon",
	       "coordinates" : [[<xsl:call-template name="gml2coord">
		   <xsl:with-param name="string" select="."/></xsl:call-template>]]</xsl:template>  

<xsl:template match="gml:Envelope">
<xsl:variable name="x1" select="substring-after(gml:lowerCorner,' ')"/><xsl:variable name="x2" select="substring-after(gml:upperCorner,' ')"/>
<xsl:variable name="y1" select="substring-before(gml:lowerCorner,' ')"/><xsl:variable name="y2" select="substring-before(gml:upperCorner,' ')"/>
              "type":"Polygon",
              "coordinates":[[<xsl:value-of select="concat ('[', $x1, ',', $y1,']')"/>,<xsl:value-of select="concat ('[', $x1, ',', $y2,']')"/>,<xsl:value-of select="concat ('[', $x2, ',', $y2,']')"/>,<xsl:value-of select="concat ('[', $x2, ',', $y1,']')"/>,<xsl:value-of select="concat ('[', $x1, ',', $y1,']')"/>]]</xsl:template>   
	    						
<xsl:template match="georss:box">
<xsl:variable name="x1" select="substring-before(substring-after(.,' '),' ')"/><xsl:variable name="x2" select="substring-after(substring-after(substring-after(.,' '),' '),' ')"/>
<xsl:variable name="y1" select="substring-before(.,' ')"/><xsl:variable name="y2" select="substring-before(substring-after(substring-after(.,' '),' '),' ')"/>
              "type" : "Polygon",	    	
              "coordinates" : [[ <xsl:value-of select="concat ('[', $x1, ',', $y1,']')"/>,<xsl:value-of select="concat ('[', $x1, ',', $y2,']')"/>,<xsl:value-of select="concat ('[', $x2, ',', $y2,']')"/>,<xsl:value-of select="concat ('[', $x2, ',', $y1,']')"/>,<xsl:value-of select="concat ('[', $x1, ',', $y1,']')"/>]]</xsl:template>   
  
<xsl:template match="georss:where">        
	<xsl:apply-templates select="*"/>
</xsl:template>  
<!-- GeoRSS to GeoJson transformation block -->
<!-- ************************************** -->



<xsl:template match="atom:feed">
<xsl:value-of select="concat($new-line,$tab)"/>"type": "FeatureCollection",
<xsl:value-of select="concat($tab,'')"/>"geometry": {<xsl:apply-templates select="georss:*[1]"/>},
<xsl:value-of select="concat($tab,'')"/>"properties" : {
<xsl:value-of select="concat($tab,$tab)"/><xsl:apply-templates select="." mode="atomCommonAttributes"/>	
<xsl:for-each select="atom:*[name()!='author' and name()!='category' and name()!='contributor' and name()!='link' and name()!='entry']">
<xsl:value-of select="concat($new-line,$tab,$tab)"/><xsl:apply-templates select="."/>,<xsl:if test="position() &lt; last()"><xsl:value-of select="''"/></xsl:if></xsl:for-each>
<xsl:value-of select="concat($new-line,$tab,$tab)"/>"authors" : [<xsl:for-each select="atom:author">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>],
<xsl:value-of select="concat($tab,$tab)"/>"categories" : [<xsl:for-each select="atom:category">{<xsl:value-of select="concat($new-line,$tab,$tab,$tab)"/><xsl:apply-templates select="."/><xsl:value-of select="concat($new-line,$tab,$tab,$tab)"/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>],
<xsl:value-of select="concat($tab,$tab)"/>"contributors" : [<xsl:for-each select="atom:contributor">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>],
<xsl:value-of select="concat($tab,$tab)"/>"links" : [<xsl:for-each select="atom:link">{<xsl:for-each select="@*"><xsl:value-of select="concat($new-line,$tab,$tab,$tab)"/><xsl:apply-templates select="."/><xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>
<xsl:value-of select="concat($new-line,$tab,$tab,$tab)"/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>]
<xsl:value-of select="concat($tab,$tab)"/>},
<xsl:value-of select="concat($tab,'')"/> "features" : [<xsl:for-each select="atom:entry">{<xsl:apply-templates select="."/><xsl:value-of select="concat($tab,$tab)"/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>]
</xsl:template>
    
<xsl:template match="atom:entry">
<xsl:value-of select="concat($new-line,$tab,$tab)"/>"type": "Feature",
<xsl:value-of select="concat($tab,$tab)"/>"geometry": {<xsl:apply-templates select="(georss:*|../georss:*)[last()]"/>},
<xsl:value-of select="concat($tab,$tab)"/>"properties": {<xsl:apply-imports/>,
<xsl:value-of select="concat($tab,$tab,$tab)"/>"offerings" : [<xsl:for-each select="owc:offering">{
            <xsl:apply-templates select="."/>
<xsl:value-of select="concat($new-line,$tab,$tab,$tab,$tab)"/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>]
             }
 </xsl:template>

<xsl:template match="owc:offering">
<xsl:for-each select="@*">
<xsl:value-of select="concat($tab,'')"/><xsl:apply-templates select="."/>,</xsl:for-each>
<xsl:value-of select="concat($new-line,$tab,$tab,$tab,$tab)"/>"operations" : [<xsl:for-each select="owc:operation">{<xsl:value-of select="concat($tab,$tab,$tab,$tab)"/><xsl:apply-templates select="."/><xsl:value-of select="concat($new-line,$tab,$tab,$tab,$tab,$tab)"/>}<xsl:if test="position() &lt; last()">,</xsl:if></xsl:for-each>],
<xsl:value-of select="concat($tab,$tab,$tab,$tab)"/>"contents" : [<xsl:for-each select="owc:content">{<xsl:apply-templates select="."/>}<xsl:if test="position() &lt; last()">,<xsl:value-of select="concat($new-line,$tab,$tab,$tab,$tab)"/></xsl:if></xsl:for-each>]</xsl:template>

<xsl:template match="owc:operation"><xsl:for-each select="@*">
<xsl:value-of select="concat($new-line,$tab,$tab,$tab,$tab,$tab)"/><xsl:apply-templates select="."/>,</xsl:for-each>
<xsl:value-of select="concat($new-line,$tab,$tab,$tab,$tab,$tab)"/>"request":{<xsl:apply-templates select="owc:request"/>},
<xsl:value-of select="concat($tab,$tab,$tab,$tab,$tab)"/>"result":{<xsl:apply-templates select="owc:result"/>}</xsl:template>

<xsl:template match="owc:request | owc:result ">
<xsl:for-each select="@*">
<xsl:value-of select="concat($new-line,$tab,$tab,$tab,$tab,$tab,$tab)"/><xsl:apply-templates select="."/>,</xsl:for-each>
<xsl:variable name="myNode" select="*[1]"/>
<xsl:variable name="nodeAsStr"><xsl:call-template name="safestring">
<xsl:with-param name="val"><xsl:apply-templates select="$myNode" mode="xml-to-string"/></xsl:with-param>
</xsl:call-template>
</xsl:variable>
<xsl:value-of select="concat($new-line,$tab,$tab,$tab,$tab,$tab,$tab)"/>"content" : "<xsl:value-of select="$nodeAsStr"/>"</xsl:template>

<xsl:template match="owc:content">
<xsl:for-each select="@*">
<xsl:value-of select="concat($new-line,$tab,$tab,$tab,$tab,$tab)"/><xsl:apply-templates select="."/>,</xsl:for-each>
<xsl:variable name="myNode" select="*[1]"/>
<xsl:variable name="nodeAsStr"><xsl:call-template name="safestring">
<xsl:with-param name="val"><xsl:apply-templates select="$myNode" mode="xml-to-string"/></xsl:with-param>
</xsl:call-template>
</xsl:variable>
<xsl:value-of select="concat($new-line,$tab,$tab,$tab,$tab,$tab)"/>"content" : "<xsl:value-of select="$nodeAsStr"/>"</xsl:template>

</xsl:stylesheet>
