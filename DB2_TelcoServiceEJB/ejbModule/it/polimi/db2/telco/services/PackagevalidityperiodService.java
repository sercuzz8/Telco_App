package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class PackagevalidityperiodService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public PackagevalidityperiodService() {}
	
	public List<Packagevalidityperiod> findAllPackagesValidityPeriods(){
		return em.createNamedQuery("Packagevalidityperiod.findAll", Packagevalidityperiod.class).getResultList();
	}
	

}