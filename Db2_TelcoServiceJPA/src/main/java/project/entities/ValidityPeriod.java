package project.entities;

import java.util.Collection;

import javax.persistence.*;

@Entity
public class ValidityPeriod {
	
	@Id@GeneratedValue(strategy=GenerationType.AUTO)
	private int id;
	@Id
	private int monthNumber;
	
	private float monthlyFee;
	
	public ValidityPeriod() {}
	
	public void setId(int id) {
		this.id = id;
	}
	public void setMonthNumber(int mn) {
		this.monthNumber = mn;
	}
	public void setMonthlyFee(float mf) {
		this.monthlyFee = mf;
	}
	
	public int getId() {
		return this.id;
	}
	public int getMonthNumber() {
		return this.monthNumber;
	}
	public float getMonthlyFee() {
		return this.monthlyFee;
	}
	
	//relationship "has" with order
	@OneToMany(fetch=FetchType.LAZY, mappedBy="months")
	private Collection<CustomerOrder> orders;
	
	//relationship "isAssociatedWith"
	@ManyToOne
	@JoinColumn(fetch=FetchType.EAGER, name="packageId")
	private ServicePackage package;

}
