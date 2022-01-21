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
	customer varchar(50), -- Not unique because the same customer can buy different packages
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
    
-- TODO: Make this views materialized

CREATE TABLE PURCHASEPERPACKAGE (
	package int PRIMARY KEY,
    purchases int
);

delimiter //
CREATE TRIGGER update_purchases
AFTER INSERT ON SERVICEACTIVATIONSCHEDULE
FOR EACH ROW
BEGIN
	SET @old_purchases = 0;
    SELECT purchases
    FROM PURCHASEPERPACKAGE
    WHERE package = new.package 
    INTO @old_purchases;
    
    SET @new_purchases = @old_purchases + 1;
    UPDATE PURCHASEPERPACKAGE SET purchases = @new_purchases WHERE package = new.package;
END//
delimiter ;
-- delete service package
CREATE TRIGGER delete_pack
AFTER DELETE ON SERVICEPACKAGE
FOR EACH ROW
DELETE FROM PURCHASEPERPACKAGE WHERE package = old.id;
-- new service package
CREATE TRIGGER new_pack
AFTER INSERT ON SERVICEPACKAGE
FOR EACH ROW 
INSERT INTO PURCHASEPERPACKAGE VALUES (new.id,0);


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
	SET @old_purchases = 0;
	SET @new_months = TIMESTAMPDIFF(MONTH,new.activationdate,new.deactivationdate);
    SELECT purchases
    FROM PURCHASEPERVALIDITY
    WHERE package = new.package AND months = @new_months
    INTO @old_purchases;
    
    SET @new_purchases = @old_purchases + 1;
    UPDATE PURCHASEPERVALIDITY SET purchases = @new_purchases WHERE package = new.package AND months = @new_months;
END//

-- new service package
CREATE TRIGGER new_package
AFTER INSERT ON SERVICEPACKAGE
FOR EACH ROW 	
BEGIN
	INSERT INTO PURCHASEPERVALIDITY VALUES (new.id,12,0);
	INSERT INTO PURCHASEPERVALIDITY VALUES (new.id,24,0);
	INSERT INTO PURCHASEPERVALIDITY VALUES (new.id,36,0);
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
	SET @old_withProd = 0;
    SET @old_withoutProd = 0;
    SET @vp_value = 0;
	SET @new_months = TIMESTAMPDIFF(MONTH,new.activationdate,new.deactivationdate);
	SET @total_value = (SELECT totalvalue FROM CUSTOMERORDER WHERE package=new.package AND customer=new.customer AND months=@new_months);
    SELECT withproducts, withoutproducts
    FROM SALEPERPACKAGE
    WHERE package = new.package
    INTO @old_withProd,@old_withoutProd;
    
    SELECT monthsnumber*monthlyfee
    FROM VALIDITYPERIOD
    WHERE package = new.package AND monthsnumber = @new_months
    INTO @vp_value;
    
    SET @new_withProd = @old_withProd + @total_value;
    SET @new_withoutProd = @old_withoutProd + @vp_value;
    
    UPDATE SALEPERPACKAGE SET withproducts = @new_withProd, withoutproducts=@new_withoutProd
    WHERE package = new.package;
END//
delimiter ;

CREATE VIEW AVERAGEPRODUCTSOLD(package, avgproductsold) AS
SELECT package, avg(productssold) as avgproductsold
FROM (	SELECT c.id as orderId, c.package, count(*) as productsSold
		FROM CUSTOMERORDER c JOIN choosesproducts ON  customerorder = c.id
		GROUP BY c.id, c.package) AS productssoldperorder 
GROUP BY package;        

-- View for the insolvent customers
CREATE TABLE INSOLVENTCUSTOMER (
	insolvent varchar(50) PRIMARY KEY,
    rejectedOrder int,
    alertDate date
);
-- manteinance of insolventcustomer
delimiter //
CREATE TRIGGER new_insolvent
AFTER INSERT ON AUDITING
FOR EACH ROW
BEGIN
	SET @suspended_order = 0;
    SELECT id 
    FROM CUSTOMERORDER c LEFT JOIN AUDITING a ON c.customer = a.customer
    WHERE rejected>0 AND c.customer = new.customer
    INTO @suspended_order;
    
    INSERT INTO INSOLVENTCUSTOMER VALUES 
    (new.customer,@suspended_order,new.lastrejectiondate);
END//
delimiter ;

CREATE TRIGGER remove_insolvent
AFTER DELETE ON AUDITING
FOR EACH ROW
DELETE FROM INSOLVENTCUSTOMER WHERE customer=old.customer AND alertDate = old.lastrejectiondate;

-- View for the best seller
CREATE TABLE BESTSELLER (
	product int PRIMARY KEY,
    numOfSales int
);
-- BESTSELLER triggers
-- new product in optional product
CREATE TRIGGER add_product
AFTER INSERT ON OPTIONALPRODUCT
FOR EACH ROW
INSERT INTO BESTSELLER VALUES (new.id, 0);
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
	SET @old_sales = 0;
        
	SELECT IFNULL(numOfSales,0)
	FROM BESTSELLER
	WHERE product = new.product
	INTO @old_sales;
	
	SET @new_sales = @old_sales + 1;
	UPDATE BESTSELLER SET numOfSales = @new_sales WHERE product = new.product;
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
