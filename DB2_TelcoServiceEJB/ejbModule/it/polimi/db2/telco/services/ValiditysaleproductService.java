package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class ValiditysaleproductService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public ValiditysaleproductService() {}
	
	public List<Validitysaleproduct> findAllValiditySaleProduct(){
		return em.createNamedQuery("Validitysaleproduct.findAll", Validitysaleproduct.class).getResultList();
	}
	

}