package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import it.polimi.db2.telco.entities.*;

import java.util.List;

@Stateless
public class ValidityPeriodService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public ValidityPeriodService() {}
	
	public List<ValidityPeriod> findPeriodsByPackage(int packageId){
		return em.createNamedQuery("ValidityPeriod.findAll", ValidityPeriod.class).setParameter(1, packageId).getResultList();
	} 
	
	
	public void createValidityPeriod() {
		
	}
}
