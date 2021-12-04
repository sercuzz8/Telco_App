package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import it.polimi.db2.telco.entities.*;

import java.util.List;

@Stateless
public class CustomerOrderService {
	@PersistenceContext(unitName="Db2_telco")
	private EntityManager em;
	
	public CustomerOrderService() {}
	
	public List<CustomerOrder> findRejectedOrdersOfUser(String usrn){
		return em.createNamedQuery("CustomerOrder.findRejectedOrderOfUser", CustomerOrder.class).setParameter(1, usrn).getResultList();
	}
	
	public void createCustomerOrder() {
		
	}
}
