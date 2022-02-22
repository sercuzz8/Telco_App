package it.polimi.db2.telco.entities;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.Collection;

import javax.persistence.*;


@Entity
@Table(name="CUSTOMERORDER")
public class CustomerOrder {
	
	@Id @GeneratedValue (strategy=GenerationType.AUTO)
	private int id;
		
	private LocalDate date;
	private LocalTime hour;
	private LocalDate start;
	
	@Column(name="totalvalue")
	private float totalValue;
	
	private int rejected;
	private boolean valid;
	
	//relationship "creates"
	@ManyToOne(fetch=FetchType.EAGER)
	@JoinColumn(name = "customer")
	private User user;
		
	//relationship "has" with ServicePackage
	@ManyToOne(fetch=FetchType.EAGER)
	@JoinColumns({
        @JoinColumn(name="package", referencedColumnName="package"),
        @JoinColumn(name="months", referencedColumnName="monthsnumber")
    })
	private ValidityPeriod validity;
	
	//relationship "include"
	@ManyToMany(fetch=FetchType.EAGER)
	@JoinTable(
			name="choosesproducts",
			joinColumns=@JoinColumn(name="customerorder"),
			inverseJoinColumns=@JoinColumn(name="product")
			)
	private Collection<OptionalProduct> products;
	
	public CustomerOrder() {}
	
	public CustomerOrder(int id, LocalDate date, LocalTime hour, LocalDate start, ValidityPeriod val) {
		this.id=id;
		this.date=date;
		this.hour=hour;
		this.start=start;
		this.rejected=0;
		this.valid=false;
		this.validity=val;
		this.products=new ArrayList<>();
	}
	
	public int getId() {
		return this.id;
	}
	public LocalDate getDate() {
		return this.date;
	}
	public LocalTime getHour() {
		return this.hour;
	}
	public LocalDate getStart() {
		return this.start;
	}
	public float getTotalValue() {
		return this.totalValue;
	}
	public int getRejected() {
		return this.rejected;
	}
	
	public boolean getValid() {
		return this.valid;
	}
	
	public User getUser() {
		return this.user;
	}
	
	public ValidityPeriod getValidity() {
		return this.validity;
	}
	
	public Collection<OptionalProduct> getProducts() {
		return this.products;
	}
	
	public void setId(int id) {
		this.id = id;
	}
	public void setDate(LocalDate date) {
		this.date = date;
	}
	public void setHour(LocalTime hour) {
		this.hour = hour;
	}
	public void setStart(LocalDate start) {
		this.start= start;
	}
	public void setTotalValue(float totalValue) {
		this.totalValue = totalValue;
	}
	public void setRejected(int rejected) {
		this.rejected = rejected;
	}
	public void incrementRejected() {
		this.rejected++;
	}
	
	public void setValid() {
		this.valid = true;
	}
	
	public void setUser (User user) {
		this.user = user;
	}
	
	public void setValidity (ValidityPeriod validityPeriod) {
		this.validity = validityPeriod;
	}
	
	public void addProduct (OptionalProduct product) {
		this.products.add(product);
	}

	public void setProducts(Collection<OptionalProduct> products) {
		this.products = products;
	}
	
	public void computeTotalValue() {
		this.totalValue=this.validity.getMonthsNumber()*this.validity.getMonthlyFee();
		for (OptionalProduct p: this.products) {
			this.totalValue=this.totalValue + this.validity.getMonthsNumber()*p.getMonthlyFee(); 
		}
	}
}
