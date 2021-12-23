package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class PackageValidityPeriodService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public PackageValidityPeriodService() {}
	
	public List<PackageValidityPeriod> findAllPackagesValidityPeriods(){
		return em.createNamedQuery("PackageValidityPeriod.findAll", PackageValidityPeriod.class).getResultList();
	}
	

}