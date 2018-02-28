<%@ page language="java" 
	import="java.util.*,
	blackboard.platform.plugin.PlugInConfig,
	blackboard.platform.plugin.PlugInUtil,
	java.io.*,
	blackboard.persist.navigation.NavigationItemDbLoader,
	blackboard.data.navigation.NavigationItem"
	contentType="text/html; charset=UTF-8" 
	pageEncoding="UTF-8"
%>

<%
/* Note: This file is not presently used. Potentially, it could contain System Admin options for uploading a custom certificate template file, but for now, these are just static */


if (PlugInUtil.authorizeForSystemAdmin(request, response) == false) {
	return;
}
%>


<%@ taglib prefix="bbNG" uri="/bbNG"%>
<%
/* genericPage - what users see in the LMS */
%>


	<bbNG:genericPage entitlement="system.admin.VIEW" title="Configure Certificate of Completion Tool" ctxId="ctx">
	    <bbNG:pageHeader>
	     <bbNG:breadcrumbBar environment="SYS_ADMIN_PANEL">
	        <bbNG:breadcrumb>Configure Certificate of Completion Tool</bbNG:breadcrumb>
	    </bbNG:breadcrumbBar>
	    <bbNG:pageTitleBar title="Configure Certificate of Completion Tool"></bbNG:pageTitleBar>
	    </bbNG:pageHeader>
	    
	    <!--  start of page content -->
	   	
	   	<!-- This form needs to allow the generic certificate template image to be updated AND show a list of existing certificates for modification or deletion -->
	   	
	    <bbNG:form action="create.jsp" onsubmit="return validateForm();">
	    	<bbNG:dataCollection markUnsavedChanges="true">
		    	<bbNG:step title="Step 1">
		    	
		    		<bbNG:dataElement label="Certificate Name">
		    			<input name="certificate_name" type="text" />
		    		</bbNG:dataElement>
		    				    		
		    	</bbNG:step>
		    	<bbNG:stepSubmit instructions="Enter data then press submit."></bbNG:stepSubmit>
	    	</bbNG:dataCollection>
	    </bbNG:form>
	    
	    
	    <!--  end of page content -->
	</bbNG:genericPage>
