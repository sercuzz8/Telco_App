package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import it.polimi.db2.telco.entities.*;

import java.util.List;

@Stateless
public class CustomerOrderService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public CustomerOrderService() {}
	
	public List<CustomerOrder> findRejectedOrdersOfUser(String usrn){
		return em.createNamedQuery("Order.findRejectedOrderOfUser", CustomerOrder.class).setParameter(1, usrn).getResultList();
	}
	
	public void createCustomerOrder() {
		
	}
}
