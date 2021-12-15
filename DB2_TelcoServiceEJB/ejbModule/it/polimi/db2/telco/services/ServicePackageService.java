package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import it.polimi.db2.telco.entities.*;

import java.util.List;

@Stateless
public class ServicePackageService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public ServicePackageService() {}
	
	public void createServicePackage() {
		
	}
	
	public List<ServicePackage> findAllPackages() /*throws PackageNotFoundException*/{
		//try {
			return em.createNamedQuery("ServicePackage.findAll", ServicePackage.class).getResultList();
		/*}
		catch (PersistenceException e){
			throw new PackageNotFoundException("No Package Found");
		}*/
	}
}
