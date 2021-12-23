package it.polimi.db2.telco.views;

import java.io.Serializable;
import java.math.BigInteger;
import java.util.Objects;

public class PackageValidityPeriodId implements Serializable{
private static final long serialVersionUID = 1L;
	
	private int package_;
	private BigInteger months;

    public PackageValidityPeriodId() {
    }

    public PackageValidityPeriodId(int id, BigInteger months) {
        this.package_ = id;
        this.months = months;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        PackageValidityPeriodId packagevalidityperiodId = (PackageValidityPeriodId) o;
        return package_==packagevalidityperiodId.package_ &&
                months==packagevalidityperiodId.months;
    }

    @Override
    public int hashCode() {
        return Objects.hash(package_, months);
    }
}
