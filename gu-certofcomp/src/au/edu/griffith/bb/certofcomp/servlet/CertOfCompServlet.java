package au.edu.griffith.bb.certofcomp.servlet;

import java.io.IOException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.logging.Level;
import java.util.logging.Logger;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.codec.binary.Hex;

import au.edu.griffith.bb.util.BbId;
import au.edu.griffith.bb.util.BuildingBlockHelper;
import blackboard.data.content.Content;
import blackboard.data.course.Course;
import blackboard.data.user.User;
import blackboard.persist.PersistenceException;
import blackboard.persist.content.ContentDbLoader;
import blackboard.platform.context.Context;
import blackboard.platform.context.ContextManagerFactory;
import blackboard.servlet.util.ContentRendererUtil;

public class CertOfCompServlet extends HttpServlet
{

  /**
   * 
   */
  private static final long serialVersionUID = 1L;

  /**
   * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
   * methods.
   * 
   * @param request
   *          servlet request
   * @param response
   *          servlet response
   * @throws ServletException
   *           if a servlet-specific error occurs
   * @throws IOException
   *           if an I/O error occurs
   * @throws InstantiationException 
   * @throws PersistenceException 
   * @throws NoSuchAlgorithmException 
   */
  protected void processRequest(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
  {
    try
    {
      Context ctx = ContextManagerFactory.getInstance().setContext(request);
      User user = ctx.getUser();
      Course course = ctx.getCourse();
      
      if (user == null || course == null)
      {
        Logger.getLogger(this.getClass().getName()).log(Level.WARNING, "Not logged in" + (course == null ? " to course" : ""));
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        return;
      }
      
      String studentId = user.getUserName();
      String studentName = user.getGivenName() + " " + user.getFamilyName();
  
      SimpleDateFormat simpleDateFormat = new SimpleDateFormat("dd-MM-yyyy");
      String todaysDate = simpleDateFormat.format(new Date(System.currentTimeMillis()));
  
      String contentIdString = request.getParameter("content_id");
      BbId contentBbId = BbId.fromIdString(contentIdString, ServletException.class, "Invalid content_id");
  
      // Load courseDoc object
      ContentDbLoader contentLoader = ContentDbLoader.Default.getInstance();
      contentBbId.generateId(Content.DATA_TYPE);
      Content content = contentLoader.loadById(contentBbId.getId());
      
      // check the contentItem is available (the criteria is met for this user)
      if (!ContentRendererUtil.getFullPathIsAvailable(contentBbId.getId(), user.getId()))
      {
        Logger.getLogger(this.getClass().getName()).log(Level.WARNING, "Content item not available");
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        return;        
      }

      // check the contentItem is part of the given course
      if (!content.getCourseId().equals(course.getId()))
      {
        Logger.getLogger(this.getClass().getName()).log(Level.WARNING, "Content item not not part of given course/organisation");
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        return;        
      }
     
      // see which certificate the contentItem is associated with
      String secret = "";
      if ("Laboratory Induction Certificate".equals(content.getTitle()))
      {
        secret = "29b3Ed";
      }
      else if ("Safety Induction Certificate".equals(content.getTitle()))
      {
        secret = "3jA3dcBD";
      }
      else if ("Health and Safety Induction Certificate".equals(content.getTitle()))
      {
        secret = "e3Gs1WW9";
      }
      else if ("Engineering G09 Certificate".equals(content.getTitle()))
      {
        secret = "f73HJc0q";
      }
      else if ("Engineering G39 Certificate".equals(content.getTitle()))
      {
        secret = "dLj4eV4";
      }
      else if ("Engineering Computer Labs Certificate".equals(content.getTitle()))
      {
        secret = "zX27py6";
      }
      else if ("Workplace Health and Safety Certificate".equals(content.getTitle()))
      {
        secret = "w1mj5wBr";
      }
      else if ("MS Access Certificate".equals(content.getTitle()))
      {
        secret = "ih3W0oa";
      } 
      else if ("MS Excel Certificate".equals(content.getTitle()))
      {
        secret = "iLf2tw3";
      } 
      else if ("MS PowerPoint Certificate".equals(content.getTitle()))
      {
        secret = "w5GBiHp";
      } 
      else if ("MS Word Certificate".equals(content.getTitle()))
      {
        secret = "iW25MTw";
      }       
      else if ("CTS CMDB".equals(content.getTitle()))
      {
        secret = "cLeFQY3";
      }        
      else if ("Manual Tasks/Office Ergonomics Certificate".equals(content.getTitle()))
      {
        secret = "mto3AQi";
      }  
      else if ("Lab and Workshop Safety Certificate".equals(content.getTitle()))
      {
        secret = "lws29oD";
      }      
      else if ("Practical Hazard and Incident Management Certificate".equals(content.getTitle()))
      {
        secret = "p45d89j";
      }  
      else if ("Annual Fire Safety Certificate".equals(content.getTitle()))
      {
        secret = "qqy7shn";
      }  
      else if ("Basic Workplace Health and Safety Certificate".equals(content.getTitle()))
      {
        secret = "uu8sjda";
      }  
      else if ("Office Ergonomics Certificate".equals(content.getTitle()))
      {
        secret = "zxyw8jd3";
      }  
      else if ("Hazardous Manual Tasks Certificate".equals(content.getTitle()))
      {
        secret = "g6sjl09";
      }  
      else if ("Hazardous Manual Tasks for Supervisors Certificate".equals(content.getTitle()))
      {
        secret = "po7r4m9";
      }  
      else if ("Wellbeing for Work and Life Certificate".equals(content.getTitle()))
      {
        secret = "ccs9ns7";
      }
      else if ("Sessional Staff Induction Certificate".equals(content.getTitle()))
      {
        secret = "ssc50W";
      }    
      else if ("Griffith Graduate Research School Certificate".equals(content.getTitle()))
      {
        secret = "ggrs234";
      }          
      else if ("Designing Online Courses AEL".equals(content.getTitle()))
      {
        secret = "doc1ael";
      }          
      else
      {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        return;        
      }        
  
      secret += studentId + studentName + todaysDate;
      MessageDigest md5MessageDigest = MessageDigest.getInstance("MD5");
      String md5Hash = new String(Hex.encodeHex(md5MessageDigest.digest(secret.getBytes())));
  
      request.setAttribute("studentId", studentId);
      request.setAttribute("studentName", studentName);
      request.setAttribute("todaysDate", todaysDate);
      request.setAttribute("md5Hash", md5Hash);
      BuildingBlockHelper.showJSP("/index.jsp", request, response);
      return;
    }
    catch (InstantiationException ie)
    {
      Logger.getLogger(this.getClass().getName()).log(Level.SEVERE, ie.getMessage(), ie);
    }
    catch (PersistenceException pe)
    {
      Logger.getLogger(this.getClass().getName()).log(Level.SEVERE, pe.getMessage(), pe);
    }
    catch (NoSuchAlgorithmException nae)
    {
      Logger.getLogger(this.getClass().getName()).log(Level.SEVERE, nae.getMessage(), nae);
    }
    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
  }

  /**
   * Handles the HTTP <code>GET</code> method.
   * 
   * @param request
   *          servlet request
   * @param response
   *          servlet response
   * @throws ServletException
   *           if a servlet-specific error occurs
   * @throws IOException
   *           if an I/O error occurs
   */
  protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
  {
    processRequest(request, response);

  }

  /**
   * Handles the HTTP <code>POST</code> method.
   * 
   * @param request
   *          servlet request
   * @param response
   *          servlet response
   * @throws ServletException
   *           if a servlet-specific error occurs
   * @throws IOException
   *           if an I/O error occurs
   */
  protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
  {
    processRequest(request, response);

  }

  /**
   * Returns a short description of the servlet.
   * 
   * @return a String containing servlet description
   */
  public String getServletInfo()
  {
    return "Certificate of Completion Servlet";

  }// </editor-fold>

}
