package it.polimi.db2.telco.entities;

import java.util.Collection;

import javax.persistence.*;

@Entity
@Table(name="SERVICE")
@NamedQuery(name="Service.findAll", query="SELECT s FROM Service S")
public class Service {
	@Id@GeneratedValue(strategy=GenerationType.AUTO)
	private int id;
	
	@Column(name="servicetype")
	private ServiceType servicetype;
	
	private int minnumber;
	
	private int smsnumber;
	
	private int gbnumber;
	
	private float minfee;
	
	private float smsfee;
	
	private float gbfee;
	
	@ManyToMany(fetch=FetchType.LAZY, mappedBy="services")
	private Collection<ServicePackage> packages;
	
	public Service () {}
	
	public void setId(int id) {
		this.id = id;
	}
	
	public int getId() {
		return id;
	}

	public ServiceType getServicetype() {
		return servicetype;
	}

	public void setServicetype(ServiceType servicetype) {
		this.servicetype = servicetype;
	}

	public int getMinnumber() {
		return minnumber;
	}

	public void setMinnumber(int minnumber) {
		this.minnumber = minnumber;
	}

	public int getSmsnumber() {
		return smsnumber;
	}

	public void setSmsnumber(int smsnumber) {
		this.smsnumber = smsnumber;
	}

	public int getGbnumber() {
		return gbnumber;
	}

	public void setGbnumber(int gbnumber) {
		this.gbnumber = gbnumber;
	}

	public float getMinfee() {
		return minfee;
	}

	public void setMinfee(float minfee) {
		this.minfee = minfee;
	}

	public float getSmsfee() {
		return smsfee;
	}

	public void setSmsfee(float smsfee) {
		this.smsfee = smsfee;
	}

	public float getGbfee() {
		return gbfee;
	}

	public void setGbfee(float gbfee) {
		this.gbfee = gbfee;
	}

	public Collection<ServicePackage> getPackages() {
		return packages;
	}

	public void setPackages(Collection<ServicePackage> packages) {
		this.packages = packages;
	}
	
	
	
}
