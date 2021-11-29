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
	packageId int NOT NULL, 
	monthsNumber int NOT NULL, 
	monthlyFee float NOT NULL, 
	PRIMARY KEY (packageId,monthsNumber), 
	FOREIGN KEY (packageId) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT Out_Of_Fixed_Values CHECK (monthsNumber in (12, 24, 36))
    );
	
CREATE TABLE CustomerOrder (
	id int NOT NULL PRIMARY KEY,
	date Date NOT NULL, 
	hour Time NOT NULL,
	start Date NOT NULL,
	user varchar(50) NOT NULL UNIQUE, 
	package int NOT NULL, -- The order is associated with the validity period but the validity period is associated with only
	months int NOT NULL, -- one service package thus the validity period is associated with a single service package
	rejected int NOT NULL DEFAULT 0,  -- We assume that the most natural occurence is that the order is valid
	totalValue float,
	FOREIGN KEY (user) REFERENCES User(username),
	FOREIGN KEY (package, months) REFERENCES ValidityPeriod(packageId, monthsNumber) -- ON DELETE CASCADE ON UPDATE CASCADE we won't delete the order tuple if a validity period is updated or deleted
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
	serviceId int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	FOREIGN KEY (serviceId) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE MobilePhone (
	serviceId int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	minNumber int NOT NULL,  
	smsNumber int NOT NULL, 
	minFee float NOT NULL,  
	smsFee float NOT NULL, 
	FOREIGN KEY (serviceId) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE MobileInternet (
	serviceId int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	gbNumber int NOT NULL,
	gbFee float NOT NULL, 
	FOREIGN KEY (serviceId) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
    );


CREATE TABLE FixedInternet (
	serviceId int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	gbNumber int NOT NULL, 
	gbFee float NOT NULL, 
	FOREIGN KEY (serviceId) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
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
	packageId int NOT NULL,
	productId int NOT NULL,
	PRIMARY KEY (packageId, productId),
	FOREIGN KEY (packageId) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (productId) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE includesServices (
	packageId int NOT NULL,
	serviceId int NOT NULL,
	PRIMARY KEY (packageId, serviceId),
	FOREIGN KEY (packageId) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (serviceId) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE TABLE purchasesProducts (
	customerOrderId int NOT NULL,
	productId int NOT NULL,
	PRIMARY KEY (customerOrderId, productId),
	FOREIGN KEY (customerOrderId) REFERENCES CustomerOrder(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (productId) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

CREATE VIEW PurchasesPackage (package, purchases) AS
SELECT package, COUNT(*)
FROM ServiceActivationSchedule 
GROUP BY package;

CREATE VIEW PackageValidityPeriod (package, months, purchases) AS
SELECT package, TIMESTAMPDIFF(MONTH,activationDate,deactivationDate), COUNT(*)
FROM ServiceActivationSchedule	
GROUP BY package, TIMESTAMPDIFF(MONTH,activationDate,deactivationDate)
ORDER BY package, TIMESTAMPDIFF(MONTH,activationDate,deactivationDate);

CREATE VIEW ValiditySaleProduct (package, withProducts, withoutProducts) AS
SELECT s.package, SUM(c.totalValue), SUM(v.monthsNumber*v.monthlyFee)
FROM ServiceActivationSchedule AS s, CustomerOrder AS c, ValidityPeriod as v
WHERE s.package = c.package AND s.user=c.user AND c.package=v.packageId AND c.months=v.monthsNumber
GROUP BY s.package;

CREATE VIEW AVGProductsSold (package, avgProducts) AS
SELECT s.package, COUNT(p.productId)
FROM ServiceActivationSchedule AS s, CustomerOrder AS c, purchasesProducts AS p
WHERE s.package = c.package AND s.user=c.user AND p.customerOrderId=c.id
GROUP BY s.package, c.user;

CREATE VIEW InsolventUsers(insolvent, rejectedOrder, alertDate) AS
SELECT c.user, c.id, a.lastRejectionDate
FROM CustomerOrder c LEFT JOIN Auditing a ON c.user=a.user
WHERE rejected>0;

CREATE VIEW BestSellers(productId, numOfSales) AS
SELECT p.productId, COUNT(*) AS NUM
FROM ServiceActivationSchedule AS s, CustomerOrder AS c, purchasesProducts AS p
WHERE s.package = c.package AND s.user=c.user AND p.customerOrderId=c.id
GROUP BY p.productId
ORDER BY NUM DESC;
-- LIMIT 5;

-- TODO: Add the materialized views of the data, to be populated by triggers

CREATE TRIGGER Calculate_Fee BEFORE INSERT ON CustomerOrder
FOR EACH ROW
	SET new.totalValue = new.months *
 		-- Sum of fees of the Service Package
 		(SELECT V.monthlyFee FROM ValidityPeriod AS V WHERE V.packageId=new.package AND V.monthsNumber=new.months);

CREATE TRIGGER Adjust_Total AFTER INSERT ON purchasesProducts 
FOR EACH ROW
	UPDATE CustomerOrder AS c SET
        c.totalValue = (
		c.totalValue + c.months *
 		-- Sum of all the fees of the Optional Product
 		(SELECT O.monthlyFee FROM OptionalProduct as O WHERE O.id = new.productId))
        WHERE c.id=new.customerOrderId; --  It also contains the total value

delimiter //
CREATE TRIGGER Create_Fixed_Phone_Service BEFORE INSERT ON FixedPhone
	FOR EACH ROW
    BEGIN
	IF new.serviceId IN (SELECT id FROM Service WHERE id=new.ServiceId) THEN 
		SET new.ServiceId = ((SELECT MAX(id) FROM Service) + 1);
	END IF;
    INSERT INTO Service(id) VALUES (new.serviceId);
    END;

CREATE TRIGGER Create_Mobile_Phone_Service BEFORE INSERT ON MobilePhone
	FOR EACH ROW
    BEGIN
	IF new.serviceId IN (SELECT id FROM Service WHERE id=new.ServiceId) THEN 
		SET new.ServiceId = ((SELECT MAX(id) FROM Service) + 1);
	END IF;
    INSERT INTO Service(id) VALUES (new.serviceId);
    END;

CREATE TRIGGER Create_Fixed_Internet_Service BEFORE INSERT ON FixedInternet
	FOR EACH ROW
    BEGIN
	IF new.serviceId IN (SELECT id FROM Service WHERE id=new.ServiceId) THEN 
		SET new.ServiceId = ((SELECT MAX(id) FROM Service) + 1);
	END IF;
    INSERT INTO Service(id) VALUES (new.serviceId);
    END;

CREATE TRIGGER Create_Mobile_Internet_Service BEFORE INSERT ON MobileInternet
	FOR EACH ROW
    BEGIN
	IF new.serviceId IN (SELECT id FROM Service WHERE id=new.ServiceId) THEN 
		SET new.ServiceId = ((SELECT MAX(id) FROM Service) + 1);
	END IF;
    INSERT INTO Service(id) VALUES (new.serviceId);
    END;

CREATE TRIGGER Product_Not_On_package 
	BEFORE INSERT ON purchasesProducts 
	FOR EACH ROW
    BEGIN
	IF (new.productId NOT IN (
		SELECT OP.productId FROM offersProducts AS OP WHERE OP.packageId =
			(SELECT CO.package from CustomerOrder AS CO WHERE CO.id=new.customerOrderId)))
		THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Product not offered with the package';
	END IF;
	END;

CREATE TRIGGER Failed_Payments
	BEFORE UPDATE ON CustomerOrder
	FOR EACH ROW
    BEGIN 
		IF (new.rejected=1)
		THEN
			UPDATE User SET insolvent=1 WHERE username=new.user ;
		ELSEIF (new.rejected=3)
        THEN
			BEGIN
			SET @insolvent_mail = (SELECT u.email FROM User AS u WHERE u.username=new.user);
			INSERT INTO Auditing (user, email, lastRejectionAmount, lastRejectionDate, lastRejectionTime) values (new.user, @insolvent_mail ,new.totalValue, CURRENT_DATE(), CURRENT_TIME()); 
			END;
		END IF;
	END;
    
CREATE TRIGGER Calculate_Activaction 
	BEFORE INSERT ON ServiceActivationSchedule
	FOR EACH ROW
		BEGIN
		SET @interval = (SELECT C.months FROM CustomerOrder as C WHERE C.user=new.user AND C.package = new.package);
		SET	new.activationDate = (SELECT C.start FROM CustomerOrder as C WHERE C.user=new.user AND C.package = new.package);
		SET new.deactivationDate = date_add(new.activationDate, interval @interval month);
		END;
delimiter;