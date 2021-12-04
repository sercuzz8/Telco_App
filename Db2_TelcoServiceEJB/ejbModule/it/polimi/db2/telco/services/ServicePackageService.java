package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import it.polimi.db2.telco.entities.*;

import java.util.List;

@Stateless
public class ServicePackageService {
	@PersistenceContext(unitName="Db2_telco")
	private EntityManager em;
	
	public ServicePackageService() {}
	
	public List<ServicePackage> findAllPackages(){
		return em.createNamedQuery("ServicePackage.findAll", ServicePackage.class).getResultList();
	}
	
	public void createServicePackage() {
		
	}
}
