package project.entities;

import java.util.Collection;

import javax.persistence.*;
import jakarta.persistence.NamedQuery;

@Entity

@NamedQuery (name = "User.checkCredentials", query = "SELECT u FROM User u WHERE u.username=?1 AND u.password=?2")
@NamedQuery(name = "User.rejectedOrders", query = "SELECT o FROM Order o WHERE o.rejected=true AND u.user=?1")
public class User {
	@Id
	private String username;
	
	private String email;
	private String password;
	private boolean insolvent;
	
	public User() {};
	public User(String username, String password, String email) {
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
	
	//relationship "has" with ServiceActivationSchedule
	@OneToMany(fetch=FetchType.LAZY, mappedBy = "user")
	private Collection<SAS> serviceActivationSchedules;
	
	//relationship "has" with AuditingTable
	@OneToOne(fetch=FetchType.LAZY, mappedBy="user")
	private AuditingTable alert;
}
