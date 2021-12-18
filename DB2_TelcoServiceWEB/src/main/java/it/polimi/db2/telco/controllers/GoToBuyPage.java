package it.polimi.db2.telco.controllers;

import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

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

import it.polimi.db2.telco.entities.CustomerOrder;
import it.polimi.db2.telco.entities.OptionalProduct;
import it.polimi.db2.telco.entities.ServicePackage;
import it.polimi.db2.telco.entities.User;
import it.polimi.db2.telco.entities.ValidityPeriod;
import it.polimi.db2.telco.exceptions.CredentialsException;
import it.polimi.db2.telco.services.CustomerOrderService;
import it.polimi.db2.telco.services.OptionalProductService;
import it.polimi.db2.telco.services.ServicePackageService;
import it.polimi.db2.telco.services.ValidityPeriodService;

/**
 * Servlet implementation class GoToBuyPage
 */
@WebServlet("/GoToBuyPage")
public class GoToBuyPage extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TemplateEngine templateEngine;
	
	@EJB(name = "it.polimi.db2.telco.services/ServicePackageService")
	private ServicePackageService sPacks;
	@EJB(name = "it.polimi.db2.telco.services/OptionalProductService")
	private OptionalProductService oProds;
	@EJB(name = "it.polimi.db2.telco.services/CustomerOrderService")
	private CustomerOrderService cOrds;
	@EJB(name = "it.polimi.db2.telco.services/ValidityPeriodService")
	private ValidityPeriodService vPers;

	/**
	 * @see HttpServlet#HttpServlet()
	 */
	public GoToBuyPage() {
		super();
		// TODO Auto-generated constructor stub
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
		List<OptionalProduct> optionalProducts = oProds.findAllProducts();
		String path = "/WEB-INF/Buy.html";
		ServletContext servletContext = getServletContext();
		final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
		request.getSession().setAttribute("products", optionalProducts);
		templateEngine.process(path, ctx, response.getWriter());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		String pack = null;
		String months = null;
		String start = null;
		String[] prods = null;
		CustomerOrder order = null;
		
		
		try {

			
			pack = StringEscapeUtils.escapeJava(request.getParameter("chosen_pack"));
			months = StringEscapeUtils.escapeJava(request.getParameter("chosen_months"));
			start = StringEscapeUtils.escapeJava(request.getParameter("start_date"));
			prods = request.getParameterValues("chosen_products");

			if (pack == null || months == null || start == null || pack.isBlank() || months.isBlank()
					|| start.isBlank()) {
				throw new Exception("Empty fields in order");
			}

			Collection<OptionalProduct> rightProducts = sPacks.findPackageById(Integer.parseInt(pack)).getProducts();
			
			List<Integer> rightId=new ArrayList<>();
			
			for (OptionalProduct o: rightProducts) {
				rightId.add(o.getId());
			}
			
			
			try {
				for (String p : prods) {
					if (!rightId.contains(Integer.parseInt(p))) {
						throw new Exception("Product not offered in package");
					}
				}
			} catch (NullPointerException e) {
				// No problem, the user simply did not choose any product
			}

		} catch (Exception e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", e.getMessage());
			String path = "/WEB-INF/Buy.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}
		
		ServicePackage sPack =sPacks.findPackageById(Integer.parseInt(pack));
		ValidityPeriod vPer=vPers.findPeriod(sPack, Integer.parseInt(months)).get(0);

		order=cOrds.createCustomerOrder(LocalDate.now(), LocalTime.now(), LocalDate.parse(start), vPer);
		
		for (String p : prods) {
			cOrds.addProductToOrder(order, oProds.findProductsById(Integer.parseInt(p)));
		}
		
		order.computeTotalValue();
		
		request.getSession().setAttribute("order", order);
		String path = getServletContext().getContextPath() + "/GoToConfirmationPage";
		response.setContentType("text/html");
		response.sendRedirect(path);

	}

}