package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class AverageProductSoldService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public AverageProductSoldService() {}
	
	public List<AverageProductSold> findAllAVGProductsSold(){
		return em.createNamedQuery("AverageProductSold.findAll", AverageProductSold.class).getResultList();
	}
	

}
