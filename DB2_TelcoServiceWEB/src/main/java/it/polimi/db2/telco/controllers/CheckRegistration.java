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
import it.polimi.db2.telco.services.UserService;

/**
 * Servlet implementation class CheckRegistration
 */
@WebServlet("/CheckRegistration")
public class CheckRegistration extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TemplateEngine templateEngine;
	@EJB(name = "it.polimi.db2.telco.services/UserService")
	private UserService usrService;

	public CheckRegistration() {
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
		String path = "WEB-INF/Registration.html";
		ServletContext servletContext = getServletContext();
		final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
		templateEngine.process(path, ctx, response.getWriter());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String usrn = null;
		String email = null;
		String pwd = null;
		
		User user = null;
		
		try {
			usrn = StringEscapeUtils.escapeJava(request.getParameter("username"));
			email = StringEscapeUtils.escapeJava(request.getParameter("email"));
			pwd = StringEscapeUtils.escapeJava(request.getParameter("pwd"));
			if (usrn == null || email == null || pwd == null || usrn.isBlank() || email.isBlank() || pwd.isBlank()) {
				throw new Exception("Missing or empty credential value");
			}
		} catch (Exception e) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing credential value");
			return;
		}

		try {
			user=usrService.addUser(usrn, email, pwd);
		} catch (Exception e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", "Email address or username already in use");
			String path = "/WEB-INF/Registration.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}
		
		request.getSession().setAttribute("user", user);
		
		if (request.getSession().getAttribute("order")!=null) {
			String path = getServletContext().getContextPath() + "/GoToConfirmationPage";
			response.setContentType("text/html");
			response.sendRedirect(path);
			return;
		}
		else {
		String path = getServletContext().getContextPath() + "/GoToHomePage";
		response.setContentType("text/html");
		response.sendRedirect(path);
		return;
		}
		
	}
}
