<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:json="http://json.org/" >
    <xsl:output indent="no" omit-xml-declaration="yes" method="text" encoding="UTF-8" media-type="text/x-json"/>
    <xsl:strip-space elements="*"/>

    <json:search name="string">
        <json:replace src="\" dst="\\"/>
        <json:replace src="&quot;" dst="\&quot;"/>
        <json:replace src="&#xA;" dst="\n"/>
        <json:replace src="&#xD;" dst="\r"/>
        <json:replace src="&#x9;" dst="\t"/>
        <json:replace src="\n" dst="\n"/>
        <json:replace src="\r" dst="\r"/>
        <json:replace src="\t" dst="\t"/>
    </json:search>

    <xsl:template name="replace-string">
        <xsl:param name="input"/>
        <xsl:param name="src"/>
        <xsl:param name="dst"/>
    
        <xsl:choose>
            <xsl:when test="contains($input, $src)">
                <xsl:value-of select="concat(substring-before($input, $src), $dst)"/>
                <xsl:call-template name="replace-string">
                    <xsl:with-param name="input" select="substring-after($input, $src)"/>
                    <xsl:with-param name="src" select="$src"/>
                    <xsl:with-param name="dst" select="$dst"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="encode">
        <xsl:param name="input"/>
        <xsl:param name="index">1</xsl:param>
        <xsl:variable name="text">
            <xsl:call-template name="replace-string">
                <xsl:with-param name="input" select="$input"/>
                <xsl:with-param name="src" select="document('')//json:search/json:replace[$index]/@src"/>
                <xsl:with-param name="dst" select="document('')//json:search/json:replace[$index]/@dst"/>
            </xsl:call-template>
           
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$index &lt; count(document('')//json:search/json:replace)">
                <xsl:call-template name="encode">
                    <xsl:with-param name="input" select="$text"/>
                    <xsl:with-param name="index" select="$index + 1"/>
                </xsl:call-template>

            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="device|tuner|sourcetype|ts">
        <xsl:if test="position() = 1">"<xsl:value-of select="name()"/>":[</xsl:if>
        <xsl:text>{</xsl:text>
            <xsl:text>"id":</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:if test="@name">
                <xsl:text>,"name":"</xsl:text>
                <!-- <xsl:value-of select="@name"/> -->
                <!-- <xsl:value-of select="count(document('')//json:search/json:replace)"/> -->
                
              <!--   <xsl:if test="function-available('count')">
                    -YES
                </xsl:if> -->
                
                <xsl:call-template name="encode">
                    <xsl:with-param name="input" select="@name"/>
                </xsl:call-template>
                <xsl:text>"</xsl:text>
            </xsl:if>
            <xsl:if test="@version">,"version":<xsl:value-of select="@version"/></xsl:if>
            <xsl:if test="@enable">,"enable":<xsl:value-of select="@enable"/></xsl:if>
            <xsl:if test="@port">,"port":<xsl:value-of select="@port"/></xsl:if>
            <xsl:if test="node()">
                <xsl:text>,</xsl:text>
                <xsl:apply-templates select="node()"/>
            </xsl:if>
        <xsl:text>}</xsl:text>
        <xsl:choose>
            <xsl:when test="position() = last()">]</xsl:when>
            <xsl:otherwise>,</xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="result|progress">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="name()"/>
        <xsl:text>":</xsl:text>
        <xsl:choose>
            <xsl:when test="number(text()) = text()"><xsl:value-of select="text()"/></xsl:when>
            <xsl:otherwise>"<xsl:value-of select="text()"/>"</xsl:otherwise>
        </xsl:choose>
        <xsl:if test="following-sibling::*">,</xsl:if>
    </xsl:template>

    <xsl:template match="snugcaster|BackupTask">
        <xsl:text>{</xsl:text>
            <xsl:if test="result">
                <xsl:apply-templates select="result"/>
            </xsl:if>

            <xsl:if test="device">
                <xsl:apply-templates select="device"/>
            </xsl:if>
            <xsl:if test="list">
                <xsl:apply-templates select="list/device"/>
            </xsl:if>
        <xsl:text>}</xsl:text>
    </xsl:template>

</xsl:stylesheet>