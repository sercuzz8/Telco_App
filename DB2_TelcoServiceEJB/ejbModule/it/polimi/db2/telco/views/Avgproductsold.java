package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;
import java.math.BigInteger;


/**
 * The persistent class for the avgproductsold database table.
 * 
 */
@Entity
@Table(name="avgproductsold")
@NamedQuery(name="Avgproductsold.findAll", query="SELECT a FROM Avgproductsold a")
public class Avgproductsold implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private BigInteger avgProducts;
	
	@Id
	@Column(name="package")
	private int package_;

	public Avgproductsold() {
	}

	public BigInteger getAvgProducts() {
		return this.avgProducts;
	}

	public void setAvgProducts(BigInteger avgProducts) {
		this.avgProducts = avgProducts;
	}

	public int getPackage_() {
		return this.package_;
	}

	public void setPackage_(int package_) {
		this.package_ = package_;
	}

}