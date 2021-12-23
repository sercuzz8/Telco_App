package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;
import java.math.BigInteger;


/**
 * The persistent class for the purchasespackage database table.
 * 
 */
@Entity
@Table(name="PURCHASEPERPACKAGE")
@NamedQuery(name="PurchasesPackage.findAll", query="SELECT p FROM PurchasesPackage p")
public class PurchasesPackage implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id
	@Column(name="package")
	private int package_;

	private BigInteger purchases;

	public PurchasesPackage() {
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