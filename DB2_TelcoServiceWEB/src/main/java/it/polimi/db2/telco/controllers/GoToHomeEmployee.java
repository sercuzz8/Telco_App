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
	
	@EJB(name = "it.polimi.db2.telco.services/ServicePackageService")
	private ServicePackageService sPack;

	@EJB(name = "it.polimi.db2.telco.services/ValidityPeriodService")
	private ValidityPeriodService vPer;
	
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
		
		String path=null;
		
		if (request.getSession().getAttribute("user")!=null) {
			path = getServletContext().getContextPath() + "/GoToHomePage";
			response.sendRedirect(path);
			return;
		}
		
		List<Service> services = sServ.findAllServices();
		List<OptionalProduct> products = oProd.findAllProducts();
		path = "/WEB-INF/HomeEmployee.html";		
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
		
		String packageName = null;
		String packageCostTwelve = null;		
		String packageCostTwentyFour = null;	
		String packageCostThirtySix = null;	
		String[] servs = null;
		String[] prods = null;
		
		ServicePackage sPackage = null;
		
		ValidityPeriod shortPeriod = null;
		ValidityPeriod mediumPeriod = null;
		ValidityPeriod longPeriod = null;

				
		try {
			
			productName = StringEscapeUtils.escapeJava(request.getParameter("product_name"));
			productCost = StringEscapeUtils.escapeJava(request.getParameter("product_cost"));
			

			if (productName == null || productCost == null || productName.isBlank() || productCost.isBlank()) {
				
				try {
				packageName = StringEscapeUtils.escapeJava(request.getParameter("package_name"));
				packageCostTwelve = StringEscapeUtils.escapeJava(request.getParameter("package_cost_twelve"));
				packageCostTwentyFour = StringEscapeUtils.escapeJava(request.getParameter("package_cost_twentyfour"));
				packageCostThirtySix = StringEscapeUtils.escapeJava(request.getParameter("package_cost_thirtysix"));
				servs=request.getParameterValues("chosen_services");
				prods=request.getParameterValues("chosen_products");
				
				if (packageName==null || packageCostTwelve==null || packageCostTwentyFour==null || packageCostThirtySix==null || servs==null ||
						packageName.isBlank() || packageCostTwelve.isBlank() || packageCostTwentyFour.isBlank() || packageCostThirtySix.isBlank()) {
					throw new Exception("Empty fields in creation");
				}
				
				sPackage = sPack.createServicePackage(packageName);
				
				sPack.addServicePackage(sPackage);
				
				for (String s: servs) {
					sPack.addServiceToPackage(sPackage, sServ.findServicebyId(Integer.parseInt(s)));
				}
				
				
				
				shortPeriod = vPer.createValidityPeriod(sPackage, 12, Float.parseFloat(packageCostTwelve));
				mediumPeriod = vPer.createValidityPeriod(sPackage, 24, Float.parseFloat(packageCostTwentyFour));
				longPeriod = vPer.createValidityPeriod(sPackage, 36, Float.parseFloat(packageCostThirtySix));
				
				sPack.addValidityPeriodToPackage(sPackage, shortPeriod);
				sPack.addValidityPeriodToPackage(sPackage, mediumPeriod);
				sPack.addValidityPeriodToPackage(sPackage, longPeriod);
				
				sPack.updateServicePackage(sPackage);
				
				try {
					for (String p : prods) {
						sPack.addProductToPackage(sPackage, oProd.findProductsById(Integer.parseInt(p)));
					}
				}
				catch(NullPointerException e) {
					
				}
				
				sPack.updateServicePackage(sPackage);
				
				}
				catch(Exception e) {
					
					List<Service> services = sServ.findAllServices();
					List<OptionalProduct> products = oProd.findAllProducts();
					ServletContext servletContext = getServletContext();
					final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
					ctx.setVariable("errorMsg", e.getMessage());
					ctx.setVariable("services", services);
					ctx.setVariable("products", products);
					String path = "/WEB-INF/HomeEmployee.html";
					templateEngine.process(path, ctx, response.getWriter());
					return;
				}
			}
			
			oProd.createProduct(productName, Float.parseFloat(productCost));

		} catch (Exception e) {
			List<Service> services = sServ.findAllServices();
			List<OptionalProduct> products = oProd.findAllProducts();
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", e.getMessage());
			ctx.setVariable("services", services);
			ctx.setVariable("products", products);
			String path = "/WEB-INF/HomeEmployee.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}
		
		
		String path = getServletContext().getContextPath() + "/GoToHomeEmployee";
		response.setContentType("text/html");
		response.sendRedirect(path);

	}

}
