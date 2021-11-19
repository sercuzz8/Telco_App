package it.polimi.db2.telco.entities;

import java.util.Collection;

import javax.persistence.*;

@Entity
public class OptionalProduct {
	
	@Id @GeneratedValue(strategy=GenerationType.AUTO)
	private int id;
	
	private String name;
	private float monthlyFee;
	
	public OptionalProduct() {}
	
	public OptionalProduct(int id) {
		this.id = id;
	}
	
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
	
	//relationship "include"
	@ManyToMany (fetch=FetchType.LAZY, mappedBy="products")
	private Collection<CustomerOrder> orders;
	
	//relationship "has"
	@ManyToMany (fetch=FetchType.LAZY, mappedBy="products")
	private Collection<ServicePackage> packages;
}

