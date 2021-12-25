package it.polimi.db2.telco.entities;

import javax.persistence.*;

@Entity
@Table(name="VALIDITYPERIOD")
@IdClass(ValidityPeriodId.class)
@NamedQuery(name="ValidityPeriod.findAll", query="SELECT v FROM ValidityPeriod v")
@NamedQuery(name="ValidityPeriod.findValidity", query="SELECT v FROM ValidityPeriod v WHERE v.sPackage=?1 AND v.monthsNumber=?2 ORDER BY v.monthsNumber ASC")
public class ValidityPeriod {
	
	@Id
	@ManyToOne
	@JoinColumn(name="package", referencedColumnName="id")
	private ServicePackage sPackage;
	@Id
	@Column(name="monthsnumber")
	private int monthsNumber;
	
	@Column(name="monthlyfee")
	private float monthlyFee;
	
	public ValidityPeriod() {}
	
	public ValidityPeriod(ServicePackage sPackage, int monthsNumber, float monthlyFee) {
		this.sPackage=sPackage;
		this.monthsNumber=monthsNumber;
		this.monthlyFee=monthlyFee;
	}
	
	public void setPackage(ServicePackage id) {
		this.sPackage = id;
	}
	public void setMonthsNumber(int monthsNumber) {
		this.monthsNumber = monthsNumber;
	}
	public void setMonthlyFee(float monthlyFee) {
		this.monthlyFee = monthlyFee;
	}
	
	public ServicePackage getPackage() {
		return this.sPackage;
	}
	public int getMonthsNumber() {
		return this.monthsNumber;
	}
	public float getMonthlyFee() {
		return this.monthlyFee;
	}
	
	//relationship "has" with order
	/*@OneToMany(fetch=FetchType.LAZY, mappedBy="validity")
	private Collection<CustomerOrder> orders;*/
	
	//relationship "isAssociatedWith"
	

}
