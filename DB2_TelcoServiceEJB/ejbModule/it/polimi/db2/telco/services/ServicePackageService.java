package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.PersistenceException;

import it.polimi.db2.telco.entities.*;
import it.polimi.db2.telco.exceptions.PackageNotFoundException;

import java.util.List;

@Stateless
public class ServicePackageService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public ServicePackageService() {}
	
	public List<ServicePackage> findAllPackages() /*throws PackageNotFoundException*/{
		//try {
        	System.out.println("PROVA: " + em.createNamedQuery("ServicePackage.findAll", ServicePackage.class).getResultList()); 
			return em.createNamedQuery("ServicePackage.findAll", ServicePackage.class).getResultList();
		/*}
		catch (PersistenceException e){
			throw new PackageNotFoundException("No Package Found");
		}*/
	}
	
	public void createServicePackage() {
		
	}
}
