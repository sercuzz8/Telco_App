package it.polimi.db2.telco.entities;

import java.io.Serializable;
import java.util.Objects;

public class ValidityPeriodId implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private int sPackage;
	private int monthsNumber;

    public ValidityPeriodId() {
    }

    public ValidityPeriodId(int id, int monthsNumber) {
        this.sPackage = id;
        this.monthsNumber = monthsNumber;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ValidityPeriodId validityPeriodId = (ValidityPeriodId) o;
        return sPackage==validityPeriodId.sPackage &&
                monthsNumber==validityPeriodId.monthsNumber;
    }

    @Override
    public int hashCode() {
        return Objects.hash(sPackage, monthsNumber);
    }
}
