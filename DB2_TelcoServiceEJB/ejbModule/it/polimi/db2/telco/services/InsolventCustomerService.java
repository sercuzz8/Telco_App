package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class InsolventCustomerService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public InsolventCustomerService() {}
	
	public List<InsolventCustomer> findAllInsolventCustomers(){
		return em.createNamedQuery("InsolventCustomer.findAll", InsolventCustomer.class).getResultList();
	}
	

}