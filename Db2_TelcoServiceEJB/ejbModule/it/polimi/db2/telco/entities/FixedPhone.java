package it.polimi.db2.telco.entities;

import javax.persistence.*;

// https://stackoverflow.com/questions/46657420/mapping-a-weak-entity-with-jpa

@Entity
public class FixedPhone {
	
	@Id
	@OneToOne
	@PrimaryKeyJoinColumn(name="service", referencedColumnName="id")
	protected Service service;

	public void setId(Service service) 
    {
        this.service = service;
    }
	

	/*@OneToOne(fetch=FetchType.LAZY, mappedBy="services")
	private Collection<ServicePackage> packages;§*/


}
