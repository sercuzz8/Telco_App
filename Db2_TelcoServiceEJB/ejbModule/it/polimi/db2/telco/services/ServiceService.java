package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import it.polimi.db2.telco.entities.*;

import java.util.List;

@Stateless
public class ServiceService {
	@PersistenceContext(unitName="Db2_telco")
	private EntityManager em;
	
	public ServiceService() {}
	
	public List<Service> findAllServices(){
		return em.createNamedQuery("Service.findAll", Service.class).getResultList();
	}
	
	public Service findServicebyId(int serviceId){
		Service service = em.find(Service.class, serviceId);
		return service;
	}
}
