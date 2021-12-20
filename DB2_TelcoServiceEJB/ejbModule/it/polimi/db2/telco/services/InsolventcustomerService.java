package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class InsolventcustomerService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public InsolventcustomerService() {}
	
	public List<Insolventcustomer> findAllInsolventCustomers(){
		return em.createNamedQuery("Insolventcustomer.findAll", Insolventcustomer.class).getResultList();
	}
	

}