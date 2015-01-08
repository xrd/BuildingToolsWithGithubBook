<xsl:stylesheet version="1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:h="http://www.w3.org/1999/xhtml"
		xmlns="http://www.w3.org/1999/xhtml"
		exclude-result-prefixes="h">

<xsl:template match="h:img/@src">
  <xsl:choose>
  <xsl:when test="starts-with(., 'callouts/')">
     <xsl:attribute name="src">
     	<xsl:value-of select="translate(., 'png', 'pdf')"/>
     </xsl:attribute>
  </xsl:when>
  <xsl:otherwise>
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
   </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>