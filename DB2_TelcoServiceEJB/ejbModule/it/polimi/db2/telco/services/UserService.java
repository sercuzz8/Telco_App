
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
public class UserService {
	@PersistenceContext(unitName="DB2_TelcoServiceEJB")
	private EntityManager em;
	
	public UserService() {}
	
	public User checkCredentials(String name, String pwd) throws CredentialsException, NonUniqueResultException {
		List<User> userList = null;
		try {
			userList = em.createNamedQuery("User.checkCredentials", User.class).setParameter(1, name).setParameter(2, pwd)
					.getResultList();
		} catch (PersistenceException e) {
			throw new CredentialsException("Impossible to verify credentials");
		}
		if (userList.isEmpty())
			return null;
		else if (userList.size() == 1)
			return userList.get(0);
		throw new NonUniqueResultException("More users registered");

	}

	public User addUser(String name, String email, String pwd) {
		User user = new User(name, email, pwd);
		em.persist(user);
		return user;
	}
	
	
	
}
