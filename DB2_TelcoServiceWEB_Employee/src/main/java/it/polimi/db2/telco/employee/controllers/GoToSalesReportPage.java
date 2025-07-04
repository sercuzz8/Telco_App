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
import it.polimi.db2.telco.views.*;
import java.util.List;
import org.thymeleaf.TemplateEngine;
import org.thymeleaf.context.WebContext;
import org.thymeleaf.templatemode.TemplateMode;
import org.thymeleaf.templateresolver.ServletContextTemplateResolver;

/**
 * Servlet implementation class GoToSalesReportPage
 */
@WebServlet("/GoToSalesReportPage")
public class GoToSalesReportPage extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TemplateEngine templateEngine;

	@EJB(name = "it.polimi.db2.telco.services/PurchasePerPackageService")
	private PurchasePerPackageService purPackSer;
	@EJB(name = "it.polimi.db2.telco.services/PurchasePerValidityService")
	private PurchasePerValidityService packVal;
	@EJB(name = "it.polimi.db2.telco.services/SalePerPackageService")
	private SalePerPackageService valSaleProd;
	@EJB(name = "it.polimi.db2.telco.services/AverageProductSoldService")
	private AverageProductSoldService avgProd;
	@EJB(name = "it.polimi.db2.telco.services/InsolventCustomerService")
	private InsolventCustomerService insCust;
	@EJB(name = "it.polimi.db2.telco.services/BestSellerService")
	private BestSellerService bestSell;
	

	public GoToSalesReportPage() {
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
		
		List<PurchasePerPackage> purchases_package = purPackSer.findAllPurchasesForPackage();
		List<PurchasePerValidity> purchases_validity = packVal.findAllPackagesValidityPeriods();
		List<SalePerPackage> validity_sale = valSaleProd.findAllValiditySaleProduct();
		List<AverageProductSold> avg_product = avgProd.findAllAVGProductsSold();
		List<InsolventCustomer> insolvent_customer = insCust.findAllInsolventCustomers();
		List<BestSeller> best_seller = bestSell.findAllBestSellers();
		
		path = "/WEB-INF/SalesReport.html";		
		
		ServletContext servletContext = getServletContext();
		final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
		
		ctx.setVariable("purchases_package_view", purchases_package);
		ctx.setVariable("purchases_validity_view", purchases_validity);
		ctx.setVariable("validity_sale_view", validity_sale);
		ctx.setVariable("average_product_view", avg_product);
		ctx.setVariable("insolvent_customer_view", insolvent_customer);
		ctx.setVariable("best_seller_view", best_seller);
		
		templateEngine.process(path, ctx, response.getWriter());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		
		doGet(request, response);
	}

}
