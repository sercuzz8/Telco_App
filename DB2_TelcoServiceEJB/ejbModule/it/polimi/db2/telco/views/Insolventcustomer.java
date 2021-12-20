package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;
import java.util.Date;


/**
 * The persistent class for the insolventcustomers database table.
 * 
 */
@Entity
@Table(name="insolventcustomers")
@NamedQuery(name="Insolventcustomer.findAll", query="SELECT i FROM Insolventcustomer i")
public class Insolventcustomer implements Serializable {
	private static final long serialVersionUID = 1L;

	@Temporal(TemporalType.DATE)
	private Date alertDate;
	
	@Id
	private String insolvent;

	private int rejectedOrder;

	public Insolventcustomer() {
	}

	public Date getAlertDate() {
		return this.alertDate;
	}

	public void setAlertDate(Date alertDate) {
		this.alertDate = alertDate;
	}

	public String getInsolvent() {
		return this.insolvent;
	}

	public void setInsolvent(String insolvent) {
		this.insolvent = insolvent;
	}

	public int getRejectedOrder() {
		return this.rejectedOrder;
	}

	public void setRejectedOrder(int rejectedOrder) {
		this.rejectedOrder = rejectedOrder;
	}

}