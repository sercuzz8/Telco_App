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
	CONSTRAINT out_of_fixed_values CHECK (monthsnumber in (12, 24, 36)),
    CONSTRAINT non_negative_fee CHECK (monthlyfee>=0)
	);
		
CREATE TABLE CUSTOMERORDER (
	id int NOT NULL PRIMARY KEY,
	date Date NOT NULL, 
	hour Time NOT NULL,
	start Date NOT NULL,
	customer varchar(50) NOT NULL, -- Not unique because the same customer can buy different packages
	package int NOT NULL, -- The order is associated with the validity period but the validity period is associated with only
	months int NOT NULL, -- one service package thus the validity period is associated with a single service package
	rejected int NOT NULL DEFAULT 0,  
	valid int NOT NULL DEFAULT 0,
	totalvalue float,
	FOREIGN KEY (customer) REFERENCES CUSTOMER(username),
    UNIQUE (package, customer),
	FOREIGN KEY (package, months) REFERENCES VALIDITYPERIOD(package, monthsnumber), -- ON DELETE CASCADE ON UPDATE CASCADE we won't delete the order tuple if a validity period is updated or deleted
	CONSTRAINT non_negative_value CHECK (totalvalue>=0)
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
	gbfee float DEFAULT 0.0, 
    CONSTRAINT non_negative_min CHECK (minnumber>=0),
    CONSTRAINT non_negative_minfee CHECK (minfee>=0),
    CONSTRAINT non_negative_sms CHECK (smsnumber>=0),
    CONSTRAINT non_negative_smsfee CHECK (smsfee>=0),
    CONSTRAINT non_negative_gb CHECK (gbnumber>=0),
    CONSTRAINT non_negative_gbfee CHECK (gbfee>=0)
	);

CREATE TABLE OPTIONALPRODUCT (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name varchar(50) NOT NULL,
	monthlyfee float NOT NULL,
    CONSTRAINT non_negative_product_fee CHECK (monthlyfee>=0)
	);

CREATE TABLE SERVICEACTIVATIONSCHEDULE (
	package int NOT NULL, 
	customer varchar(50) NOT NULL,
	activationdate Date, 
	deactivationdate Date,
	PRIMARY KEY (package, customer),
	FOREIGN KEY (customer) REFERENCES CUSTOMER(username) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (package) REFERENCES SERVICEPACKAGE(id) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT deactivation_after_activation CHECK (deactivationdate>activationdate)
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
    

/*
VIEW 1: It keeps tracks of how many times a package was purchased

@package : id of the package
@purchases: counter of how many times the package was purchases

*/
CREATE TABLE PURCHASEPERPACKAGE (
	package int PRIMARY KEY,
    purchases int
);

/* A new voice is added when a package is sold for the first time */
delimiter //
CREATE TRIGGER update_purchases
AFTER INSERT ON SERVICEACTIVATIONSCHEDULE
FOR EACH ROW
BEGIN
	IF new.package NOT IN (SELECT package FROM PURCHASEPERPACKAGE) THEN
		INSERT INTO PURCHASEPERPACKAGE(package, purchases) VALUES (new.package, 1);
	ELSE
		UPDATE PURCHASEPERPACKAGE SET purchases = purchases+1 WHERE package = new.package;
	END IF;
END//
delimiter ;

/* A voice is removed together with the package*/
CREATE TRIGGER delete_pack
AFTER DELETE ON SERVICEPACKAGE
FOR EACH ROW
DELETE FROM PURCHASEPERPACKAGE WHERE package = old.id;

/*
VIEW 2: It keeps tracks of how many times a package (for a specific number of months) was purchased

@package : id of the package
@months : number of months
@purchases: counter of how many times the package was purchases

*/

CREATE TABLE PURCHASEPERVALIDITY (
	package int,
    months int,
    purchases int,
	PRIMARY KEY (package, months)
);

delimiter //
CREATE TRIGGER insert_new_package_purchase
AFTER INSERT ON SERVICEACTIVATIONSCHEDULE
FOR EACH ROW
BEGIN
	SET @new_months = TIMESTAMPDIFF(MONTH,new.activationdate,new.deactivationdate);
	IF (new.package, @new_months) NOT IN (SELECT package, months FROM PURCHASEPERVALIDITY) THEN 
		INSERT INTO PURCHASEPERVALIDITY(package,months, purchases) VALUES (new.package, @new_months, 1);
	ELSE
    	UPDATE PURCHASEPERVALIDITY SET purchases = purchases+1 WHERE package = new.package AND months = @new_months;
	END IF;
END//
delimiter ;

-- delete service package
CREATE TRIGGER delete_package
AFTER DELETE ON SERVICEPACKAGE
FOR EACH ROW
DELETE FROM PURCHASEPERVALIDITY WHERE package = old.id;
-- delete validity period
CREATE TRIGGER delete_validity
AFTER DELETE ON VALIDITYPERIOD
FOR EACH ROW 
DELETE FROM PURCHASEPERVALIDITY WHERE package = old.package AND months = old.monthsnumber;

/*
VIEW 3: It keeps tracks of the sales for every package, accounting both the cases with and without the products

@package : id of the package
@withproducts : sales with the products included
@withoutproducts : sales without the products included

*/

CREATE TABLE SALEPERPACKAGE (
	package int PRIMARY KEY,
    withproducts int,
    withoutproducts int
);

delimiter //
CREATE TRIGGER new_sale
AFTER INSERT ON SERVICEACTIVATIONSCHEDULE
FOR EACH ROW
BEGIN

	SET @new_months = TIMESTAMPDIFF(MONTH,new.activationdate,new.deactivationdate);
	SET @vp_value = ( SELECT v.monthsnumber*v.monthlyfee FROM VALIDITYPERIOD AS v WHERE v.package = new.package AND v.monthsnumber = @new_months);
	SET @total_value = (SELECT totalvalue FROM CUSTOMERORDER AS c WHERE c.package=new.package AND c.customer=new.customer);

	IF new.package NOT IN (SELECT package FROM SALEPERPACKAGE) THEN
		INSERT INTO SALEPERPACKAGE (package, withproducts, withoutproducts) VALUES (new.package, @total_value, @vp_value);
	ELSE
    	UPDATE SALEPERPACKAGE SET withproducts = withproducts + @total_value, withoutproducts = withoutproducts + @vp_value	WHERE package = new.package;
	
	END IF;
END//
delimiter ;

/*
VIEW 4: It keeps tracks of the average number of products sold with every package

@package : id of the package
@avgproductsold : average number of products sold with it

*/

CREATE TABLE AVERAGEPRODUCTSOLD(
	package int PRIMARY KEY,
	avgproductsold float
);

delimiter //
CREATE TRIGGER update_average
AFTER INSERT ON purchasesproducts
FOR EACH ROW 
BEGIN
	IF (new.package NOT IN (SELECT package FROM AVERAGEPRODUCTSOLD)) THEN
		SET @sumofproducts=(SELECT COUNT(*) FROM purchasesproducts WHERE package=new.package);
		INSERT INTO AVERAGEPRODUCTSOLD(package, avgproductsold) VALUES 
			(new.package, @sumofproducts);
	ELSE
		BEGIN
		SET @sumofproducts=(SELECT COUNT(*) FROM purchasesproducts WHERE package=new.package);
		SET @numofpurchases = (SELECT purchases FROM PURCHASEPERPACKAGE WHERE package=new.package);
		UPDATE AVERAGEPRODUCTSOLD SET 
            avgproductsold = @sumofproducts / @numofpurchases  
            WHERE package=new.package;
		END;
    END IF;
END //
delimiter ;

/*
VIEW 3: It keeps tracks of the insolvent customers

@insolvent: username of the insolvent user
@rejectedorder: id of the rejected order
@alertdate: (NULL) if the order has not been rejected for 3+ times, otherwise it is the date of the auditing

*/


CREATE TABLE INSOLVENTCUSTOMER (
	insolvent varchar(50) PRIMARY KEY,
    rejectedorder int,
    alertdate date,
    alerttime time
);

delimiter //
CREATE TRIGGER remove_insolvent
AFTER UPDATE ON CUSTOMERORDER 
FOR EACH ROW
BEGIN
	IF (new.valid = 1 AND old.valid = 0) THEN
		IF (new.customer IN (SELECT i.insolvent FROM INSOLVENTCUSTOMER i)) THEN
			SET @validorders = (SELECT count(*) FROM CUSTOMERORDER c WHERE c.customer = new.customer AND c.valid = 1);
            IF (@validorders = (SELECT count(*) FROM CUSTOMERORDER c WHERE c.customer = new.customer)) THEN
				DELETE FROM INSOLVENTCUSTOMER WHERE insolvent=new.customer AND rejectedorder = new.id;
            END IF;
        END IF;
    END IF;
END //
delimiter ;

delimiter //
CREATE TRIGGER new_insolvent
AFTER UPDATE ON CUSTOMERORDER
FOR EACH ROW
BEGIN
	IF (new.rejected = 1 AND old.rejected = 0) THEN
		INSERT INTO INSOLVENTCUSTOMER (insolvent, rejectedorder, alertdate, alerttime) VALUES (new.customer,new.id, NULL, NULL);
	END IF;
END //
delimiter ;

delimiter //
CREATE TRIGGER update_insolvent
AFTER INSERT ON AUDITING
FOR EACH ROW
BEGIN
	UPDATE INSOLVENTCUSTOMER SET alertdate=new.lastrejectiondate WHERE insolvent=new.customer;
	UPDATE INSOLVENTCUSTOMER SET alerttime=new.lastrejectiontime WHERE insolvent=new.customer;
END //
delimiter ;

/*
VIEW 3: It keeps tracks of the sales for every product

@product: id of the product
@numofsales: number of sales

*/

CREATE TABLE BESTSELLER (
	product int PRIMARY KEY,
    numofsales int
);

-- BESTSELLER triggers

-- delete product from optional product
CREATE TRIGGER remove_product
AFTER DELETE ON OPTIONALPRODUCT
FOR EACH ROW
DELETE FROM BESTSELLER WHERE product=old.id;

-- update product in BESTSELLER
delimiter //
CREATE TRIGGER update_product
AFTER INSERT ON purchasesproducts
FOR EACH ROW
BEGIN
	IF new.product NOT IN (SELECT PRODUCT FROM BESTSELLER) THEN 
		INSERT INTO BESTSELLER(product,numofsales) VALUES (new.product, 1);
	ELSE 
		UPDATE BESTSELLER SET numofsales = numofsales+1 WHERE product = new.product;
	END IF;
END//
delimiter ;


-- ------------------------------------------------------------------------------

CREATE TRIGGER calculate_fee BEFORE INSERT ON CUSTOMERORDER
FOR EACH ROW
	SET new.totalvalue = new.months *
		-- Sum of fees of the SERVICE Package
		(SELECT V.monthlyfee FROM VALIDITYPERIOD AS V WHERE V.package=new.package AND V.monthsnumber=new.months);

CREATE TRIGGER adjust_Total AFTER INSERT ON choosesproducts 
FOR EACH ROW
	UPDATE CUSTOMERORDER AS c SET
		c.totalvalue = (
		c.totalvalue + c.months *
		-- Sum of all the fees of the Optional Product
		(SELECT O.monthlyfee FROM OPTIONALPRODUCT as O WHERE O.id = new.product))
		WHERE c.id=new.customerorder; --  It also contains the total value

delimiter //
CREATE TRIGGER accepted_payment
	BEFORE UPDATE ON CUSTOMERORDER
	FOR EACH ROW
	IF (new.valid=1 and old.valid<>1)
	THEN
		BEGIN
		
		SET new.rejected=0;

		INSERT INTO SERVICEACTIVATIONSCHEDULE (package, customer, activationdate, deactivationdate) VALUES (new.package, new.customer, new.start, date_add(new.start, interval new.months month));
		
		INSERT INTO purchasesproducts(package, customer, product)
		SELECT co.package, co.customer, ch.product 
		FROM CUSTOMERORDER co JOIN choosesproducts ch ON ch.customerorder=co.id
		WHERE co.id=new.id;
        
		END;
	END IF//

CREATE TRIGGER make_solvent
	AFTER UPDATE ON CUSTOMERORDER
	FOR EACH ROW
	IF (new.valid=1 and old.valid<>1)
	THEN
		BEGIN
		
        SET @insolv=(SELECT MAX(o.rejected) FROM CUSTOMERORDER AS o WHERE o.customer=new.customer);
        IF (@insolv=0) THEN
			UPDATE CUSTOMER SET insolvent=0 WHERE username=new.customer;
		END IF;
        
		END;
	END IF//
        
CREATE TRIGGER set_insolvent
	AFTER UPDATE ON CUSTOMERORDER
	FOR EACH ROW
	BEGIN 
		IF (new.rejected=1 and old.rejected<>1)
		THEN
			UPDATE CUSTOMER SET insolvent=1 WHERE username=new.customer;
		END IF;
	END//
    
CREATE TRIGGER create_auditing
	AFTER UPDATE ON CUSTOMERORDER
	FOR EACH ROW
	BEGIN 
		IF (new.rejected=3 and old.rejected<>3)
		THEN
			BEGIN
			SET @insolvent_mail = (SELECT u.email FROM CUSTOMER AS u WHERE u.username=new.customer);
			INSERT INTO AUDITING (customer, email, lastrejectionamount, lastrejectiondate, lastrejectiontime) VALUES (new.customer, @insolvent_mail, new.totalvalue, CURRENT_DATE(), CURRENT_TIME()); 
			END;
		END IF;
	END//
delimiter ;
