package it.polimi.db2.telco.controllers;

import java.io.IOException;

import javax.ejb.EJB;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.WebContext;
import org.thymeleaf.templatemode.TemplateMode;
import org.thymeleaf.templateresolver.ServletContextTemplateResolver;

import it.polimi.db2.telco.entities.CustomerOrder;
import it.polimi.db2.telco.entities.User;
import it.polimi.db2.telco.services.CustomerOrderService;


/**
 * Servlet implementation class GoToConfirmationPage
 */
@WebServlet("/GoToConfirmationPage")
public class GoToConfirmationPage extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TemplateEngine templateEngine;
	
	@EJB(name = "it.polimi.db2.telco.services/CustomerOrderService")
	private CustomerOrderService cOrds;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public GoToConfirmationPage() {
		super();
	}

	public void init() throws ServletException {
		ServletContext servletContext = getServletContext();
		ServletContextTemplateResolver templateResolver = new ServletContextTemplateResolver(servletContext);
		templateResolver.setTemplateMode(TemplateMode.HTML);
		this.templateEngine = new TemplateEngine();
		this.templateEngine.setTemplateResolver(templateResolver);
		templateResolver.setSuffix(".html");
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String path = "/WEB-INF/Confirmation.html";
				
		ServletContext servletContext = getServletContext();
		final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
		templateEngine.process(path, ctx, response.getWriter());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		try {
		
			CustomerOrder order = (CustomerOrder) request.getSession().getAttribute("order");
			User buyer = (User) request.getSession().getAttribute("user");
			boolean success=false;
				
			
			
			success = Boolean.parseBoolean(request.getParameter("success"));
			
			cOrds.addCustomerToOrder(order, buyer);
			cOrds.addCustomerOrder(order);
			
			if (success) {
				order.setValid();
			}
			else {
				order.incrementRejected();
			}
			
			cOrds.addCustomerOrder(order);
			
		} catch (Exception e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", e.getMessage());
			String path = "/WEB-INF/Confirmation.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}
		
		
		request.getSession().removeAttribute("order");
		String path = getServletContext().getContextPath() + "/GoToHomePage";
		response.setContentType("text/html");
		response.sendRedirect(path);

		
		//doGet(request, response);
	}

}
