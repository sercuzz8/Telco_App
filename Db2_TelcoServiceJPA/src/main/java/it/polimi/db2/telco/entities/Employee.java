package it.polimi.db2.telco.entities;

import javax.persistence.*;

@Entity
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
