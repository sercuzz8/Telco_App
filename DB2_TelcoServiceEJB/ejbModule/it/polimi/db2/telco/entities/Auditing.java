package it.polimi.db2.telco.entities;

import java.time.LocalDate;
import java.time.LocalTime;

import javax.persistence.*;

@Entity
@Table(name="AUDITING")
public class Auditing {
	
	@Id
	@OneToOne
	@PrimaryKeyJoinColumn(referencedColumnName="username")
	private User user;
	
	private String email;
	private float lastRejectionamount;
	private LocalDate lastRejectiondate;
	private LocalTime lastRejectiontime;
	
	public Auditing() {}
	
	public void setUser(User u) {
		this.user = u;
	}
	public void setEmail(String email) {
		this.email = user.getEmail();
	}
	public void setLastRejectionAmount(float lra) {
		this.lastRejectionamount = lra;
	}
	public void setLastRejectionDate(LocalDate lrd) {
		this.lastRejectiondate = lrd;
	}
	public void setLastRejectionTime(LocalTime lrt) {
		this.lastRejectiontime = lrt;
	}
	
	public User getUser() {
		return this.user;
	}
	
	public String getEmail() {
		return this.email;
	}
	
	public float getLastRejectionAmount() {
		return this.lastRejectionamount;
	}
	public LocalDate getLastRejectionDate() {
		return this.lastRejectiondate;
	}
	public LocalTime getLastRejectionTime() {
		return this.lastRejectiontime;
	}

}
