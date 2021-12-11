package it.polimi.db2.telco.entities;

import java.io.Serializable;
import java.util.Objects;

public class ValidityPeriodId implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private int id;
	private int monthsnumber;

    public ValidityPeriodId() {
    }

    public ValidityPeriodId(int id, int monthsNumber) {
        this.id = id;
        this.monthsnumber = monthsNumber;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        ValidityPeriodId validityPeriodId = (ValidityPeriodId) o;
        return id==validityPeriodId.id &&
                monthsnumber==validityPeriodId.monthsnumber;
    }

    @Override
    public int hashCode() {
        return Objects.hash(id, monthsnumber);
    }
}
