package it.polimi.db2.telco.controllers;

import java.io.IOException;
import java.util.List;

import javax.ejb.EJB;
import javax.persistence.NonUniqueResultException;
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
import it.polimi.db2.telco.entities.ServicePackage;
import it.polimi.db2.telco.entities.User;
import it.polimi.db2.telco.exceptions.CredentialsException;
import it.polimi.db2.telco.services.CustomerOrderService;
import it.polimi.db2.telco.services.ServicePackageService;
import it.polimi.db2.telco.services.UserService;


/**
 * Servlet implementation class GoToConfirmationPage
 */
@WebServlet("/GoToConfirmationPage")
public class GoToConfirmationPage extends HttpServlet {
	private static final long serialVersionUID = 1L;
	private TemplateEngine templateEngine;
	
	@EJB(name = "it.polimi.db2.telco.services/CustomerOrderService")
	private CustomerOrderService cOrds;
	
	@EJB(name = "it.polimi.db2.telco.services/ServicePackageService")
	private ServicePackageService sPacks;
	
	@EJB(name = "it.polimi.db2.telco.services/UserService")
	private UserService usrServ;
	
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
				
			
			cOrds.addCustomerToOrder(order, buyer);
			cOrds.updateCustomerOrder(order);
			
			success = Boolean.parseBoolean(request.getParameter("success"));
			
			if (success) {
				order.setValid();
			}
			else {
				order.incrementRejected();
			}
			
			cOrds.updateCustomerOrder(order);
		} 
		
		/*catch (SQLIntegrityConstraintViolationException e) {
			
		}*/
		
		catch (Exception e) {
			ServletContext servletContext = getServletContext();
			final WebContext ctx = new WebContext(request, response, servletContext, request.getLocale());
			request.getSession().removeAttribute("order");
			List<ServicePackage> servicePackages = sPacks.findAllPackages();
			ctx.setVariable("packages", servicePackages);
			ctx.setVariable("errorMsg", "User already bought the package");
			String path = "/WEB-INF/Home.html";
			templateEngine.process(path, ctx, response.getWriter());
			return;
		}
		

		request.getSession().removeAttribute("order");
		User user = (User) request.getSession().getAttribute("user");
		try {
			user = usrServ.checkCredentials(user.getUsername(), user.getPassword());
		} catch (NonUniqueResultException | CredentialsException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		request.getSession().setAttribute("user", user);
		String path = getServletContext().getContextPath() + "/GoToHomePage";
		response.setContentType("text/html");
		response.sendRedirect(path);

	}

}
