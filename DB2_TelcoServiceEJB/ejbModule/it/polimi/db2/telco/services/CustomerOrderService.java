package it.polimi.db2.telco.services;

import javax.ejb.Stateful;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import it.polimi.db2.telco.entities.*;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Random;

@Stateful
public class CustomerOrderService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public CustomerOrderService() {}
	
	public CustomerOrder findById(int id) {
		return em.find(CustomerOrder.class, id);
	}
	
	public List<CustomerOrder> findRejectedOrdersOfUser(String usrn){
		return em.createNamedQuery("Order.findRejectedOrderOfUser", CustomerOrder.class).setParameter(1, usrn).getResultList();
	}
	
	public CustomerOrder createCustomerOrder(LocalDate dateOrder, LocalTime hourOrder, LocalDate startSubscription, ValidityPeriod validityPeriod) {
		Random rand = new Random();
		int n = rand.nextInt(1000);
		CustomerOrder customerOrder = new CustomerOrder(n, dateOrder, hourOrder, startSubscription, validityPeriod);
		return customerOrder;
	}	
	
	public void addCustomerToOrder(CustomerOrder customerOrder, User user) {
		customerOrder.setUser(user);
	}
	
	public void addProductToOrder(CustomerOrder customerOrder, OptionalProduct product) {
		customerOrder.addProduct(product);
	}

	public void addCustomerOrder(CustomerOrder customerOrder) {
		em.merge(customerOrder);
	}
	
	
	
}
