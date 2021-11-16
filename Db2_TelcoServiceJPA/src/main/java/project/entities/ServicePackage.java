package project.entities;

import java.util.Collection;

import javax.persistence.*;

@Entity
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
	
	@ManyToMany (fetch=FetchType.EAGER)
	@JoinColumn(name="products")
	private Collection<OptionalProduct> products;

	@ManyToMany (fetch=FetchType.EAGER)
	@JoinColumn(name="products")
	private Collection<Service> services;

	
}
