package it.polimi.db2.telco.entities;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.Collection;

import javax.persistence.*;

@Entity
@NamedQuery(name="CustomerOrder.findRejectedOrdersOfUser", query="SELECT o FROM CustomerOrder o WHERE o.user=?1 and o.rejected>0")
public class CustomerOrder {
	
	@Id @GeneratedValue (strategy=GenerationType.AUTO)
	private int id;
	
	private LocalDate date;
	private LocalTime hour;
	private LocalDateTime start;
	private float totalValue;
	private int rejected;
	private boolean valid;
	
	public CustomerOrder() {}
	
	public CustomerOrder(int id) {
		this.id = id;
	}
	
	public void setId(int id) {
		this.id = id;
	}
	public void setDate(LocalDate dt) {
		this.date = dt;
	}
	public void setHour(LocalTime h) {
		this.hour = h;
	}
	public void setStart(LocalDateTime st) {
		this.start= st;
	}
	public void setTotalValue(float tv) {
		this.totalValue = tv;
	}
	public void setRejected(int rej) {
		this.rejected = rej;
	}
	
	public void setValid(boolean val) {
		this.valid = val;
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
	public LocalDateTime getStart() {
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
	
	//relationship "creates"
	@ManyToOne(fetch=FetchType.EAGER)
	@JoinColumn(name = "user")
	private User user;
	
	//relationship "has" with ServicePackage
	@ManyToOne(fetch=FetchType.EAGER)
	@JoinColumn(name="package")
	private ServicePackage sPackage;
	
	//relationship "include"
	@ManyToMany(fetch=FetchType.LAZY)
	@JoinTable(
			name="choosesProducts",
			joinColumns={@JoinColumn(name="customerOrder")},
			inverseJoinColumns={@JoinColumn(name="product")}
			)
	private Collection<OptionalProduct> products;
	
	//relationship "has" with valPeriod
	@ManyToOne(fetch=FetchType.EAGER)
	@JoinColumn(name="months")
	private ValidityPeriod months;
}
