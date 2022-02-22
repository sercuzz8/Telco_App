package it.polimi.db2.telco.entities;

import java.util.ArrayList;
import java.util.Collection;

import javax.persistence.*;

@Entity
@Table(name="SERVICEPACKAGE")
@NamedQuery(name="ServicePackage.findAll", query="SELECT S FROM ServicePackage S")
public class ServicePackage {
	@Id@GeneratedValue(strategy=GenerationType.IDENTITY)
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
	
	@OneToMany(fetch=FetchType.EAGER, mappedBy="sPackage")
	private Collection<ValidityPeriod> validityPeriods;
	
	public ServicePackage () {}
	
	public ServicePackage (String name) {
		this.name=name;
		this.products=new ArrayList<OptionalProduct>();
		this.services=new ArrayList<Service>();
		this.validityPeriods=new ArrayList<ValidityPeriod>();
	}
	
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

	public void setProducts(Collection<OptionalProduct> products) {
		this.products = products;
	}

	public void setServices(Collection<Service> services) {
		this.services = services;
	}

	public Collection<ValidityPeriod> getValidityPeriods() {
		return validityPeriods;
	}

	public void setValidityPeriods(Collection<ValidityPeriod> validityPeriods) {
		this.validityPeriods = validityPeriods;
	}
	
	public void addValidityPeriod(ValidityPeriod validityPeriod) {
		this.validityPeriods.add(validityPeriod);
	}
}
	
	
