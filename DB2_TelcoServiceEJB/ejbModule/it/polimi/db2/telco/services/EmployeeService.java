package it.polimi.db2.telco.services;

import javax.ejb.Stateless;
import javax.persistence.EntityManager;
import javax.persistence.NonUniqueResultException;
import javax.persistence.PersistenceContext;
import javax.persistence.PersistenceException;

import it.polimi.db2.telco.entities.*;
import it.polimi.db2.telco.exceptions.*;

import java.util.List;

@Stateless
public class EmployeeService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public EmployeeService() {}
	
	public Employee checkCredentials(String code, String pwd) throws CredentialsException, NonUniqueResultException {
		List<Employee> EmployeeList = null;
		try {
			EmployeeList = em.createNamedQuery("Employee.checkCredentials", Employee.class).setParameter(1, code).setParameter(2, pwd)
					.getResultList();
		} catch (PersistenceException e) {
			throw new CredentialsException("Impossible to verify credentials");
		}
		if (EmployeeList.isEmpty())
			return null;
		else if (EmployeeList.size() == 1)
			return EmployeeList.get(0);
		throw new NonUniqueResultException("More employees registered");

	}
	
}
