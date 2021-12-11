package it.polimi.db2.telco.exceptions;

public class PackageNotFoundException extends Exception {
	private static final long serialVersionUID = 1L;

	public PackageNotFoundException(String message) {
		super(message);
	}
}