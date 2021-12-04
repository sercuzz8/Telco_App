DROP schema telcoDB;
CREATE schema telcoDB;
USE telcoDB;

CREATE TABLE User ( 
	username varchar(50) PRIMARY KEY,
	password varchar(16) NOT NULL,
	email varchar(50) NOT NULL UNIQUE,  
	insolvent int NOT NULL DEFAULT 0 
	);

CREATE TABLE Employee ( 
	code varchar(16) PRIMARY KEY,
	password varchar(16) NOT NULL
	);
		
CREATE TABLE ServicePackage (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY, 
	name varchar(50) NOT NULL
	);
		
CREATE TABLE ValidityPeriod (
	package int NOT NULL, 
	monthsNumber int NOT NULL, 
	monthlyFee float NOT NULL, 
	PRIMARY KEY (package,monthsNumber), 
	FOREIGN KEY (package) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT Out_Of_Fixed_Values CHECK (monthsNumber in (12, 24, 36))
	);
		
CREATE TABLE CustomerOrder (
	id int NOT NULL PRIMARY KEY,
	date Date NOT NULL, 
	hour Time NOT NULL,
	start Date NOT NULL,
	user varchar(50) NOT NULL, -- Not unique because the same user can buy different packages
	package int NOT NULL, -- The order is associated with the validity period but the validity period is associated with only
	months int NOT NULL, -- one service package thus the validity period is associated with a single service package
	rejected int NOT NULL DEFAULT 0,  
	valid int NOT NULL DEFAULT 0,
	totalValue float,
	FOREIGN KEY (user) REFERENCES User(username),
	FOREIGN KEY (package, months) REFERENCES ValidityPeriod(package, monthsNumber) -- ON DELETE CASCADE ON UPDATE CASCADE we won't delete the order tuple if a validity period is updated or deleted
	);

CREATE TABLE Auditing (
	user varchar(50) PRIMARY KEY, 
	email varchar(50), -- we set it null by default because we will populate the table by the use of triggers
						-- in addition, this table does not change over its lifetime
	lastRejectionAmount float NOT NULL, 
	lastRejectionDate Date NOT NULL, 
	lastRejectionTime Time NOT NULL,
	FOREIGN KEY (user) REFERENCES User(username) ON DELETE CASCADE ON UPDATE CASCADE
	);
		

CREATE TABLE Service (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY
	);


CREATE TABLE FixedPhone (
	service int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	FOREIGN KEY (service) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE MobilePhone (
	service int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	minNumber int NOT NULL,  
	smsNumber int NOT NULL, 
	minFee float NOT NULL,  
	smsFee float NOT NULL, 
	FOREIGN KEY (service) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE MobileInternet (
	service int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	gbNumber int NOT NULL,
	gbFee float NOT NULL, 
	FOREIGN KEY (service) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
	);


CREATE TABLE FixedInternet (
	service int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	gbNumber int NOT NULL, 
	gbFee float NOT NULL, 
	FOREIGN KEY (service) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE OptionalProduct (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name varchar(50) NOT NULL,
	monthlyFee float NOT NULL
	);

CREATE TABLE ServiceActivationSchedule (
	package int NOT NULL, 
	user varchar(50) NOT NULL,
	activationDate Date, 
	deactivationDate Date,
	PRIMARY KEY (package, user),
	FOREIGN KEY (user) REFERENCES User(username) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (package) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE
	);


CREATE TABLE offersProducts (
	package int NOT NULL,
	product int NOT NULL,
	PRIMARY KEY (package, product),
	FOREIGN KEY (package) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE includesServices (
	package int NOT NULL,
	service int NOT NULL,
	PRIMARY KEY (package, service),
	FOREIGN KEY (package) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (service) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE choosesProducts (
	customerOrder int NOT NULL,
	product int NOT NULL,
	PRIMARY KEY (customerOrder, product),
	FOREIGN KEY (customerOrder) REFERENCES CustomerOrder(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE TABLE purchasesProducts (
	package int NOT NULL,
	user varchar(50) NOT NULL,
	product int NOT NULL,
	PRIMARY KEY (package, user, product),
	FOREIGN KEY (package) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (user) REFERENCES User(username) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE
	);

CREATE VIEW PurchasesPackage (package, purchases) AS
SELECT package, COUNT(*)
FROM ServiceActivationSchedule 
GROUP BY package
ORDER BY package ASC;

CREATE VIEW PackageValidityPeriod (package, months, purchases) AS
SELECT package, TIMESTAMPDIFF(MONTH,activationDate,deactivationDate), COUNT(*)
FROM ServiceActivationSchedule	
GROUP BY package, TIMESTAMPDIFF(MONTH,activationDate,deactivationDate)
ORDER BY package, TIMESTAMPDIFF(MONTH,activationDate,deactivationDate);

CREATE VIEW ValiditySaleProduct (package, withProducts, withoutProducts) AS
SELECT s.package, SUM(c.totalValue), SUM(v.monthsNumber*v.monthlyFee)
FROM ServiceActivationSchedule AS s, CustomerOrder AS c, ValidityPeriod as v
WHERE s.package = c.package AND s.user=c.user AND c.package=v.package AND c.months=v.monthsNumber
GROUP BY s.package
ORDER BY s.package ASC;

CREATE VIEW AVGProductsSold (package, avgProducts) AS
SELECT o.package, COUNT(p.product)/COUNT(o.product)
FROM  offersProducts o LEFT JOIN purchasesProducts p ON p.package=o.package AND p.product=o.product
GROUP BY o.package;

CREATE VIEW InsolventUsers(insolvent, rejectedOrder, alertDate) AS
SELECT c.user, c.id, a.lastRejectionDate
FROM CustomerOrder c LEFT JOIN Auditing a ON c.user=a.user
WHERE rejected>0
ORDER BY c.user ASC;

CREATE VIEW BestSellers(product, numOfSales) AS
SELECT p.product, COUNT(*) AS NUM
FROM ServiceActivationSchedule AS s, purchasesProducts as p
WHERE s.package = p.package AND s.user=p.user
GROUP BY p.product
ORDER BY NUM DESC;
-- LIMIT 5;

-- TODO: Add the materialized views of the data, to be populated by triggers
CREATE TRIGGER Calculate_Fee BEFORE INSERT ON CustomerOrder
FOR EACH ROW
	SET new.totalValue = new.months *
		-- Sum of fees of the Service Package
		(SELECT V.monthlyFee FROM ValidityPeriod AS V WHERE V.package=new.package AND V.monthsNumber=new.months);

CREATE TRIGGER Adjust_Total AFTER INSERT ON choosesProducts 
FOR EACH ROW
	UPDATE CustomerOrder AS c SET
		c.totalValue = (
		c.totalValue + c.months *
		-- Sum of all the fees of the Optional Product
		(SELECT O.monthlyFee FROM OptionalProduct as O WHERE O.id = new.product))
		WHERE c.id=new.customerOrder; --  It also contains the total value

delimiter //
CREATE TRIGGER Create_Fixed_Phone_Service BEFORE INSERT ON FixedPhone
	FOR EACH ROW
	BEGIN
	IF new.service IN (SELECT id FROM Service WHERE id=new.service) THEN 
		SET new.service = ((SELECT MAX(id) FROM Service) + 1);
	END IF;
	INSERT INTO Service(id) VALUES (new.service);
	END;

CREATE TRIGGER Create_Mobile_Phone_Service BEFORE INSERT ON MobilePhone
	FOR EACH ROW
	BEGIN
	IF new.service IN (SELECT id FROM Service WHERE id=new.service) THEN 
		SET new.service = ((SELECT MAX(id) FROM Service) + 1);
	END IF;
	INSERT INTO Service(id) VALUES (new.service);
	END;

CREATE TRIGGER Create_Fixed_Internet_Service BEFORE INSERT ON FixedInternet
	FOR EACH ROW
	BEGIN
	IF new.service IN (SELECT id FROM Service WHERE id=new.service) THEN 
		SET new.Service = ((SELECT MAX(id) FROM Service) + 1);
	END IF;
	INSERT INTO Service(id) VALUES (new.service);
	END;

CREATE TRIGGER Create_Mobile_Internet_Service BEFORE INSERT ON MobileInternet
	FOR EACH ROW
	BEGIN
	IF new.service IN (SELECT id FROM Service WHERE id=new.service) THEN 
		SET new.Service = ((SELECT MAX(id) FROM Service) + 1);
	END IF;
	INSERT INTO Service(id) VALUES (new.service);
	END;

CREATE TRIGGER Product_Not_On_package 
	BEFORE INSERT ON choosesProducts 
	FOR EACH ROW
	BEGIN
	IF (new.product NOT IN (
		SELECT op.product FROM offersProducts AS op WHERE op.package =
			(SELECT co.package from CustomerOrder AS co WHERE co.id=new.customerOrder)))
		THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not offered with the package';
	END IF;
	END;

CREATE TRIGGER Accepted_Payment
	AFTER UPDATE ON CustomerOrder
	FOR EACH ROW
	IF (new.valid=1 and old.valid<>1)
	THEN
		BEGIN
		INSERT INTO ServiceActivationSchedule (package, user, activationDate, deactivationDate) VALUES (new.package, new.user, new.start, date_add(new.start, interval new.months month));
		
		INSERT INTO purchasesProducts(package, user, product)
		SELECT co.package, co.user, ch.product 
		FROM CustomerOrder co JOIN choosesProducts ch ON ch.customerOrder=co.id
		WHERE co.id=new.id;

		END;
	END IF;

CREATE TRIGGER Failed_Payments
	AFTER UPDATE ON CustomerOrder
	FOR EACH ROW
	BEGIN 
		IF (new.rejected=1 and old.rejected<>1)
		THEN
			UPDATE User SET insolvent=1 WHERE username=new.user;
		ELSEIF (new.rejected=3 and old.rejected<>3)
		THEN
			BEGIN
			SET @insolvent_mail = (SELECT u.email FROM User AS u WHERE u.username=new.user);
			INSERT INTO Auditing (user, email, lastRejectionAmount, lastRejectionDate, lastRejectionTime) values (new.user, @insolvent_mail, new.totalValue, CURRENT_DATE(), CURRENT_TIME()); 
			END;
		END IF;
	END;
delimiter;