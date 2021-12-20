package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class BestsellerService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public BestsellerService() {}
	
	public List<Bestseller> findAllBestSellers(){
		return em.createNamedQuery("Bestseller.findAll", Bestseller.class).getResultList();
	}
	

}