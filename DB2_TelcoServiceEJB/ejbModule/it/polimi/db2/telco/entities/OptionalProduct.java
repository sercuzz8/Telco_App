package it.polimi.db2.telco.entities;

import java.util.Collection;

import javax.persistence.*;

@Entity
@Table(name="OPTIONALPRODUCT")
@NamedQuery(name="OptionalProduct.findAll", query="SELECT o FROM OptionalProduct o")
public class OptionalProduct {
	
	@Id @GeneratedValue(strategy=GenerationType.AUTO)
	private int id;
	
	private String name;
	private float monthlyFee;
	
	public OptionalProduct() {}
	
	public OptionalProduct(int id, String name, float monthlyFee) {
		this.id = id;
		this.name = name;
		this.monthlyFee = monthlyFee;
	}
	
	//relationship "include"
	@ManyToMany (fetch=FetchType.LAZY, mappedBy="products")
	private Collection<CustomerOrder> orders;
	
	//relationship "has"
	@ManyToMany (fetch=FetchType.LAZY, mappedBy="products")
	private Collection<ServicePackage> packages;
	
	public void setName(String name) {
		this.name = name;
	}
	public void setId(int id) {
		this.id = id;
	}
	public void setMonthlyFee(float mf) {
		this.monthlyFee = mf;
	}
	
	public int getId() {
		return this.id;
	}
	
	public String getName() {
		return this.name;
	}
	
	public float getMonthlyFee() {
		return this.monthlyFee;
	}
	
	/*@Override
	public String toString() {
		return (this.getName() + ": " + this.getMonthlyFee() + "per month" + System.getProperty("line.separator"));
	}*/
}

