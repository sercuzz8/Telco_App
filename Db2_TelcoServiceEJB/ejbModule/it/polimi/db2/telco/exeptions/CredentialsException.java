package it.polimi.db2.telco.exeptions;

public class CredentialsException extends Exception {
	private static final long serialVersionUID = 1L;

	public CredentialsException(String message) {
		super(message);
	}
}
