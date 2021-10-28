CREATE TABLE User (
	username varchar(50) NOT NULL,
	password varchar(16) NOT NULL,
	email varchar(50) NOT NULL UNIQUE,
	PRIMARY KEY (username));

-- ok

CREATE TABLE Service (
	id int NOT NULL AUTO_INCREMENT,
	name varchar(50) not null,
	PRIMARY KEY(id));

--ok

CREATE TABLE MobilePhone (
	id int NOT NULL AUTO_INCREMENT,
	minNumber int NOT NULL,
	smsNumber int NOT NULL,
	minFee float NOT NULL, --extra
	smsFee float NOT NULL, --extra
	PRIMARY KEY (id),
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE);

--ok

CREATE TABLE FixedPhone (
	id int NOT NULL AUTO_INCREMENT,
	PRIMARY KEY (id),
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE);

--ok

CREATE TABLE MobileInternet (
	id int NOT NULL AUTO_INCREMENT,
	gbNumber int NOT NULL,
	gbFee float NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE);

--ok

CREATE TABLE FixedInternet (
	id int NOT NULL AUTO_INCREMENT,
	gbNumber int NOT NULL,
	gbFee float NOT NULL,
	PRIMARY KEY (id),
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE);

--ok

CREATE TABLE OptionalProduct (
	id int NOT NULL AUTO_INCREMENT,
	name varchar(50) NOT NULL,
	monthlyFee float NOT NULL,
	-- validity period the same as the service package
	PRIMARY KEY (id));

--ok

CREATE TABLE ValidityPeriod (
	monthsNumber int NOT NULL,
	monthlyFee float NOT NULL,
	package_id int NOT NULL,
	PRIMARY KEY (‘monthsNumber, monthlyFee, package_id), 
	FOREIGN KEY (package_id) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE),
	CONSTRAINT 'fixedNumber' CHECK (monthsNumber=12 OR monthsNumber=24 OR monthsNumber=36);

--ok

CREATE TABLE ServicePackage (
	id int NOT NULL AUTO_INCREMENT,
	name varchar(50) NOT NULL,
	PRIMARY KEY (id));



CREATE TABLE PackageProduct (
	package_id int NOT NULL,
	product_id int NOT NULL,
	PRIMARY KEY (package_id, product_id),
	FOREIGN KEY (package_id) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE);

--ok

CREATE TABLE PackageServices (
	package_id int NOT NULL,
	service_id int NOT NULL,
	PRIMARY KEY (package_id, service_id),
	FOREIGN KEY (package_id) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (service_id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE);

CREATE TABLE ProductOrder (
	order_id int NOT NULL,
	product_id int NOT NULL,
	PRIMARY KEY (order_id, product_id),
	FOREIGN KEY (order_id) REFERENCES Order(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE);
	
-- TODO: Non credo che la relazione sia N:N 

CREATE TABLE Order(
	id int NOT NULL AUTO_INCREMENT,
	date Date NOT NULL,
	hour Time NOT NULL,
	start Date NOT NULL,
	valid int NOT NULL DEFAULT ‘0’,
	package_id int NOT NULL,
	monthsNumber int NOT NULL,
	monthlyFee float NOT NULL,
	totalVaue float NOT NULL,
	PRIMARY KEY(id),
	FOREIGN KEY (package_id) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (monthsNumber, monthlyFee) REFERENCES ValidityPeriod(monthsNumber, monthlyFee) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT ’totalChk’ CHECK (totalValue = monthlyFee*monthsNumber + (’SELECT sum(monthlyFee) FROM ProductOrder WHERE order_id = id’)*monthsNumber),
	CONSTRAINT ‘validitiCheck’ CHECK((monthsNumber, monthlyFee) = (‘SELECT monthsNumber, monthlyFee FROM ValidityPeriod WHERE package_id = package_id’))


CREATE TABLE ServiceActivationSchedule (
	user_id varchar(50) NOT NULL,
	service_id int NOT NULL,
	activation Date NOT NULL,
	deactivation Date NOT NULL,
	PRIMARY KEY (user_id, service_id),
	FOREIGN KEY (user_id) REFERENCES User(username) --TODO: Penso che nel caso in cui lo user venga cancellato sia comunque necessario mantenere questa tavola per motivi di contabilità
	FOREIGN KEY (user_id) REFERENCES User(username) --TODO: Come sopra
)

/* 

Service Package [1:1] <-> [1:N] Service. 
Service package [1:1] <-> [1:1] one validity period. 
Package [1:1] <-> [1:N ] Optional products (e.g., an SMS news feed, an internet TV channel, etc.). 
Optional product[1:1] <-> [1:N] Service package

*/
