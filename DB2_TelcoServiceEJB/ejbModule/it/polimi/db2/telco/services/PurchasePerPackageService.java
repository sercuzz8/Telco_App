package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class PurchasePerPackageService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public PurchasePerPackageService() {}
	
	public List<PurchasePerPackage> findAllPurchasesForPackage(){
		return em.createNamedQuery("PurchasePerPackage.findAll", PurchasePerPackage.class).getResultList();
	}
	

}