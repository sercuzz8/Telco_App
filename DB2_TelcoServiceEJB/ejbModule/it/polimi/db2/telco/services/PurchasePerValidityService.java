package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class PurchasePerValidityService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public PurchasePerValidityService() {}
	
	public List<PurchasePerValidity> findAllPackagesValidityPeriods(){
		return em.createNamedQuery("PurchasePerValidity.findAll", PurchasePerValidity.class).getResultList();
	}
	

}