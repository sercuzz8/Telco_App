package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class BestSellerService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public BestSellerService() {}
	
	public List<BestSeller> findAllBestSellers(){
		return em.createNamedQuery("BestSeller.findAll", BestSeller.class).getResultList();
	}
	

}