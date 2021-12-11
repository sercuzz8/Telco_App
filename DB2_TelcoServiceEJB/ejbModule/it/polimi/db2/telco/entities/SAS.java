package it.polimi.db2.telco.entities;

import java.time.LocalDateTime;

import javax.persistence.*;

@Entity
@Table(name="SERVICEACTIVATIONSCHEDULE")
public class SAS {
	
	@Id
	//relationship "has" with user
	@ManyToOne(fetch=FetchType.EAGER)
	@JoinColumn(name="user")
	private User user;
	
	private LocalDateTime activationdate;
	private LocalDateTime deactivationdate;
	
	public SAS() {}
	
	public void setUser(User u) {
		this.user = u;
	}
	public void setActivationDate(LocalDateTime ad) {
		this.activationdate = ad;
	}
	public void setDeactivationDate(LocalDateTime dd) {
		this.deactivationdate = dd;
	}
	
	public User getUser() {
		return this.user;
	}
	public LocalDateTime getActivationDate() {
		return this.activationdate;
	}
	public LocalDateTime getDeactivationDate() {
		return this.deactivationdate;
	}
}
