package it.polimi.db2.telco.entities;

import java.util.Collection;

import javax.persistence.*;

@Entity
@Table(name="SERVICEPACKAGE")
@NamedQuery(name="ServicePackage.findAll", query="SELECT S FROM ServicePackage S")
public class ServicePackage {
	@Id@GeneratedValue(strategy=GenerationType.AUTO)
	private int id;
	
	private String name;
	
	@ManyToMany(fetch=FetchType.EAGER)
	@JoinTable(
			name="offersproducts",
			joinColumns={@JoinColumn(name="package")},
			inverseJoinColumns={@JoinColumn(name="product")}
			)
	private Collection<OptionalProduct> products;

	@ManyToMany(fetch=FetchType.EAGER)
	@JoinTable(
			name="includesservices",
			joinColumns={@JoinColumn(name="package")},
			inverseJoinColumns={@JoinColumn(name="service")}
			)
	private Collection<Service> services;
	
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

	public Collection<OptionalProduct> getProducts() {
		return products;
	}

	public void addProduct(OptionalProduct product) {
		this.products.add(product);
	}

	public Collection<Service> getServices() {
		return services;
	}

	public void addService(Service service) {
		this.services.add(service);
	}
	
}
