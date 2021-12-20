package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;
import java.math.BigInteger;


/**
 * The persistent class for the bestsellers database table.
 * 
 */
@Entity
@Table(name="bestsellers")
@NamedQuery(name="Bestseller.findAll", query="SELECT b FROM Bestseller b")
public class Bestseller implements Serializable {
	private static final long serialVersionUID = 1L;

	private BigInteger numOfSales;
	
	@Id
	private int product;

	public Bestseller() {
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