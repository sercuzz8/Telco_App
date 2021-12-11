package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import it.polimi.db2.telco.entities.*;
import it.polimi.db2.telco.exceptions.*;

import java.util.List;

@Stateless
public class OptionalProductService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public OptionalProductService() {}
	
	public void createProduct(int id, String name, float monthlyFee) {
		OptionalProduct product=new OptionalProduct(id, name, monthlyFee);
		em.persist(product);
	}
	
}
