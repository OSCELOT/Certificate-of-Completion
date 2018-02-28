<%@ page language="java"
		import="java.io.*,
				java.awt.*,
				java.util.Date,
				java.text.SimpleDateFormat,
				blackboard.data.user.*,
				java.awt.image.BufferedImage,
				java.awt.geom.AffineTransform,
				javax.imageio.ImageIO,
				java.awt.geom.Rectangle2D,
				blackboard.platform.contentsystem.data.*,
				blackboard.platform.contentsystem.service.ContentSystemServiceExFactory,
				
				java.awt.font.GlyphVector,
				java.awt.font.FontRenderContext,
				java.awt.geom.Ellipse2D"
%>

<%@ taglib prefix="bbNG" uri="/bbNG"%>

<bbNG:learningSystemPage ctxId="ctx">


<%
// force short cache for IE so image shows up when printing
response.setHeader("Cache-Control","max-age=180");

// set up user instance
User sessionUser = ctx.getUser();

// get user details
String sessionUserSNumber = sessionUser.getUserName();
String sessionUserFullName = sessionUser.getGivenName() + " " + sessionUser.getFamilyName();

// set parameters from session
String certificateName = session.getAttribute("certificateName").toString();
String dateDisplayFormat = session.getAttribute("dateDisplayFormat").toString();

// set the date string (empty by default, override if a date format is set)
String todaysDate = "";

// set the date format
SimpleDateFormat df;
if(dateDisplayFormat.equals("Year only (YYYY)")) {
	df = new SimpleDateFormat("yyyy");
	todaysDate = df.format(new Date());
} else if(dateDisplayFormat.equals("Full date (DD/MM/YYYY)")) {
	df = new SimpleDateFormat("dd/MM/yyyy");
	todaysDate = df.format(new Date());
}

Resource csResource = ContentSystemServiceExFactory.getInstance().getDocumentManagerEx().getDocument(session.getAttribute("certificateXID").toString());

if (csResource instanceof ResourceFile) {
	
	// read template image
	ResourceFile file = (ResourceFile) csResource;
	InputStream certificateInputStream = file.getContents();
	BufferedImage certificate = ImageIO.read(certificateInputStream);
		
	// get dimensions
	int certificateWidth = certificate.getWidth(); // Certificate should be 700
	int certificateHeight = certificate.getHeight(); // Certificate should be 990
	
	// set foreground colour
	Color foreground = Color.black;
	
	// Garamond Italic font - for the participant name
	String garamondItalicFile = "fonts/GARAIT.TTF";
	garamondItalicFile = request.getSession().getServletContext().getRealPath(garamondItalicFile);
	float size = 20.0f;
	Font garamondItalicFont = Font.createFont(Font.TRUETYPE_FONT, new FileInputStream(garamondItalicFile));
	garamondItalicFont = garamondItalicFont.deriveFont(size);
	
	// establish certificate graphics
	Graphics2D textGraphics = certificate.createGraphics();
	
	// set rendering
	textGraphics.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_ON);
	FontRenderContext fc = textGraphics.getFontRenderContext();
	Rectangle2D bounds = garamondItalicFont.getStringBounds(sessionUserFullName,fc);
	int textWidth = (int) bounds.getWidth();
	int textHeight = (int) bounds.getHeight();
	
	int textX = 304;
	int textY = 388;
		
	// add watermark of student's user ID - based off https://www.richardnichols.net/2010/09/how-to-add-dynamic-watermark-to-jpeg-java/
	
	// set the font and text for the watermark
	Font font = new Font(Font.SANS_SERIF, Font.PLAIN, 9);
	GlyphVector fontGV = font.createGlyphVector(textGraphics.getFontRenderContext(), sessionUserSNumber);
	
	// get the size of the watermark area
	Rectangle watermarkSize = fontGV.getPixelBounds(textGraphics.getFontRenderContext(), 0, 0);
	double watermarkTextWidth = watermarkSize.getWidth();
    double watermarkTextHeight = watermarkSize.getHeight();
	
	// create shape using font
	Shape textShape = fontGV.getOutline();
	
	// set starting position for watermark
	double watermarkX = textX;
	double watermarkY = textY-(watermarkTextHeight*2.7);
	
	// create AffineTransform at the x and y of the participant name
	AffineTransform at = AffineTransform.getTranslateInstance(watermarkX,watermarkY);
	
	// rotate the AffineTransform 90 degrees
	at.rotate(Math.PI / 2d);
	
	// create a transformed text shape
	Shape transformedText = at.createTransformedShape(textShape);
	
	// set watermark colour - r,g,b,a
	Color watermarkColour = new Color(0.1f,0.1f,0.1f,0.01f);
	textGraphics.setColor(watermarkColour);
	
	// step in y direction is calculeted using pythagoras
    double yStep = Math.sqrt(watermarkTextWidth * watermarkTextWidth / 2);
	
	// store the translated amounts for reversing later
	double totalTranslateX = 0;
	double totalTranslateY = 0;
	
	for (double x = -watermarkTextHeight; x < textWidth; x += watermarkTextHeight) {
		double y = -yStep;
 		textGraphics.draw(transformedText);
		textGraphics.fill(transformedText);
 		
		double translateX = watermarkTextHeight * 2;
		double translateY = -(y + yStep);
		
		textGraphics.translate(translateX, translateY);
 		
 		totalTranslateX += translateX;
 		totalTranslateY += translateY;
    }
	
	textGraphics.translate(-totalTranslateX,-totalTranslateY);
	    				  
	// set font for remaining text and write to image
	textGraphics.setFont(garamondItalicFont);
	textGraphics.setColor(foreground);
	
	textGraphics.drawString(sessionUserFullName,textX,textY);
	textGraphics.drawString(sessionUserSNumber,textX,418);
	textGraphics.drawString(todaysDate,440,883);
	
	textGraphics.dispose();
	
	// set the content type and get the output stream
	response.setContentType("image/png");
	OutputStream os = response.getOutputStream();
	
	// output the image as png
	ImageIO.write(certificate, "png", os);
	os.close();
	
	// clear the session variables used on this certificate. They will be regenerated if a different certificate is viewed or this one is refreshed
	session.removeAttribute("certificateName");
	session.removeAttribute("certificateXID");
}

%>
</bbNG:learningSystemPage>