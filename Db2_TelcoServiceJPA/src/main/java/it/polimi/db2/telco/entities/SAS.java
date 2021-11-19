package it.polimi.db2.telco.entities;

import java.time.LocalDateTime;

import javax.persistence.*;

@Entity
@Table(name="ServiceActivationSchedule")
public class SAS {
	
	@Id
	//relationship "has" with user
	@ManyToOne(fetch=FetchType.EAGER)
	@JoinColumn(name="user")
	private User user;
	
	private LocalDateTime activationDate;
	private LocalDateTime deactivationDate;
	
	public SAS() {}
	
	public void setUser(User u) {
		this.user = u;
	}
	public void setActivationDate(LocalDateTime ad) {
		this.activationDate = ad;
	}
	public void setDeactivationDate(LocalDateTime dd) {
		this.deactivationDate = dd;
	}
	
	public User getUser() {
		return this.user;
	}
	public LocalDateTime getActivationDate() {
		return this.activationDate;
	}
	public LocalDateTime getDeactivationDate() {
		return this.deactivationDate;
	}
}
