package it.polimi.db2.telco.controllers;

import java.io.IOException;
import java.io.PrintWriter;
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

import it.polimi.db2.telco.entities.ServicePackage;
import it.polimi.db2.telco.entities.User;
import it.polimi.db2.telco.exceptions.CredentialsException;
import it.polimi.db2.telco.services.CustomerOrderService;
import it.polimi.db2.telco.services.ServicePackageService;

/**
 * Servlet implementation class GoToBuyPage
 */
@WebServlet("/GoToBuyPage")
public class GoToBuyPage extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TemplateEngine templateEngine;
	@EJB(name = "it.polimi.db2.telco.services/ServicePackageService")
	private ServicePackageService sPacks;
	@EJB(name = "it.polimi.db2.telco.services/CustomerOrderService")
	private CustomerOrderService cOrds;
	
	String pack = null;
	String months = null;
	String start = null;
       
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
		List<ServicePackage> servicePackages = sPacks.findAllPackages();
		String path = "/WEB-INF/BuyPage.html";
		ServletContext servletContext = getServletContext();
		final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
		if (this.pack==null) {
		ctx.setVariable("packages", servicePackages);
		}
		else {
		ctx.setVariable("products", sPacks.findPackageById(Integer.parseInt(this.pack)).getProducts());
		}
		templateEngine.process(path, ctx, response.getWriter());
	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		try {
			this.pack = StringEscapeUtils.escapeJava(request.getParameter("pack_id"));
			this.months = StringEscapeUtils.escapeJava(request.getParameter("num_months"));
			this.start = StringEscapeUtils.escapeJava(request.getParameter("start_date"));
			
			System.out.println(pack);
			System.out.println(months);
			System.out.println(start);
			
			if (pack == null || months == null || start == null 
					|| pack.isBlank() || months.isBlank() || start.isBlank()) {
				throw new Exception("Empty fields in order");
			}
			
		} catch (Exception e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			ctx.setVariable("errorMsg", "Empty fields in order");
			String path = "/WEB-INF/BuyPage.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}
		
		String path = getServletContext().getContextPath() + "/GoToBuyPage";
		response.setContentType("text/html");
		response.sendRedirect(path);
		
	}

}