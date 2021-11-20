package it.polimi.db2.telco.entities;

import javax.persistence.*;

// https://stackoverflow.com/questions/46657420/mapping-a-weak-entity-with-jpa

@Entity
public class FixedPhone {
	
	@Id
	@OneToOne
	@PrimaryKeyJoinColumn(name="serviceId", referencedColumnName="id")
	protected Service serviceId;

	public void setId(Service service) 
    {
        this.serviceId = service;
    }
	

	/*@OneToOne(fetch=FetchType.LAZY, mappedBy="services")
	private Collection<ServicePackage> packages;§*/


}
