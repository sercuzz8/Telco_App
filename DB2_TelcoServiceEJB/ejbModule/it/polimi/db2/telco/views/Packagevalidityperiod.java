package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;

import it.polimi.db2.telco.entities.ValidityPeriodId;

import java.math.BigInteger;


/**
 * The persistent class for the packagevalidityperiod database table.
 * 
 */
@Entity
@Table(name="packagevalidityperiod")
@IdClass(PackagevalidityperiodId.class)
@NamedQuery(name="Packagevalidityperiod.findAll", query="SELECT p FROM Packagevalidityperiod p")
public class Packagevalidityperiod implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id
	private BigInteger months;
	
	@Id
	@Column(name="package")
	private int package_;
	
	
	private BigInteger purchases;

	public Packagevalidityperiod() {
	}

	public BigInteger getMonths() {
		return this.months;
	}

	public void setMonths(BigInteger months) {
		this.months = months;
	}

	public int getPackage_() {
		return this.package_;
	}

	public void setPackage_(int package_) {
		this.package_ = package_;
	}

	public BigInteger getPurchases() {
		return this.purchases;
	}

	public void setPurchases(BigInteger purchases) {
		this.purchases = purchases;
	}

}