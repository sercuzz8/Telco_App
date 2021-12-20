package it.polimi.db2.telco.controllers;

import java.io.IOException;

import javax.ejb.EJB;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import it.polimi.db2.telco.services.*;
import it.polimi.db2.telco.entities.*;

import java.util.List;

import org.apache.commons.lang.StringEscapeUtils;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.WebContext;
import org.thymeleaf.templatemode.TemplateMode;
import org.thymeleaf.templateresolver.ServletContextTemplateResolver;

/**
 * Servlet implementation class GoToHomePageEmployee
 */
@WebServlet("/GoToHomeEmployee")
public class GoToHomeEmployee extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TemplateEngine templateEngine;
	@EJB(name = "it.polimi.db2.telco.services/ServiceService")
	private ServiceService sServ;

	@EJB(name = "it.polimi.db2.telco.services/OptionalProductService")
	private OptionalProductService oProd;

	public GoToHomeEmployee() {
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
		List<Service> services = sServ.findAllServices();
		List<OptionalProduct> products = oProd.findAllProducts();
		String path = "/WEB-INF/HomeEmployee.html";		
		ServletContext servletContext = getServletContext();
		final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
		ctx.setVariable("services", services);
		ctx.setVariable("products", products);
		templateEngine.process(path, ctx, response.getWriter());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		String productName = null;
		String productCost = null;
		/*String start = null;
		String[] prods = null;
		CustomerOrder order = null;*/
		
		
		try {

			
			productName = StringEscapeUtils.escapeJava(request.getParameter("product_name"));
			productCost = StringEscapeUtils.escapeJava(request.getParameter("product_cost"));
			/*start = StringEscapeUtils.escapeJava(request.getParameter("start_date"));
			prods = request.getParameterValues("chosen_products");*/

			if (productName == null || productCost == null || productName.isBlank() || productCost.isBlank()) {
				throw new Exception("Empty fields in creation");
			}


		} catch (Exception e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", e.getMessage());
			String path = "/WEB-INF/Confirmation.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}
		
		oProd.createProduct(productName, Float.parseFloat(productCost));
		
		String path = getServletContext().getContextPath() + "/GoToHomeEmployee";
		response.setContentType("text/html");
		response.sendRedirect(path);

	}

}
