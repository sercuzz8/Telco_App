package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

import it.polimi.db2.telco.entities.*;
import it.polimi.db2.telco.exeptions.*;

import java.util.List;

@Stateless
public class OptionalProductService {
	@PersistenceContext(unitName="Db2_telco")
	private EntityManager em;
	
	public OptionalProductService() {}
	
	public void createOptionalProduct() {
		
	}
	
}
