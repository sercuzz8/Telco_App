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
	
	public List<ValidityPeriod> findPeriod(ServicePackage packageId, int monthsNumber){
		return em.createNamedQuery("ValidityPeriod.findValidity", ValidityPeriod.class).setParameter(1, packageId).setParameter(2, monthsNumber).getResultList();
	} 
	
	public List<ValidityPeriod> findAllPeriods(){
		return em.createNamedQuery("ValidityPeriod.findAll", ValidityPeriod.class).getResultList();
	} 
	
	
	public void createValidityPeriod() {
		
	}
}
