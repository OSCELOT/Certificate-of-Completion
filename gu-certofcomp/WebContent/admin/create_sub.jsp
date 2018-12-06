<%@page import="java.util.*,
                java.io.*,
               	java.text.SimpleDateFormat,
                blackboard.data.*,
                blackboard.data.course.Course,
                blackboard.data.course.CourseQuota,
                blackboard.data.content.*,
                blackboard.data.registry.*,
                blackboard.persist.*,
                blackboard.persist.content.*,
                blackboard.persist.course.CourseDbLoader,
                blackboard.platform.BbServiceManager,
                blackboard.platform.persistence.*,
				blackboard.platform.filesystem.UploadUtil,
				blackboard.platform.filesystem.MultipartRequest,
                blackboard.platform.plugin.*,
				blackboard.platform.servlet.*,
				blackboard.platform.context.*,
				blackboard.platform.contentsystem.data.*,
				blackboard.platform.contentsystem.manager.*,
				blackboard.platform.contentsystem.service.ContentSystemServiceFactory,
				blackboard.platform.contentsystem.service.ContentSystemServiceExFactory,
				blackboard.util.RequestUtil"
		pageEncoding="UTF-8"
		contentType="text/html"
        errorPage="/error.jsp"
%>
<%@ taglib uri="/bbNG" prefix="bbNG"%>
<%

if (!PlugInUtil.authorizeForCourse(request, response)){
		return;
}

boolean success = true;
String message = "";
String certificateName = "New Certificate";

ContextManagerFactory.getInstance().setContext(request);
Context ctx = ContextManagerFactory.getInstance().getContext();
Id coursePkId = ctx.getCourseId(); // same as thisCourse.getId() using thisCourse as set below. Also the same as bbPm.generateId(Course.DATA_TYPE,request.getParameter("course_id")) using bbPm as set below

// create a new content item to house the certificate
Content contentItem = new Content();

// retrieve the Db persistence manager from the persistence service
BbPersistenceManager bbPm = PersistenceServiceFactory.getInstance().getDbPersistenceManager();
ContentDbPersister contentPersister = (ContentDbPersister) bbPm.getPersister( ContentDbPersister.TYPE );
ContentDbLoader contentLoader = (ContentDbLoader) bbPm.getLoader( ContentDbLoader.TYPE );

// set internal content and parent IDs to null for now. These will vary depending on whether a new item is being created or an existing one modified
Id contentId = null;
Id parentId = null;
		
int numChildren = 0;
  
// get real course reference ID, not pk number
CourseDbLoader cLoader = CourseDbLoader.Default.getInstance();
Course thisCourse = (Course)cLoader.loadById(coursePkId); // could also be achieved through ctx.getCourse();
String courseId = thisCourse.getCourseId(); // NOT USED

//the content system (Content Collection) location for this course/org, e.g. /orgs/ORG_NAME - public storage area
String csLocation = ContentSystemServiceExFactory.getInstance().getNavigationManager().getHomeDirectory(thisCourse);

String strReturnUrl = "";
String fileName = "";

String tempOrigFilename = "";

//receipt options for displaying at redirect
ReceiptOptions rOptions = new ReceiptOptions();
		
//try to get multipart request
try { 
		
	MultipartRequest mr = UploadUtil.processUpload(request);
	
	String action = mr.getParameter("action");
		
	// get availability options
	String isTracked = RequestUtil.getStringParameter(mr, "isTracked","false");
	String isAvailable = RequestUtil.getStringParameter(mr, "isAvailable","false");
	String startDate = RequestUtil.getStringParameter(mr, "bbDateTimePicker_start_datetime",null);
	String useStartDate = RequestUtil.getStringParameter(mr, "bbDateTimePicker_start_checkbox","0");
	String endDate = RequestUtil.getStringParameter(mr, "bbDateTimePicker_end_datetime",null);
	String useEndDate = RequestUtil.getStringParameter(mr, "bbDateTimePicker_end_checkbox",null);
	SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	Calendar cstart = Calendar.getInstance();
	Calendar cend = Calendar.getInstance();
	cstart.setTime(formatter.parse(startDate));
	cend.setTime(formatter.parse(endDate));
	
	// get certificate settings
	certificateName = RequestUtil.getStringParameter(mr, "certificate_name","");
	String dateDisplayFormat = RequestUtil.getStringParameter(mr, "date_display_format","");
			
	// certificate name is required, else error
	if(certificateName != null && !certificateName.equals("")) {
				
		// check if this is a newly created item or whether the user is modifying an existing item
		if (action.equals("create")) {
			
			// customise success message
			message = "Your certificate, \""+certificateName+"\", has been created. Click its title below to view it. It is suggested that an Adaptive Release rule is applied to certificates so they will only display to those who have met certain criteria.";
			
			parentId = bbPm.generateId(Content.DATA_TYPE,mr.getParameter("content_id"));
			List<Content> childList; // was BbList childList = new List();
			try {
				childList = contentLoader.loadChildren(parentId);
				numChildren = childList.size();
			} catch (Exception error) {
				// don't do anything
			}
			contentItem.setPosition(numChildren);
			contentItem.setContentHandler("resource/x-gu-certofcomp"); // refers to the content handler set in bb-manifest
			contentItem.setCourseId(coursePkId);
			contentItem.setParentId(parentId);
			
		} else if(action.equals("modify")) {
			
			// customise success message
			message = "Your certificate, \""+certificateName+"\", has been modified.";
			
			contentId = bbPm.generateId(Content.DATA_TYPE,mr.getParameter("content_id"));
			contentItem = contentLoader.loadById(contentId);
			parentId = contentItem.getParentId();
			
			// Remove any ContentFiles that may already be attached. New or existing will be attached/reattached below...
			
			// get attached files - based on http://forums.edugarage.com/forums/p/3296/9785.aspx#9785
			// note that contentItem.getContentFiles() could be used to achieve the same thing IF the Content object was "heavy" loaded (using one of the methods in ContentDbLoader that take a boolean "heavy" argument) as per http://forums.edugarage.com/forums/t/3455.aspx . If it is not "heavy" loaded, it will return empty, but the following can be used in place of this.
			List<ContentFile> fileList;
			
			ContentFileDbLoader cfLoader = ContentFileDbLoader.Default.getInstance();//(ContentFileDbLoader)BbServiceManager.getPersistenceService().getDbPersistenceManager().getLoader(ContentFileDbLoader.TYPE);   
			
			fileList = cfLoader.loadByContentId(contentId);
			
			// There should only be one file attached, but iterate through fileList in case there are more, and remove them all
			ContentFile attachedFile;
			for (int i = 0; i < fileList.size(); i++) {
				
				attachedFile = fileList.get(i);
				blackboard.platform.content.ContentFileHelper.removeContentFile(coursePkId,contentId,attachedFile.getId());
				
				// Also tried the following, but the above version actually works
				// contentItem.removeContentFile(attachedFile);
				
	        }
		}
		
		// set content item title
		contentItem.setTitle(certificateName);
				
		// set whether the content item is available
		contentItem.setIsAvailable(isAvailable.equals("true"));
				
		// set whether the content item is tracked
		contentItem.setIsTracked(isTracked.equals("true"));
				
		// Set Availability Dates
		if (useStartDate != null){
			contentItem.setStartDate(cstart);
		}
		if (useEndDate != null){
			contentItem.setEndDate(cend);
		}
		
		strReturnUrl = PlugInUtil.getEditableContentReturnURL(parentId,coursePkId);
		
		// save miscellaneous parameters as ExtendedData
		ExtendedData ed = contentItem.getExtendedData();
		
		ed.setValue("dateDisplayFormat",dateDisplayFormat);
		contentItem.setExtendedData(ed);
		
		// persist contentItem before adding attachment
		contentPersister.persist(contentItem);	
		
		// Handle attachment
		String uploadType = mr.getParameter("certificate_template_file_attachmentType");
						
		// L indicates a local file which is a file uploaded from the user's computer	
		if(uploadType.equals("L")) {
		    // The file object is included in the request
			// Retrieve the name of the file (note that the 0 is missing from the Bb Java Doc). This will be something like example.jpg
		    fileName = mr.getParameter("certificate_template_file_LocalFile0");
		    
		    tempOrigFilename = fileName;
		    
		 	// IE returns full path of upload, e.g. C:\Path\To\File.jpg while other browsers just return File.jpg. These lines address that:
		    // look for slash
		 	if(fileName.contains("/")) {
		    	int index = fileName.lastIndexOf("/");
		    	fileName = fileName.substring(index + 1);
		    // or look for backslash
		 	} else if(fileName.contains("\\")) {
		    	int index = fileName.lastIndexOf("\\");
		    	fileName = fileName.substring(index + 1);
		    }
		    		    
		    // uploadedFile is java.io.file
		    File uploadedFile;
		    
		    // fullFileName is needed
		    if (fileName!=null && !fileName.equals("")) {
		    	// get the uploaded file that is sitting in a temporary location on the server. This comes out as /path/to/something.tmp
				uploadedFile = mr.getFile(tempOrigFilename); 
				
		    	// could also be achieved with:
				//File uploadedfile = mr.getFileFromParameterName("uploadedFile_LocalFile0");
		    				  
			 	String CS_FILEID_PREFIX = "xid-";
			  
			  	// CourseQuota is deprecated in 9.1 with no known replacement
				CourseQuota cq = CourseQuota.createInstance(thisCourse);
				if (cq.getEnforceQuota() && (cq.getCourseAbsoluteLimitRemainingSize() < 0 || uploadedFile.length() > cq.getCourseAbsoluteLimitRemainingSize())) {
					success = false;
					message = "Could not add attachment: Insufficient disk quota for " + thisCourse.getCourseId();
							
					rOptions.addErrorMessage("Error: "+message,null);
				}
								
				// code below based on http://forums.edugarage.com/forums/p/2145/7043.aspx
				
				try {
					// this is where Blackboard stores its attachments
					ResourceFile rf = ContentSystemServiceExFactory.getInstance().getDocumentManager().createFile(csLocation, fileName, new FileInputStream(uploadedFile), IDocumentManager.DuplicateFileHandling.Rename);
				
					ContentSystemServiceFactory.getInstance().getSecurityManager().grantPermissions(rf.getLocation(), thisCourse, blackboard.platform.contentsystem.manager.SecurityManager.PermissionType.Readable);
					ContentFile cf = new ContentFile(uploadedFile);
				 	cf.setContentId(contentItem.getId());
				 	cf.setAction(ContentFile.Action.BROKEN_IMAGE); // LINK (display link to the attachment), EMBED (embed attachment? - does not do this), PACKAGE (for zip?), BROKEN_IMAGE (unsure what this does, but it still seems to attach and does not link or embed the image, which is good)
				 	cf.setLinkName(fileName); // This would display if the ContentFile.Action.LINK setting was used above
				 	cf.setStorageType(AbstractContentFile.StorageType.CS); // CS or LOCAL
				 	cf.setSize(uploadedFile.length());
				 	cf.setName("/" + CS_FILEID_PREFIX + rf.getPermanentId());
									 			
				 	contentItem.addContentFile(cf);
					ContentFileDbPersister.Default.getInstance().persist(cf);			
				 			
					contentPersister.persist(contentItem);
				 			
					long _lCurrentCourseSize = Long.valueOf(CourseRegistryUtil.getString(thisCourse.getId(), "disk_usage", "1024"));
					CourseRegistryUtil.setString(coursePkId, "disk_usage", String.valueOf(_lCurrentCourseSize + cf.getSize()));
									 			
				} catch (ValidationException e) {
					message = "Invalid content file: " + e.getMessage();
					success = false;
					
					rOptions.addErrorMessage("Error: "+message,e);
					
				} catch (FileNotFoundException e) {
					message = "File not found: " + uploadedFile.getAbsolutePath();
					success = false;
					
					rOptions.addErrorMessage("Error: "+message,e);
					
				}
								 
			} else {
				success = false;
				message = "No file specified";
				
				rOptions.addErrorMessage("Error: "+message,null);
			}		    
		    
		// Otherwise, must be content system file (a file selected from the Content Collection), i.e. uploadType.equals("C")
		} else {
		    // The file itself is not included in the request
		   
		    // Retrieve the xythos ID (e.g."/xid-1801_2")
			String xythosId = mr.getParameter("certificate_template_file_CSFile"); //mr.getParameter("certificate_template_file_CSFilePath" would do the same in this instance
		    
			Resource csResource = ContentSystemServiceExFactory.getInstance().getDocumentManagerEx().getDocument(xythosId);
			if (csResource instanceof ResourceFile) {
				// Get the actual name of the file from the Content System
			    fileName = mr.getParameter("certificate_template_file_linkTitle");
				
				ContentFile cf = new ContentFile();
				cf.setContentId(contentItem.getId());
				cf.setStorageType(AbstractContentFile.StorageType.CS);
				cf.setAction(ContentFile.Action.BROKEN_IMAGE); // LINK (display link to the attachment), EMBED (embed attachment? - does not do this), PACKAGE (for zip?), BROKEN_IMAGE (unsure what this does, but it still seems to attach and does not link or embed the image, which is good)
								
				// cf.setLinkName - would display link name if the ContentFile.Action.LINK setting was used above
						
				// address IE error that makes script fail if filename not set.
				try{
					cf.setLinkName(fileName);
				} catch(NullPointerException e) {
					cf.setLinkName("Certificate");
				}
				
				cf.setName(xythosId);
				cf.setSize(csResource.getFileSize());
				ContentFileDbPersister.Default.getInstance().persist(cf);
			}
		}
		
	} else {
		// no certificate name, so no success
		success = false;
		message = "No Certificate Name specified";
		
		rOptions.addErrorMessage("Error: "+message,null);
	}

}catch(Exception e){
		
	// add errors to string for output: http://stackoverflow.com/questions/4812570/how-to-store-printstacktrace-into-a-string
	StringWriter errors = new StringWriter();
	e.printStackTrace(new PrintWriter(errors));
		
	success = false;
	message = "Error creating certificate item: " + errors.toString();
	
	rOptions.addErrorMessage(message,e);
}

// if success remains true at this point, add success message
if (success) {
	rOptions.addSuccessMessage("Success: "+message);
}

response.sendRedirect(InlineReceiptUtil.addReceiptToUrl(strReturnUrl, rOptions));

%>
