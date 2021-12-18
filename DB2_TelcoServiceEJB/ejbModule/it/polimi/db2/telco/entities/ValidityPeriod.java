package it.polimi.db2.telco.entities;

import javax.persistence.*;

@Entity
@Table(name="VALIDITYPERIOD")
@IdClass(ValidityPeriodId.class)
@NamedQuery(name="ValidityPeriod.findAll", query="SELECT v FROM ValidityPeriod v")
@NamedQuery(name="ValidityPeriod.findValidity", query="SELECT v FROM ValidityPeriod v WHERE v.sPackage=?1 AND v.monthsnumber=?2 ORDER BY v.monthsnumber ASC")
public class ValidityPeriod {
	
	@Id
	@ManyToOne
	@JoinColumn(name="package", referencedColumnName="id")
	private ServicePackage sPackage;
	@Id
	private int monthsnumber;
	
	private float monthlyfee;
	
	public ValidityPeriod() {}
	
	public void setPackage(ServicePackage id) {
		this.sPackage = id;
	}
	public void setMonthsNumber(int mn) {
		this.monthsnumber = mn;
	}
	public void setMonthlyFee(float mf) {
		this.monthlyfee = mf;
	}
	
	public ServicePackage getPackage() {
		return this.sPackage;
	}
	public int getMonthsNumber() {
		return this.monthsnumber;
	}
	public float getMonthlyFee() {
		return this.monthlyfee;
	}
	
	//relationship "has" with order
	/*@OneToMany(fetch=FetchType.LAZY, mappedBy="validity")
	private Collection<CustomerOrder> orders;*/
	
	//relationship "isAssociatedWith"
	

}
