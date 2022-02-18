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
@NamedQuery(name="PurchasePerPackage.findAll", query="SELECT p FROM PurchasePerPackage p")
public class PurchasePerPackage implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id
	@Column(name="package")
	private int package_;

	private BigInteger purchases;

	public PurchasePerPackage() {
	}

	public int getPackage_() {
		return this.package_;
	}

	public BigInteger getPurchases() {
		return this.purchases;
	}

}