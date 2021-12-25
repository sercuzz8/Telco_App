package it.polimi.db2.telco.entities;

import java.time.LocalDateTime;

import javax.persistence.*;

@Entity
@Table(name="SERVICEACTIVATIONSCHEDULE")
public class SAS {
	
	@Id
	//relationship "has" with user
	@ManyToOne(fetch=FetchType.EAGER)
	@JoinColumn(name="customer")
	private User user;
	
	@Column(name="activationdate")
	private LocalDateTime activationDate;
	@Column(name="deactivationdate")
	private LocalDateTime deactivationDate;
	
	public SAS() {}
	
	public void setUser(User user) {
		this.user = user;
	}
	public void setActivationDate(LocalDateTime ActivationDate) {
		this.activationDate = ActivationDate;
	}
	public void setDeactivationDate(LocalDateTime DeactivationDate) {
		this.deactivationDate = DeactivationDate;
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
