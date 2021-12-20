package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;


/**
 * The persistent class for the validitysaleproduct database table.
 * 
 */
@Entity
@Table(name="validitysaleproduct")
@NamedQuery(name="Validitysaleproduct.findAll", query="SELECT v FROM Validitysaleproduct v")
public class Validitysaleproduct implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id
	@Column(name="package")
	private int package_;

	private double withoutProducts;

	private double withProducts;

	public Validitysaleproduct() {
	}

	public int getPackage_() {
		return this.package_;
	}

	public void setPackage_(int package_) {
		this.package_ = package_;
	}

	public double getWithoutProducts() {
		return this.withoutProducts;
	}

	public void setWithoutProducts(double withoutProducts) {
		this.withoutProducts = withoutProducts;
	}

	public double getWithProducts() {
		return this.withProducts;
	}

	public void setWithProducts(double withProducts) {
		this.withProducts = withProducts;
	}

}