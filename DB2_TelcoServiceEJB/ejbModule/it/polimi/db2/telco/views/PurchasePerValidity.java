package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;

import java.math.BigInteger;


/**
 * The persistent class for the packagevalidityperiod database table.
 * 
 */
@Entity
@Table(name="PURCHASEPERVALIDITY")
@IdClass(PurchasePerValidityId.class)
@NamedQuery(name="PurchasePerValidity.findAll", query="SELECT p FROM PurchasePerValidity p")
public class PurchasePerValidity implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id
	private BigInteger months;
	
	@Id
	@Column(name="package")
	private int package_;
	
	
	private BigInteger purchases;

	public PurchasePerValidity() {
	}

	public BigInteger getMonths() {
		return this.months;
	}

	public int getPackage_() {
		return this.package_;
	}

	public BigInteger getPurchases() {
		return this.purchases;
	}

}