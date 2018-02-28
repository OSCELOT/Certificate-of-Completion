<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@ page language="java"
	import="blackboard.persist.*,
			blackboard.persist.content.ContentDbLoader,
			blackboard.persist.content.ContentFileDbLoader,
			blackboard.data.content.*,
			blackboard.data.ExtendedData,
			blackboard.platform.persistence.PersistenceServiceFactory,
			java.util.List"
	contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"
	errorPage="/error.jsp"
%>
<%@ taglib prefix="bbNG" uri="/bbNG"%>


<%
/* learningSystemPage - what users see in the LMS */
%>

<bbNG:learningSystemPage ctxId="ctx">

<%
	// get content item details and save them to session variables for retrieval by certificate.jsp

	BbPersistenceManager bbPm = PersistenceServiceFactory.getInstance().getDbPersistenceManager();
	Container bbContainer = bbPm.getContainer();
	
	Id contentId = new PkId( bbContainer, CourseDocument.DATA_TYPE, request.getParameter("content_id") );
	
	ContentDbLoader courseDocumentLoader = (ContentDbLoader) bbPm.getLoader( ContentDbLoader.TYPE );
	Content contentItem = courseDocumentLoader.loadById( contentId );
	
	String certificateName = contentItem.getTitle();
	   	
	// get attached files - based on http://forums.edugarage.com/forums/p/3296/9785.aspx#9785
	// note that contentItem.getContentFiles() could be used to achieve the same thing IF the Content object was "heavy" loaded (using one of the methods in ContentDbLoader that take a boolean "heavy" argument) as per http://forums.edugarage.com/forums/t/3455.aspx . If it is not "heavy" loaded, it will return empty, but the following can be used in place of this.
	List<ContentFile> fileList;
	
	ContentFileDbLoader cfLoader = ContentFileDbLoader.Default.getInstance();//(ContentFileDbLoader)BbServiceManager.getPersistenceService().getDbPersistenceManager().getLoader(ContentFileDbLoader.TYPE);   
	
	fileList = cfLoader.loadByContentId(contentId);
	
	// There should only be one file attached so get the first ContentFile from the fileList and use it as the certificate template
	ContentFile certificateFile = fileList.get(0);
		
	// get custom saved data
	ExtendedData attrs = contentItem.getExtendedData();
	String dateDisplayFormat = attrs.getValue("dateDisplayFormat");
	
	session.setAttribute("certificateName", certificateName);
	session.setAttribute("dateDisplayFormat", dateDisplayFormat);
	
	// use certificateFile.getName() (i.e. ContentFile.getName) to get the XID
	// see http://library.blackboard.com/ref/02948bcf-b38c-48c5-aeec-af41622de82e/blackboard/data/content/ContentFile.html
	session.setAttribute("certificateXID", certificateFile.getName());
%>

	<bbNG:cssBlock>
	  <link rel="stylesheet" href="styles/print.css" type="text/css" media="print" />   
	</bbNG:cssBlock>

    <bbNG:pageHeader instructions="Print your certificate">
        <bbNG:breadcrumbBar environment="COURSE" isContent="true"></bbNG:breadcrumbBar>
        <bbNG:pageTitleBar><% out.print(certificateName); %></bbNG:pageTitleBar>
    </bbNG:pageHeader>
	
	<div id="certificate" style="margin-bottom: 10px;">
		<img src="certificate.jsp"/>
	</div>
	
	<bbNG:button label="Print" onClick="window.print();"/>
	<p id="printnote" style="margin-top: 5px;">Note: If printing does not work for you, please right-click the certificate and choose "Save image as" and save the certificate image to your computer. You may then print this saved image file.</p>
	<bbNG:okButton />

</bbNG:learningSystemPage>

