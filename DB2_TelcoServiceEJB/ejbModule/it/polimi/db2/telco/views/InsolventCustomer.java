package it.polimi.db2.telco.views;

import java.io.Serializable;
import java.sql.Time;
import java.time.LocalDate;

import javax.persistence.*;


/**
 * The persistent class for the insolventcustomers database table.
 * 
 */
@Entity
@Table(name="INSOLVENTCUSTOMER")
@NamedQuery(name="InsolventCustomer.findAll", query="SELECT i FROM InsolventCustomer i")
public class InsolventCustomer implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id
	private String insolvent;
	
	@Column(name="alertdate")
	private LocalDate alertDate;
	
	@Column(name="alerttime")
	private Time alertTime;

	private int rejectedOrder;

	public InsolventCustomer() {
	}

	public LocalDate getAlertDate() {
		return this.alertDate;
	}
	
	public Time getAlertTime() {
		return this.alertTime;
	}
	
	public String getInsolvent() {
		return this.insolvent;
	}

	public int getRejectedOrder() {
		return this.rejectedOrder;
	}

}