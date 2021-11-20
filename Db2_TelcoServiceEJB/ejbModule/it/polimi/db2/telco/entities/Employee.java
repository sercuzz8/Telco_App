package it.polimi.db2.telco.entities;

import javax.persistence.*;

@Entity
@NamedQuery (name = "Employee.checkCredentials", query = "SELECT e FROM Employee e WHERE e.code=?1 AND e.password=?2")
public class Employee {
	
	@Id
	private String code;
	
	private String password;

	public String getCode() {
		return code;
	}

	public void setCode(String code) {
		this.code = code;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}
	
	
}
