package it.polimi.db2.telco.entities;

import java.util.Collection;

import javax.persistence.*;

@Entity
@Table(name="SERVICE")
@NamedQuery(name="Service.findAll", query="SELECT s FROM Service S")
public class Service {
	@Id@GeneratedValue(strategy=GenerationType.AUTO)
	private int id;
	
	@Enumerated(EnumType.STRING)
	@Column(name="servicetype")
	private ServiceType serviceType;
	
	@Column(name="minnumber")
	private int minNumber;
	
	@Column(name="smsnumber")
	private int smsNumber;
	
	@Column(name="gbnumber")
	private int gbNumber;
	
	@Column(name="minfee")
	private float minFee;
	
	@Column(name="smsfee")
	private float smsFee;
	
	@Column(name="gbfee")
	private float gbFee;
	
	@ManyToMany(fetch=FetchType.LAZY, mappedBy="services")
	private Collection<ServicePackage> packages;
	
	public Service () {}
	
	public void setId(int id) {
		this.id = id;
	}
	
	public int getId() {
		return id;
	}

	public ServiceType getServiceType() {
		return this.serviceType;
	}

	public void setServicetype(ServiceType servicetype) {
		this.serviceType = servicetype;
	}

	public int getMinNumber() {
		return this.minNumber;
	}

	public void setMinNumber(int minNumber) {
		this.minNumber = minNumber;
	}

	public int getSmsNumber() {
		return this.smsNumber;
	}

	public void setSmsNumber(int smsNumber) {
		this.smsNumber = smsNumber;
	}

	public int getGBNumber() {
		return gbNumber;
	}

	public void setGBNumber(int gbnumber) {
		this.gbNumber = gbnumber;
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

	public float getGBFee() {
		return gbFee;
	}

	public void setGBFee(float gbfee) {
		this.gbFee = gbfee;
	}

	public Collection<ServicePackage> getPackages() {
		return packages;
	}

	public void setPackages(Collection<ServicePackage> packages) {
		this.packages = packages;
	}
}
