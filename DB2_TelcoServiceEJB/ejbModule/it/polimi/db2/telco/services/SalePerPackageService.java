package it.polimi.db2.telco.services;

import it.polimi.db2.telco.views.*;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

@Stateless
public class SalePerPackageService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public SalePerPackageService() {}
	
	public List<SalePerPackage> findAllValiditySaleProduct(){
		return em.createNamedQuery("SalePerPackage.findAll", SalePerPackage.class).getResultList();
	}
	

}