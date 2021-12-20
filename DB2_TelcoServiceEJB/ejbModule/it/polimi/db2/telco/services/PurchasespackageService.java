package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class PurchasespackageService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public PurchasespackageService() {}
	
	public List<Purchasespackage> findAllPurchasesForPackage(){
		return em.createNamedQuery("Purchasespackage.findAll", Purchasespackage.class).getResultList();
	}
	

}