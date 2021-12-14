package it.polimi.db2.telco.entities;

import java.util.ArrayList;
import java.util.Collection;

import javax.persistence.*;

@Entity
@Table(name="CUSTOMER")
@NamedQuery (name = "User.checkCredentials", query = "SELECT u FROM User u WHERE u.username=?1 AND u.password=?2")
@NamedQuery(name = "User.rejectedOrders", query = "SELECT o FROM CustomerOrder o WHERE o.rejected=true AND o.user=?1")
public class User {
	@Id
	private String username;
	
	private String email;
	private String password;
	private boolean insolvent;
	
	@OneToMany(fetch=FetchType.EAGER, mappedBy="user")
	private Collection<CustomerOrder> orders;
	
	public User() {};
	public User(String username, String email, String password) {
		this.username = username;
		this.email = email;
		this.password = password;
		this.insolvent = false;
	}
	
	public void setUsername(String username) {
		this.username = username;
	}
	
	public String getUsername() {
		return this.username;
	}
	
	public void setEmail(String email) {
		this.email = email;
	}
	
	public String getEmail() {
		return this.email;
	}
	
	public void setPassword(String password) {
		this.password = password;
	}
	
	public String getPassword() {
		return this.password;
	}
	
	public void setInsolvent(boolean x) {
		this.insolvent = x;
	}
	
	public boolean getInsolvent() {
		return this.insolvent;
	}
	
	public Collection<CustomerOrder> getOrders() {
		return orders;
	}
	
	public void setOrders(Collection<CustomerOrder> orders) {
		this.orders = orders;
	}
	
	public Collection<CustomerOrder> getRejectedOrders() {
		if (!this.getInsolvent()) return null;
		else {
			
			Collection<CustomerOrder> results = new ArrayList<>();
			
			for (CustomerOrder order: this.getOrders()) {
				if (order.getRejected()>0) 
					results.add(order);
				}
			
			return results;
		}
	}
}
