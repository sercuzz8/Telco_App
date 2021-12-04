package it.polimi.db2.telco.entities;

import java.util.Collection;

import javax.persistence.*;

@Entity
@NamedQuery(name="ServicePackage.findAll", query="SELECT s FROM ServicePackage S")
public class ServicePackage {
	@Id@GeneratedValue(strategy=GenerationType.AUTO)
	private int id;
	
	private String name;
	
	public ServicePackage () {}
	
	public void setId(int id) {
		this.id = id;
	}
	
	public int getId() {
		return id;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	public String getName() {
		return name;
	}
	
	@ManyToMany(fetch=FetchType.EAGER)
	@JoinTable(
			name="offersProducts",
			joinColumns={@JoinColumn(name="package")},
			inverseJoinColumns={@JoinColumn(name="product")}
			)
	private Collection<OptionalProduct> products;

	@ManyToMany(fetch=FetchType.EAGER)
	@JoinTable(
			name="includesServices",
			joinColumns={@JoinColumn(name="package")},
			inverseJoinColumns={@JoinColumn(name="service")}
			)
	private Collection<Service> services;

	
}
