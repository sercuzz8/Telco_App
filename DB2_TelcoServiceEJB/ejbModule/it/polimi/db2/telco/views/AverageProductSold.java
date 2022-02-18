package it.polimi.db2.telco.views;

import java.io.Serializable;
import javax.persistence.*;


/**
 * The persistent class for the avgproductsold database table.
 * 
 */
@Entity
@Table(name="AVERAGEPRODUCTSOLD")
@NamedQuery(name="AverageProductSold.findAll", query="SELECT a FROM AverageProductSold a")
public class AverageProductSold implements Serializable {
	private static final long serialVersionUID = 1L;
	
	@Id
	@Column(name="package")
	private int package_;
	
	@Column(name="avgproductsold")
	private float avgProductSold;

	public AverageProductSold() {
	}

	public float getAvgProducts() {
		return this.avgProductSold;
	}
	
	public int getPackage_() {
		return this.package_;
	}

}