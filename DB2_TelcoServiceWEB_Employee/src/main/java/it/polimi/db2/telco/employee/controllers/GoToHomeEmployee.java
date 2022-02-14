package it.polimi.db2.telco.employee.controllers;

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
		
		List<ServicePackage> packages = sPack.findAllPackages();
		List<Service> services = sServ.findAllServices();
		List<OptionalProduct> products = oProd.findAllProducts();
		path = "/WEB-INF/HomeEmployee.html";		
		ServletContext servletContext = getServletContext();
		final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
		ctx.setVariable("packages", packages);
		ctx.setVariable("services", services);
		ctx.setVariable("products", products);
		templateEngine.process(path, ctx, response.getWriter());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {			
		
		
		if(request.getParameter("pageName").equals("create_product"))
		{
			
			String productName = null;
			String productCost = null;
			
			try {
			productName = StringEscapeUtils.escapeJava(request.getParameter("product_name"));
			productCost = StringEscapeUtils.escapeJava(request.getParameter("product_cost"));
			
			if (productName == null || productCost == null || productName.isBlank() || productCost.isBlank()) {
				throw new Exception("Missing or empty product value");
			}
			
			}
			catch (Exception e) {
				List<ServicePackage> packages = sPack.findAllPackages();
				List<Service> services = sServ.findAllServices();
				List<OptionalProduct> products = oProd.findAllProducts();
				ServletContext servletContext = getServletContext();
				final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
				ctx.setVariable("errorMsgProduct", e.getMessage());
				ctx.setVariable("packages", packages);				
				ctx.setVariable("services", services);
				ctx.setVariable("products", products);
				String path = "/WEB-INF/HomeEmployee.html";
				templateEngine.process(path, ctx, response.getWriter());
				return;
			}
			
			oProd.createProduct(productName, Float.parseFloat(productCost));
		}
		else if(request.getParameter("pageName").equals("create_package"))
		{
			try {
				String packageName = StringEscapeUtils.escapeJava(request.getParameter("package_name"));
				String packageCostTwelve = StringEscapeUtils.escapeJava(request.getParameter("package_cost_twelve"));
				String packageCostTwentyFour = StringEscapeUtils.escapeJava(request.getParameter("package_cost_twentyfour"));
				String packageCostThirtySix = StringEscapeUtils.escapeJava(request.getParameter("package_cost_thirtysix"));
				String[] servs=request.getParameterValues("chosen_services");
				String[] prods=request.getParameterValues("chosen_products");
				
				ServicePackage sPackage = sPack.createServicePackage(packageName);
				
				sPack.addServicePackage(sPackage);
				
				for (String s: servs) {
					sPack.addServiceToPackage(sPackage, sServ.findServicebyId(Integer.parseInt(s)));
				}
				
				sPack.addValidityPeriodToPackage(sPackage, vPer.createValidityPeriod(sPackage, 12, Float.parseFloat(packageCostTwelve)));
				sPack.addValidityPeriodToPackage(sPackage, vPer.createValidityPeriod(sPackage, 24, Float.parseFloat(packageCostTwentyFour)));
				sPack.addValidityPeriodToPackage(sPackage, vPer.createValidityPeriod(sPackage, 36, Float.parseFloat(packageCostThirtySix)));
				
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
					List<ServicePackage> packages = sPack.findAllPackages();
					List<Service> services = sServ.findAllServices();
					List<OptionalProduct> products = oProd.findAllProducts();
					ServletContext servletContext = getServletContext();
					final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
					ctx.setVariable("errorMsgPackage", e.getMessage());
					ctx.setVariable("packages", packages);				
					ctx.setVariable("services", services);
					ctx.setVariable("products", products);
					String path = "/WEB-INF/HomeEmployee.html";
					templateEngine.process(path, ctx, response.getWriter());
					return;
				}
		}
				
		String path = getServletContext().getContextPath() + "/GoToHomeEmployee";
		response.setContentType("text/html");
		response.sendRedirect(path);

	}

}
