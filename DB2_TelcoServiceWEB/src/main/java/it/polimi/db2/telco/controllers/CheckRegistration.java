package it.polimi.db2.telco.controllers;

import java.io.IOException;
import java.io.PrintWriter;
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

	/*
	 * RegExp per il controllo della validit� dei campi
	 */

	//private static final String EMAIL_REGEXP = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$";
	//private static final String PWD_REGEXP = "^(?=.*[0-9])(?=.*[a-z])(?=.*[A-Z]).{6,}$";

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
		try {
			usrn = StringEscapeUtils.escapeJava(request.getParameter("username"));
			email = StringEscapeUtils.escapeJava(request.getParameter("email"));
			pwd = StringEscapeUtils.escapeJava(request.getParameter("pwd"));
			if (usrn == null || email == null || pwd == null || usrn.isBlank() || email.isBlank() || pwd.isBlank()) {
				throw new Exception("Missing or empty credential value");
			}
			/*} else if (!PatternChecker.validateField(EMAIL_REGEXP, email)) {
				ServletContext servletContext = getServletContext();
				final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
				ctx.setVariable("errorMsgEmail", "Email address not valid: it should be in the format aa@bb.cc");
				String path = "/WEB-INF/Registration.html";
				templateEngine.process(path, ctx, response.getWriter());
				return;
			} else if (!PatternChecker.validateField(PWD_REGEXP, pwd)) {
				ServletContext servletContext = getServletContext();
				final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
				ctx.setVariable("errorMsgPassword",
						"Password must be at least 6 characters long and include an uppercase, a lowercase and a digit");
				String path = "/WEB-INF/Registration.html";
				templateEngine.process(path, ctx, response.getWriter());
				return;
			}*/
		} catch (Exception e) {
			response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing credential value");
			return;
		}

		try {
			usrService.addUser(usrn, email, pwd);
		} catch (Exception e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", "Email address or username already in use");
			String path = "/WEB-INF/Registration.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}

		String path = getServletContext().getContextPath() + "/CheckLogin";
		PrintWriter out = response.getWriter();
		response.setContentType("text/html");
		out.println(
				"<script>window.alert('Registration successful!');" + "window.location.href = '" + path + "'</script>");
		// response.sendRedirect(path);
		return;
	}
}
