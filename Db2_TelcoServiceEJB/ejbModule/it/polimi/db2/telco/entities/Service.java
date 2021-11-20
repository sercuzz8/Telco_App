package it.polimi.db2.telco.entities;

import java.util.Collection;

import javax.persistence.*;

@Entity
public class Service {
	@Id@GeneratedValue(strategy=GenerationType.AUTO)
	private int id;
	
	
	public Service () {}
	
	public void setId(int id) {
		this.id = id;
	}
	
	public int getId() {
		return id;
	}
	
	@ManyToMany(fetch=FetchType.LAZY, mappedBy="services")
	private Collection<ServicePackage> packages;
	
}
