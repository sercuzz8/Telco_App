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

	public int getMinNumber() {
		return minnumber;
	}

	public void setMinNumber(int minnumber) {
		this.minnumber = minnumber;
	}

	public int getSmsNumber() {
		return smsnumber;
	}

	public void setSmsNumber(int smsnumber) {
		this.smsnumber = smsnumber;
	}

	public int getGBNumber() {
		return gbnumber;
	}

	public void setGBNumber(int gbnumber) {
		this.gbnumber = gbnumber;
	}

	public float getMinFee() {
		return minfee;
	}

	public void setMinFee(float minfee) {
		this.minfee = minfee;
	}

	public float getSmsFee() {
		return smsfee;
	}

	public void setSmsFee(float smsfee) {
		this.smsfee = smsfee;
	}

	public float getGBFee() {
		return gbfee;
	}

	public void setGBFee(float gbfee) {
		this.gbfee = gbfee;
	}

	public Collection<ServicePackage> getPackages() {
		return packages;
	}

	public void setPackages(Collection<ServicePackage> packages) {
		this.packages = packages;
	}
	
	@Override
	public String toString() {
		
		StringBuilder stb = new StringBuilder();
		
		switch (this.getServicetype()) {
		case fixed_phone:
			stb.append("Fixed Phone");
			stb.append(System.getProperty("line.separator"));
			break;
		case mobile_phone:
			stb.append("Mobile Phone");
			stb.append(System.getProperty("line.separator"));
			stb.append(this.getMinNumber() + " MIN: " + this.getMinFee() + " per extra");
			stb.append(System.getProperty("line.separator"));
			stb.append(this.getSmsNumber() + " SMS: " + this.getMinFee() + " per extra");
			stb.append(System.getProperty("line.separator"));
			break;
		case fixed_internet:
			stb.append("Fixed Internet");
			stb.append(System.getProperty("line.separator"));
			stb.append(this.getGBNumber() + " GB: " + this.getGBFee() + " per extra");
			stb.append(System.getProperty("line.separator"));
			break;
		case mobile_internet:
			stb.append("Mobile Internet");
			stb.append(System.getProperty("line.separator"));
			stb.append(this.getGBNumber() + " GB: " + this.getGBFee() + " per extra");
			stb.append(System.getProperty("line.separator"));
			break;
		default:
			stb.append("ERROR");
			break;
		}
		
		
		return stb.toString();
	}
}
