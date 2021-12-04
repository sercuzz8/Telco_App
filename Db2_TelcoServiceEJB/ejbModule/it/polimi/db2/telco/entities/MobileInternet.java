package it.polimi.db2.telco.entities;

import javax.persistence.*;

// https://stackoverflow.com/questions/46657420/mapping-a-weak-entity-with-jpa

@Entity
public class MobileInternet {
	
	@Id
	@OneToOne
	@PrimaryKeyJoinColumn(name="service", referencedColumnName="id")
	protected Service service;

	private int gbNumber;
	private float gbFee;
	
	public void setId(Service service) 
    {
        this.service = service;
    }

	public int getGbNumber() {
		return gbNumber;
	}

	public void setGbNumber(int gbNumber) {
		this.gbNumber = gbNumber;
	}

	public float getGbFee() {
		return gbFee;
	}

	public void setGbFee(float gbFee) {
		this.gbFee = gbFee;
	}

	/*@OneToOne(fetch=FetchType.LAZY, mappedBy="services")
	private Collection<ServicePackage> packages;§*/
}
