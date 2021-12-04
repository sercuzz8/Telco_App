package it.polimi.db2.telco.entities;

import javax.persistence.*;

// https://stackoverflow.com/questions/46657420/mapping-a-weak-entity-with-jpa

@Entity
public class MobilePhone {
	
	@Id
	@OneToOne
	@PrimaryKeyJoinColumn(name="service", referencedColumnName="id")
	protected Service service;

	
	private int minNumber;
	private int smsNumber;
	private float minFee;
	private float smsFee;

	public void setId(Service service) 
    {
        this.service = service;
    }
	
	public int getMinNumber() {
		return minNumber;
	}

	public void setMinNumber(int minNumber) {
		this.minNumber = minNumber;
	}

	public int getSmsNumber() {
		return smsNumber;
	}

	public void setSmsNumber(int smsNumber) {
		this.smsNumber = smsNumber;
	}

	public float getMinFee() {
		return minFee;
	}

	public void setMinFee(float minFee) {
		this.minFee = minFee;
	}

	public float getSmsFee() {
		return smsFee;
	}

	public void setSmsFee(float smsFee) {
		this.smsFee = smsFee;
	}

	/*@OneToOne(fetch=FetchType.LAZY, mappedBy="services")
	private Collection<ServicePackage> packages;§*/
}
