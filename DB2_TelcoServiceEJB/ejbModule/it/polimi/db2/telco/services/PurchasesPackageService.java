package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class PurchasesPackageService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public PurchasesPackageService() {}
	
	public List<PurchasesPackage> findAllPurchasesForPackage(){
		return em.createNamedQuery("PurchasesPackage.findAll", PurchasesPackage.class).getResultList();
	}
	

}