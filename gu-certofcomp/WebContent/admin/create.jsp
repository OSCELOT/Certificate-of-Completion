<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">

<%@	page language="java"
	import="java.util.*,
		blackboard.data.ExtendedData,
		blackboard.data.content.*,
		blackboard.data.course.*,
		blackboard.persist.*,
		blackboard.persist.content.*,
		blackboard.platform.plugin.*,
		blackboard.platform.persistence.PersistenceServiceFactory,
		java.io.*,
		blackboard.servlet.data.ngui.FilePickerFile,
		blackboard.platform.contentsystem.data.*,
		blackboard.platform.contentsystem.service.ContentSystemServiceExFactory,
		blackboard.servlet.helper.FilePickerRequestHelper"
	pageEncoding="UTF-8" 
	contentType="text/html"
	errorPage="/error.jsp"
%>

<%@ taglib uri="/bbNG" prefix="bbNG"%>

<bbNG:genericPage title="Add/Modify Certificate" ctxId="ctx">
	<%
		
		// this class is from http://forums.edugarage.com/forums/p/3454/10145.aspx and includes the basic necessities of the FilePickerFile class
		class ContentFilePicker implements FilePickerFile {
			private final ContentFile cf;
			private final Resource resource; 
			
			public ContentFilePicker(ContentFile cf) {
				this.cf = cf;
				this.resource = ContentSystemServiceExFactory.getInstance().getDocumentManagerEx().getDocument(cf.getName());
			}
			
			@Override public String getName() {
				return resource.getBaseName();
				// probably better than cf.getName()
			}
			
			@Override public String getId() {
				return resource.getPermanentId();
			}
			
			@Override public String getUrl() {
				return resource.getPermanentURL();
				// or maybe getViewURL?
			}
			
			@Override public String getType() {
				return resource.getType().name();
			 	// or maybe: return BundleManagerFactory.getInstance().getBundle("ng_tags").getString("filePicker.fileType.content");
			}
			
			@Override public StorageLocation getStorageLocation() {
				return FilePickerFile.StorageLocation.CONTENT_SYSTEM;
			}
			
			@Override public String getLinkTitle() {
				return cf.getLinkName();
			}
			
			@Override public String getSize() {
				return String.valueOf(cf.getSize());
			}
			
			@Override public FilePickerRequestHelper.SpecialAction getSpecialAction() {
				return FilePickerRequestHelper.SpecialAction.LINK;
			}
									
			@Override public Map<String, String> getCustomColumns() {
				return Collections.emptyMap();
			}
		}
		// apart from this, there is vague documentation on filePicker and filePickerListElement at:
		// http://library.blackboard.com/ref/b9696cc1-1d49-45f3-b8af-ce709f71b915/bbNG/tld-summary.html
		// http://library.blackboard.com/ref/b9696cc1-1d49-45f3-b8af-ce709f71b915/bbNG/filePicker.html
	
		if (!PlugInUtil.authorizeForCourseControlPanel(request,response)) {
			return;
		}
	
		String thisPluginUriStem = PlugInUtil.getUriStem("gu", "certofcomp");
		String thisPluginImageUrlPath = thisPluginUriStem + "images/certofcomp.gif";
		String certificateTemplatePath = thisPluginUriStem + "images/certificate_template.png";
		String certificateExamplePath = thisPluginUriStem + "images/certificate_example.png";
		String certificateDimensionsPath = thisPluginUriStem + "images/certificate_dimensions.png";
		String certificateDesignInstructions = "<img src='"+certificateDimensionsPath+"' style='float: right;' />Please upload your certificate design as an image file (JPEG, GIF or PNG), ensuring it conforms to the settings in the dimensions of <strong>700 pixels wide</strong> by <strong>990 pixels high</strong>, with spaces provided for printing the <strong>Student/Participant's Name</strong>, <strong>Student/Participant's User <abbr title='identifier'>ID</abbr></strong> and <strong>Current Date or Year</strong>.<br /><p>Additionally, you may choose to optionally allow spaces for the Student/Participant and/or the Supervisor to sign the certificate after the Student/Participant has printed it.</p><br /><p>A <a href='"+certificateTemplatePath+"'>template</a> that can be used as a guide for designing your own certificate can be downloaded from <a href='"+certificateTemplatePath+"'>here</a>. You will need to to open this template in an image editing application to adapt the design to suit your needs. See the <a href='https://intranet.secure.griffith.edu.au/computing/blended-learning-support/using-learning-at-griffith/administration-tools/certificate-of-completion' target='_blank' title='Link opens in a new window'>Certificate of Completion support page</a> for further information.</p><br /><p>An <a href='"+certificateExamplePath+"'>example of a completed certificate design</a> for inspiration can be seen <a href='"+certificateExamplePath+"'>here</a>.</p><br style='clear: right' />";
		String labelForAction = "Add Certificate";
	
		Course thisCourse = ctx.getCourse();
		String thisCourseId = thisCourse.getCourseId();
		String srcCourseId = thisCourseId;
		String action = request.getParameter("action");
		
		// set defaults for certificate
		String title = "";
		String dateDisplayFormat = "";
		
		// set defaults for availability
		Date startDate = null;
		Date endDate = null;
		boolean isTracked = false;
		boolean isAvailable = true;
		
		Calendar startDateCal = Calendar.getInstance();
		Calendar endDateCal = Calendar.getInstance();

		BbPersistenceManager bbPm = PersistenceServiceFactory.getInstance().getDbPersistenceManager();
		Container bbContainer = bbPm.getContainer();
		ContentDbLoader courseDocumentLoader = (ContentDbLoader) bbPm.getLoader(ContentDbLoader.TYPE);
		Id courseId = bbPm.generateId(Course.DATA_TYPE,request.getParameter("course_id"));
		Id parentId = bbPm.generateId(CourseDocument.DATA_TYPE,request.getParameter("content_id"));
		
		Content contentItem = null;
		List<ContentFile> fileList;
		// Note: List<FilePickerFile> cannot be instantiated, so ArrayList<FilePickerFile> is used instead
		List<FilePickerFile> filePickerFileList = new ArrayList<FilePickerFile>();
		
		if (action.equals("create")) {
			labelForAction = "Add Certificate";
		} else if (action.equals("modify")) {
			Id contentId = new PkId(bbContainer,CourseDocument.DATA_TYPE,request.getParameter("content_id"));
			contentItem = courseDocumentLoader.loadById(contentId);
			isTracked = contentItem.getIsTracked();
			isAvailable = contentItem.getIsAvailable();
			startDateCal = contentItem.getStartDate();
			endDateCal = contentItem.getEndDate();
			title = contentItem.getTitle();
			ExtendedData attrs = contentItem.getExtendedData();
			dateDisplayFormat = attrs.getValue("dateDisplayFormat");			
			
			// get attached files - based on http://forums.edugarage.com/forums/p/3296/9785.aspx#9785
			// note that contentItem.getContentFiles() could be used to achieve the same thing IF the Content object was "heavy" loaded (using one of the methods in ContentDbLoader that take a boolean "heavy" argument) as per http://forums.edugarage.com/forums/t/3455.aspx . If it is not "heavy" loaded, it will return empty, but the following can be used in place of this.
						
			ContentDbPersister contentPersister = ContentDbPersister.Default.getInstance();
			ContentFileDbLoader cfLoader = ContentFileDbLoader.Default.getInstance();//(ContentFileDbLoader)BbServiceManager.getPersistenceService().getDbPersistenceManager().getLoader(ContentFileDbLoader.TYPE);   
			
			// get attached file list (List<ContentFile>)
			fileList = cfLoader.loadByContentId(contentId);
			
			// get first ContentFile in that list (there should only be one ContentFile attached)
			ContentFile ci = fileList.get(0);
			
			// create a new FilePickerFile by sending the ContentFile to the ContentFilePicker class to do the conversion
			FilePickerFile fpf = new ContentFilePicker(ci);
			
			// add the FilePickerFile to the <List>FilePickerFile
			filePickerFileList.add(fpf);
						
			if (startDateCal != null) {
				startDate = startDateCal.getTime();
			}
			
			if (endDateCal != null) {
				endDate = endDateCal.getTime();
			}
			
			labelForAction = "Modify Certificate";

		} else {
			labelForAction = "";
			return;
		}
		
		String[] participantTypesArray = new String[]{"Participant","Student","Staff"}; // not presently used
		String[] dateDisplayFormatsArray = new String[]{"Full date (DD/MM/YYYY)","Year only (YYYY)","No date"};
		
	%>
	<bbNG:pageHeader>
		<bbNG:breadcrumbBar isContent="true">
			<bbNG:breadcrumb><%=labelForAction%></bbNG:breadcrumb>
		</bbNG:breadcrumbBar>
		<bbNG:pageTitleBar iconUrl="<%=thisPluginImageUrlPath%>" title='<%=labelForAction%>'></bbNG:pageTitleBar>
	</bbNG:pageHeader>
	
	<bbNG:form action="create_sub.jsp?course_id=${ctx.courseId.externalString}" enctype="multipart/form-data" method="post" onsubmit="validateForm();">
		
		<bbNG:dataCollection showSubmitButtons="true" hasRequiredFields="true">
			
			<bbNG:hiddenElement name="content_id" value='<%=request.getParameter("content_id")%>' />
			<bbNG:hiddenElement name="course_id" value='<%=request.getParameter("course_id")%>' />
			<bbNG:hiddenElement name="action" value='<%=action%>' />
						
			<bbNG:step title="Certificate Link Name" instructions="This name will appear as the link that points to the certificate">
	    	
	    		<bbNG:dataElement label="Certificate Link Name" isRequired="true" labelFor="certificate_name">
	    			<bbNG:textElement name="certificate_name" value='<%=title%>' />
	    		</bbNG:dataElement>
	    		
	    	</bbNG:step>
			
			<bbNG:step title="Certificate Design" instructions="<%=certificateDesignInstructions%>">
			<bbNG:filePicker baseElementName="certificate_template_file" var="certificate_template_file" pickerMimeType="IMAGE" doNotAttachLabel="Select a Different File" showLinkTitle="false" attachedFiles='<%=filePickerFileList%>' required="true"/>
	    	</bbNG:step>
			
			<bbNG:step title="Certificate Options" instructions="Choose a date display format. This determines how the date will be displayed on the certificate. If you choose not to display a date, you may wish to include a pre-defined year or semester as part of your certificate design image.">
	    		<bbNG:dataElement label="Date display format" isRequired="true" labelFor="date_display_format">
	    			<bbNG:selectElement name="date_display_format" size="1">
	    				<% for (int p=0; p<dateDisplayFormatsArray.length; p++) { 
	    					boolean displayFormatSelected = dateDisplayFormatsArray[p].equals(dateDisplayFormat) ? true : false;
	    				%>
	    				<bbNG:selectOptionElement value='<%=dateDisplayFormatsArray[p] %>' optionLabel='<%=dateDisplayFormatsArray[p] %>' isSelected='<%=displayFormatSelected %>' helpText="This determines how the date will be printed on the certificate." />
	    				<% } %>
	    			</bbNG:selectElement>
	    		</bbNG:dataElement>
	    		
	    	</bbNG:step>
			
			<bbNG:step title="Release Options">	
				<bbNG:dataElement label="Make the content available" isRequired="true">
					<bbNG:radioElement value="true" name="isAvailable" id="isAvailableYes" isSelected='<%=isAvailable%>'><label for="isAvailableYes">Yes</label></bbNG:radioElement>
					<bbNG:radioElement value="false" name="isAvailable" id="isAvailableNo" isSelected='<%=!isAvailable%>'><label for="isAvailableNo">No</label></bbNG:radioElement>
				</bbNG:dataElement>
				<bbNG:dataElement label="Track number of views" isRequired="true">
					<bbNG:radioElement value="true" name="isTracked" id="isTrackedYes" isSelected='<%=isTracked%>'><label for="isTrackedYes">Yes</label></bbNG:radioElement>
					<bbNG:radioElement value="false" name="isTracked" id="isTrackedNo" isSelected='<%=!isTracked%>'><label for="isTrackedNo">No</label></bbNG:radioElement>
				</bbNG:dataElement>
				<bbNG:dataElement label="Choose date and time restrictions">
					<bbNG:dateRangePicker baseFieldName="bbDateTimePicker" showTime="true" />
				</bbNG:dataElement>
				
			</bbNG:step>

			<bbNG:stepSubmit title="Add Certificate" instructions="Click Add to add the certificate or Cancel to quit." cancelUrl='<%=PlugInUtil.getEditableContentReturnURL(parentId, courseId)%>'>
				<bbNG:stepSubmitButton label="Submit" primary="true" />
			</bbNG:stepSubmit>

		</bbNG:dataCollection>
	</bbNG:form>

</bbNG:genericPage>