<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:h="http://www.w3.org/1999/xhtml"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="h">

  <!-- Do add border div for figure images in animal series -->
  <xsl:param name="figure.border.div" select="1"/>
  
  <!-- Drop @width attributes from table headers if present -->
  <xsl:template match="h:th/@width"/>

  <!-- Drop @width attributes from images if present -->
  <xsl:template match="h:img/@width"/>

</xsl:stylesheet>
