DROP schema telcoDB;
CREATE schema telcoDB;
USE telcoDB;

CREATE TABLE CUSTOMER ( 
	username varchar(50) PRIMARY KEY,
	password varchar(16) NOT NULL,
	email varchar(50) NOT NULL UNIQUE,  
	insolvent int NOT NULL DEFAULT 0 
	);

CREATE TABLE EMPLOYEE ( 
	code varchar(16) PRIMARY KEY,
	password varchar(16) NOT NULL
	);
		
CREATE TABLE SERVICEPACKAGE (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY, 
	name varchar(50) NOT NULL
	);
		
CREATE TABLE VALIDITYPERIOD (
	package int NOT NULL, 
	monthsnumber int NOT NULL, 
	monthlyfee float NOT NULL, 
	PRIMARY KEY (package,monthsnumber), 
	FOREIGN KEY (package) REFERENCES SERVICEPACKAGE(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT out_of_fixed_values CHECK (monthsnumber in (12, 24, 36))
	);
		
CREATE TABLE CUSTOMERORDER (
	id int NOT NULL PRIMARY KEY,
	date Date NOT NULL, 
	hour Time NOT NULL,
	start Date NOT NULL,
	customer varchar(50), -- Not unique because the same customer can buy different packages
	package int NOT NULL, -- The order is associated with the validity period but the validity period is associated with only
	months int NOT NULL, -- one service package thus the validity period is associated with a single service package
	rejected int NOT NULL DEFAULT 0,  
	valid int NOT NULL DEFAULT 0,
	totalValue float,
	FOREIGN KEY (customer) REFERENCES CUSTOMER(username),
	FOREIGN KEY (package, months) REFERENCES VALIDITYPERIOD(package, monthsnumber) -- ON DELETE CASCADE ON UPDATE CASCADE we won't delete the order tuple if a validity period is updated or deleted
	);

CREATE TABLE AUDITING (
	customer varchar(50) PRIMARY KEY, 
	email varchar(50), -- we set it null by default because we will populate the table by the use of triggers
						-- in addition, this table does not change over its lifetime
	lastrejectionamount float NOT NULL, 
	lastrejectiondate Date NOT NULL, 
	lastrejectiontime Time NOT NULL,
	FOREIGN KEY (customer) REFERENCES CUSTOMER(username) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE SERVICE (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	servicetype ENUM('fixed_phone','mobile_phone','fixed_internet','mobile_internet'),
	minnumber int DEFAULT 0,  
	smsnumber int DEFAULT 0, 
    gbnumber int DEFAULT 0,
	minfee float DEFAULT 0.0,  
	smsfee float DEFAULT 0.0,
	gbfee float DEFAULT 0.0
	);

CREATE TABLE OPTIONALPRODUCT (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name varchar(50) NOT NULL,
	monthlyfee float NOT NULL
	);

CREATE TABLE SERVICEACTIVATIONSCHEDULE (
	package int NOT NULL, 
	customer varchar(50) NOT NULL,
	activationdate Date, 
	deactivationdate Date,
	PRIMARY KEY (package, customer),
	FOREIGN KEY (customer) REFERENCES CUSTOMER(username) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (package) REFERENCES SERVICEPACKAGE(id) ON DELETE CASCADE ON UPDATE CASCADE
	);


CREATE TABLE offersproducts (
	package int NOT NULL,
	product int NOT NULL,
	PRIMARY KEY (package, product),
	FOREIGN KEY (package) REFERENCES SERVICEPACKAGE(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product) REFERENCES OPTIONALPRODUCT(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE includesservices (
	package int NOT NULL,
	service int NOT NULL,
	PRIMARY KEY (package, service),
	FOREIGN KEY (package) REFERENCES SERVICEPACKAGE(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (service) REFERENCES SERVICE(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE choosesproducts (
	customerorder int NOT NULL,
	product int NOT NULL,
	PRIMARY KEY (customerorder, product),
	FOREIGN KEY (customerorder) REFERENCES CUSTOMERORDER(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product) REFERENCES OPTIONALPRODUCT(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE purchasesproducts (
	package int NOT NULL,
	customer varchar(50) NOT NULL,
	product int NOT NULL,
	PRIMARY KEY (package, customer, product),
	FOREIGN KEY (package) REFERENCES SERVICEPACKAGE(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (customer) REFERENCES CUSTOMER(username) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product) REFERENCES OPTIONALPRODUCT(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE VIEW purchasespackage (package, purchases) AS
SELECT package, COUNT(*)
FROM SERVICEACTIVATIONSCHEDULE 
GROUP BY package
ORDER BY package ASC;

CREATE VIEW packagevalidityperiod (package, months, purchases) AS
SELECT package, TIMESTAMPDIFF(MONTH,activationdate,deactivationdate), COUNT(*)
FROM SERVICEACTIVATIONSCHEDULE	
GROUP BY package, TIMESTAMPDIFF(MONTH,activationdate,deactivationdate)
ORDER BY package, TIMESTAMPDIFF(MONTH,activationdate,deactivationdate);

CREATE VIEW validitysaleproduct (package, withProducts, withoutProducts) AS
SELECT s.package, SUM(c.totalValue), SUM(v.monthsnumber*v.monthlyfee)
FROM SERVICEACTIVATIONSCHEDULE AS s, CUSTOMERORDER AS c, VALIDITYPERIOD as v
WHERE s.package = c.package AND s.customer=c.customer AND c.package=v.package AND c.months=v.monthsnumber
GROUP BY s.package
ORDER BY s.package ASC;

CREATE VIEW avgproductsold (package, avgProducts) AS
SELECT s.package, COUNT(p.product)
FROM SERVICEACTIVATIONSCHEDULE AS s, purchasesproducts as p
WHERE s.package = p.package AND s.customer=p.customer
GROUP BY s.package, s.customer;

CREATE VIEW insolventcustomers(insolvent, rejectedOrder, alertDate) AS
SELECT c.customer, c.id, a.lastrejectiondate
FROM CUSTOMERORDER c LEFT JOIN AUDITING a ON c.customer=a.customer
WHERE rejected>0
ORDER BY c.customer ASC;

CREATE VIEW bestsellers(product, numOfSales) AS
SELECT p.product, COUNT(*) AS NUM
FROM SERVICEACTIVATIONSCHEDULE AS s, purchasesproducts as p
WHERE s.package = p.package AND s.customer=p.customer
GROUP BY p.product
ORDER BY NUM DESC;
-- LIMIT 5;

-- TODO: Add the materialized views of the data, to be populated by triggers
CREATE TRIGGER calculate_fee BEFORE INSERT ON CUSTOMERORDER
FOR EACH ROW
	SET new.totalValue = new.months *
		-- Sum of fees of the SERVICE Package
		(SELECT V.monthlyfee FROM VALIDITYPERIOD AS V WHERE V.package=new.package AND V.monthsnumber=new.months);

CREATE TRIGGER adjust_Total AFTER INSERT ON choosesproducts 
FOR EACH ROW
	UPDATE CUSTOMERORDER AS c SET
		c.totalValue = (
		c.totalValue + c.months *
		-- Sum of all the fees of the Optional Product
		(SELECT O.monthlyfee FROM OPTIONALPRODUCT as O WHERE O.id = new.product))
		WHERE c.id=new.customerorder; --  It also contains the total value

delimiter //
CREATE TRIGGER product_not_on_package 
	BEFORE INSERT ON choosesproducts 
	FOR EACH ROW
	BEGIN
	IF (new.product NOT IN (
		SELECT OP.product FROM offersproducts AS OP WHERE OP.package =
			(SELECT CO.package from CUSTOMERORDER AS CO WHERE CO.id=new.customerorder)))
		THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not offered with the package';
	END IF;
	END//

CREATE TRIGGER accepted_payment
	AFTER UPDATE ON CUSTOMERORDER
	FOR EACH ROW
	IF (new.valid=1 and old.valid<>1)
	THEN
		BEGIN
		
        UPDATE CUSTOMERORDER SET rejected=0 WHERE id=new.id ;

		INSERT INTO SERVICEACTIVATIONSCHEDULE (package, customer, activationdate, deactivationdate) VALUES (new.package, new.customer, new.start, date_add(new.start, interval new.months month));
		
		INSERT INTO purchasesproducts(package, customer, product)
		SELECT co.package, co.customer, ch.product 
		FROM CUSTOMERORDER co JOIN choosesproducts ch ON ch.customerorder=co.id
		WHERE co.id=new.id;

		END;
	END IF//

CREATE TRIGGER failed_payments
	AFTER UPDATE ON CUSTOMERORDER
	FOR EACH ROW
	BEGIN 
		IF (new.rejected=1 and old.rejected<>1)
		THEN
			UPDATE CUSTOMER SET insolvent=1 WHERE username=new.customer ;
		ELSEIF (new.rejected=3 and old.rejected<>3)
		THEN
			BEGIN
			SET @insolvent_mail = (SELECT u.email FROM CUSTOMER AS u WHERE u.username=new.customer);
			INSERT INTO AUDITING (customer, email, lastrejectionamount, lastrejectiondate, lastrejectiontime) values (new.customer, @insolvent_mail, new.totalValue, CURRENT_DATE(), CURRENT_TIME()); 
			END;
		END IF;
	END//
delimiter ;