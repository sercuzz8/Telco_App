package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class ValiditySaleProductService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public ValiditySaleProductService() {}
	
	public List<ValiditySaleProduct> findAllValiditySaleProduct(){
		return em.createNamedQuery("ValiditySaleProduct.findAll", ValiditySaleProduct.class).getResultList();
	}
	

}