package it.polimi.db2.telco.entities;

import java.io.Serializable;
import java.util.Collection;

import javax.persistence.*;

@Entity
@Table(name="VALIDITYPERIOD")
@IdClass(ValidityPeriodId.class)
@NamedQuery(name="ValidityPeriod.findAllByPackage", query="SELECT v FROM ValidityPeriod v WHERE v.id=?1 ORDER BY v.monthsnumber ASC")
public class ValidityPeriod implements Serializable{
	
	private static final long serialVersionUID = 1L;
	
	@Id
	@Column(name="package")
	private int id;
	@Id
	private int monthsnumber;
	
	private float monthlyfee;
	
	public ValidityPeriod() {}
	
	public void setId(int id) {
		this.id = id;
	}
	public void setMonthsNumber(int mn) {
		this.monthsnumber = mn;
	}
	public void setMonthlyFee(float mf) {
		this.monthlyfee = mf;
	}
	
	public int getId() {
		return this.id;
	}
	public int getMonthsNumber() {
		return this.monthsnumber;
	}
	public float getMonthlyFee() {
		return this.monthlyfee;
	}
	
	//relationship "has" with order
	@OneToMany(fetch=FetchType.LAZY, mappedBy="validity")
	private Collection<CustomerOrder> orders;
	
	//relationship "isAssociatedWith"
	/*@OneToOne (fetch=FetchType.EAGER)
	@JoinColumn(name="package")
	private ServicePackage sPackage;*/

}
