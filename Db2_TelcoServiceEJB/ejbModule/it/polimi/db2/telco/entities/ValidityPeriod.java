package it.polimi.db2.telco.entities;

import java.io.Serializable;
import java.util.Collection;

import javax.persistence.*;

@Entity
@IdClass(ValidityPeriodId.class)
public class ValidityPeriod implements Serializable{
	
	private static final long serialVersionUID = 1L;
	
	@Id
	@Column(name="packageId")
	private int id;
	@Id
	private int monthsNumber;
	
	private float monthlyFee;
	
	public ValidityPeriod() {}
	
	public void setId(int id) {
		this.id = id;
	}
	public void setMonthsNumber(int mn) {
		this.monthsNumber = mn;
	}
	public void setMonthlyFee(float mf) {
		this.monthlyFee = mf;
	}
	
	public int getId() {
		return this.id;
	}
	public int getMonthsNumber() {
		return this.monthsNumber;
	}
	public float getMonthlyFee() {
		return this.monthlyFee;
	}
	
	//relationship "has" with order
	@OneToMany(fetch=FetchType.LAZY, mappedBy="months")
	private Collection<CustomerOrder> orders;
	
	//relationship "isAssociatedWith"
	@ManyToOne (fetch=FetchType.EAGER)
	@JoinColumn(name="packageId")
	private ServicePackage sPackage;

}
