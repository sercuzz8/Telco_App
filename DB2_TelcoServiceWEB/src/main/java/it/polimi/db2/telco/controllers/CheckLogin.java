package it.polimi.db2.telco.controllers;

import java.io.IOException;
import javax.ejb.EJB;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.commons.lang.StringEscapeUtils;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.WebContext;
import org.thymeleaf.templatemode.TemplateMode;
import org.thymeleaf.templateresolver.ServletContextTemplateResolver;

import it.polimi.db2.telco.entities.User;
import it.polimi.db2.telco.exceptions.CredentialsException;
import it.polimi.db2.telco.services.UserService;

/**
 * Servlet implementation class Login
 */
@WebServlet("/CheckLogin")
public class CheckLogin extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TemplateEngine templateEngine;
	@EJB(name = "it.polimi.db2.telco.services/UserService")
	private UserService usrService;

	public CheckLogin() {
		super();
	}

	public void init() throws ServletException {
		ServletContext servletContext = getServletContext();
		ServletContextTemplateResolver templateResolver = new ServletContextTemplateResolver(servletContext);
		templateResolver.setTemplateMode(TemplateMode.HTML);
		templateResolver.setCacheable(false);
		this.templateEngine = new TemplateEngine();
		this.templateEngine.setTemplateResolver(templateResolver);
		templateResolver.setSuffix(".html");
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		String path = null;
		
		if (request.getSession().getAttribute("user")!=null) {
			path = getServletContext().getContextPath() + "/GoToHomePage";
			response.sendRedirect(path);
			return;
		}
		else if (request.getSession().getAttribute("employee")!=null) {
			path = getServletContext().getContextPath() + "/GoToHomePageEmployee";
			response.sendRedirect(path);
			return;
		}
		
		path= "/Login.html";
		
		ServletContext servletContext = getServletContext();
		final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
		templateEngine.process(path, ctx, response.getWriter());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String usrn = null;
		String pwd = null;
		try {
			usrn = StringEscapeUtils.escapeJava(request.getParameter("username"));
			pwd = StringEscapeUtils.escapeJava(request.getParameter("pwd"));
			if (usrn == null || pwd == null || usrn.isBlank() || pwd.isBlank()) {
				throw new Exception("Missing or empty credential value");
			}
		} catch (Exception e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", "Missing or empty credential value");
			String path = "/Login.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}

		User user = null;
		try {
			// query DB to authenticate the user
			user = usrService.checkCredentials(usrn, pwd);
		} catch (CredentialsException e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", "Incorrect username or password");
			String path = "/Login.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}

		// If the user exists, add info to the session and go to home page, otherwise
		// show login page with error message
		String path;
		if (user == null) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", "Incorrect username or password");
			path = "/Login.html";
			templateEngine.process(path, ctx, response.getWriter());
		} 
		else {
			
			request.getSession().setAttribute("user", user);
			if (request.getSession().getAttribute("order")!=null) {
				path = getServletContext().getContextPath() + "/GoToConfirmationPage";
				response.sendRedirect(path);
			}
			else {
			path = getServletContext().getContextPath() + "/GoToHomePage";
			response.sendRedirect(path);
			}
		}
	}
}