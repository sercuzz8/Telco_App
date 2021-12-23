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

	@EJB(name = "it.polimi.db2.telco.services/PurchasespackageService")
	private PurchasespackageService purPackSer;
	@EJB(name = "it.polimi.db2.telco.services/PackagevalidityperiodService")
	private PackagevalidityperiodService packVal;
	@EJB(name = "it.polimi.db2.telco.services/ValiditysaleproductService")
	private ValiditysaleproductService valSaleProd;
	@EJB(name = "it.polimi.db2.telco.services/AvgproductsoldService")
	private AvgproductsoldService avgProd;
	@EJB(name = "it.polimi.db2.telco.services/InsolventcustomerService")
	private InsolventcustomerService insCust;
	@EJB(name = "it.polimi.db2.telco.services/BestsellerService")
	private BestsellerService bestSell;
	

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
		List<Purchasespackage> purchases_package = purPackSer.findAllPurchasesForPackage();
		List<Packagevalidityperiod> purchases_validity = packVal.findAllPackagesValidityPeriods();
		List<Validitysaleproduct> validity_sale = valSaleProd.findAllValiditySaleProduct();
		List<Averageproductsold> avg_product = avgProd.findAllAVGProductsSold();
		List<Insolventcustomer> insolvent_customer = insCust.findAllInsolventCustomers();
		List<Bestseller> best_seller = bestSell.findAllBestSellers();
		String path = "/WEB-INF/SalesReport.html";		
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
