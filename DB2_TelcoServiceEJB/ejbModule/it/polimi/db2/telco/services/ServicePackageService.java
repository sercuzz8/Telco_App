package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import it.polimi.db2.telco.entities.*;

import java.util.List;
import java.util.Random;

@Stateless
public class ServicePackageService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public ServicePackageService() {}
	
	public ServicePackage createServicePackage(String name) {
		ServicePackage sPackage = new ServicePackage(name);
		return sPackage;
	}
	
	public List<ServicePackage> findAllPackages() /*throws PackageNotFoundException*/{
		//try {
			return em.createNamedQuery("ServicePackage.findAll", ServicePackage.class).setHint("javax.persistence.cache.storeMode", "REFRESH").getResultList();
		/*}
		catch (PersistenceException e){
			throw new PackageNotFoundException("No Package Found");
		}*/
	}
	
	public ServicePackage findPackageById(int packageId) /*throws PackageNotFoundException*/{
		//try {
			return em.find(ServicePackage.class, packageId);
		/*}
		catch (PersistenceException e){
			throw new PackageNotFoundException("No Package Found");
		}*/
	}
	
	public void addServiceToPackage(ServicePackage sPackage, Service service) {
		sPackage.addService(service);
	}
	
	public void addProductToPackage(ServicePackage sPackage, OptionalProduct product) {
		sPackage.addProduct(product);
	}
	
	public void addValidityPeriodToPackage(ServicePackage sPackage, ValidityPeriod vPeriod) {
		sPackage.addValidityPeriod(vPeriod);
	}
	
	public void addServicePackage(ServicePackage sPackage) {
		em.persist(sPackage);
	}
	
	public void updateServicePackage(ServicePackage sPackage) {
		em.merge(sPackage);
	}
}
