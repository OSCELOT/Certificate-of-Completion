<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@	page language="java"
		 import="java.io.PrintWriter"
		 pageEncoding="UTF-8"
		 contentType="text/html"
		 isErrorPage="true"
%>
<%@ taglib prefix="bbNG" uri="/bbNG"%>

<%
	String strException = exception.getMessage();
%>
<bbNG:receipt type="FAIL" title="Error">
<%=strException%>
<pre>
<%
	// now display a stack trace of the exception
 	PrintWriter pw = new PrintWriter( out );
  	exception.printStackTrace( pw );
%>
</pre>
</bbNG:receipt>