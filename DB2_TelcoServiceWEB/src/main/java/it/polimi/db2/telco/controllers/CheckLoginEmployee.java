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

import it.polimi.db2.telco.entities.Employee;
import it.polimi.db2.telco.exceptions.CredentialsException;
import it.polimi.db2.telco.services.EmployeeService;


/**
 * Servlet implementation class CheckEmployeeLogin
 */
@WebServlet("/CheckLoginEmployee")
public class CheckLoginEmployee extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TemplateEngine templateEngine;
	@EJB(name = "it.polimi.db2.telco.services/EmployeeService")
	private EmployeeService empService;

	public CheckLoginEmployee() {
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
		
		path="WEB-INF/LoginEmployee.html";
		
		ServletContext servletContext = getServletContext();
		final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
		templateEngine.process(path, ctx, response.getWriter());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String code = null;
		String pwd = null;
		try {
			code = StringEscapeUtils.escapeJava(request.getParameter("code"));
			pwd = StringEscapeUtils.escapeJava(request.getParameter("pwd"));
			if (code == null || pwd == null || code.isBlank() || pwd.isBlank()) {
				throw new Exception("Missing or empty credential value");
			}
		} catch (Exception e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", "Missing or empty credential value");
			String path = "/WEB-INF/LoginEmployee.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}

		Employee employee = null;
		try {
			employee = empService.checkCredentials(code, pwd);
		} catch (CredentialsException e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", "Incorrect code or password");
			String path = "/WEB-INF/LoginEmployee.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}

		// If the employee exists, add info to the session and go to home page, otherwise
		// show login page with error message
		String path;
		if (employee == null) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", "Incorrect code or password");
			path = "/WEB-INF/LoginEmployee.html";
			templateEngine.process(path, ctx, response.getWriter());
		} else {
			request.getSession().setAttribute("employee", employee);
			path = getServletContext().getContextPath() + "/GoToHomeEmployee";
			response.sendRedirect(path);
		}
	}
}
