package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;
import java.math.BigInteger;


/**
 * The persistent class for the purchasespackage database table.
 * 
 */
@Entity
@Table(name="purchasespackage")
@NamedQuery(name="Purchasespackage.findAll", query="SELECT p FROM Purchasespackage p")
public class Purchasespackage implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id
	@Column(name="package")
	private int package_;

	private BigInteger purchases;

	public Purchasespackage() {
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