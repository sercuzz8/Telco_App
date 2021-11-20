package it.polimi.db2.telco.entities;

import java.time.LocalDate;
import java.time.LocalTime;

import javax.persistence.*;

@Entity
public class Auditing {
	
	@Id
	@OneToOne
	@PrimaryKeyJoinColumn(referencedColumnName="username")
	private User user;
	
	private String email;
	private float lastRejectionAmount;
	private LocalDate lastRejectionDate;
	private LocalTime lastRejectionTime;
	
	public Auditing() {}
	
	public void setUser(User u) {
		this.user = u;
	}
	public void setEmail(String email) {
		this.email = user.getEmail();
	}
	public void setLastRejectionAmount(float lra) {
		this.lastRejectionAmount = lra;
	}
	public void setLastRejectionDate(LocalDate lrd) {
		this.lastRejectionDate = lrd;
	}
	public void setLastRejectionTime(LocalTime lrt) {
		this.lastRejectionTime = lrt;
	}
	
	public User getUser() {
		return this.user;
	}
	
	public String getEmail() {
		return this.email;
	}
	
	public float getLastRejectionAmount() {
		return this.lastRejectionAmount;
	}
	public LocalDate getLastRejectionDate() {
		return this.lastRejectionDate;
	}
	public LocalTime getLastRejectionTime() {
		return this.lastRejectionTime;
	}

}
