package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;
import java.math.BigInteger;


/**
 * The persistent class for the avgproductsold database table.
 * 
 */
@Entity
@Table(name="averageproductsold")
@NamedQuery(name="Avgproductsold.findAll", query="SELECT a FROM Averageproductsold a")
public class Averageproductsold implements Serializable {
	private static final long serialVersionUID = 1L;
	
	private BigInteger avgProductSold;
	
	@Id
	@Column(name="package")
	private int package_;

	public Averageproductsold() {
	}

	public BigInteger getAvgProducts() {
		return this.avgProductSold;
	}

	public void setAvgProducts(BigInteger avgProducts) {
		this.avgProductSold = avgProducts;
	}

	public int getPackage_() {
		return this.package_;
	}

	public void setPackage_(int package_) {
		this.package_ = package_;
	}

}