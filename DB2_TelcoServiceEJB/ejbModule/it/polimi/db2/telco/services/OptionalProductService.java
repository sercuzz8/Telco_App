package it.polimi.db2.telco.services;

import java.util.List;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import it.polimi.db2.telco.entities.*;

@Stateless
public class OptionalProductService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public OptionalProductService() {}
	
	public List<OptionalProduct> findAllProducts(){
		return em.createNamedQuery("OptionalProduct.findAll", OptionalProduct.class).getResultList();
	}
	
	public OptionalProduct findProductsById(int productId){
		OptionalProduct product = em.find(OptionalProduct.class, productId);
		return product;
	}
	
	public void createProduct(int id, String name, float monthlyFee) {
		OptionalProduct product=new OptionalProduct(id, name, monthlyFee);
		em.persist(product);
	}
}
