package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;
import java.math.BigInteger;


/**
 * The persistent class for the bestsellers database table.
 * 
 */
@Entity
@Table(name="BESTSELLER")
@NamedQuery(name="BestSeller.findAll", query="SELECT b FROM BestSeller b")
public class BestSeller implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Column(name="numOfSales")
	private BigInteger numOfSales;
	
	@Id
	private int product;

	public BestSeller() {
	}

	public BigInteger getNumOfSales() {
		return this.numOfSales;
	}

	public void setNumOfSales(BigInteger numOfSales) {
		this.numOfSales = numOfSales;
	}

	public int getProduct() {
		return this.product;
	}

	public void setProduct(int product) {
		this.product = product;
	}

}