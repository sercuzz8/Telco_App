
-- ENTITIES

-- User and Weak Entities

-- The consumer application has a public Landing page with a form for login and a form for registration.
CREATE TABLE User ( 
	username varchar(50) NOT NULL UNIQUE PRIMARY KEY, -- Registration requires a username,
	password varchar(16) NOT NULL, -- Registration requires a password
	email varchar(50) NOT NULL UNIQUE,  -- Registration requires an email
	insolvent int DEFAULT 0 -- If the external service rejects the billing, the order is put in the rejected status and the user is flagged
					-- as insolvent.
	);
	
CREATE TABLE CustomerOrder (
	-- The order is associated with the chosen optional products.. 	
	-- The order is associated with the validity period of its service package
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY, -- an ID of creation
	date Date NOT NULL, -- a date of creation
	hour Time NOT NULL, -- an hour of creation
	username varchar(50) NOT NULL UNIQUE, -- The order is associated with the user
	packageId int NOT NULL, -- The order is associated with the service package, 
	monthsNumber int NOT NULL, -- ** Actually the order is associated with the validity period but the validity period is associated with only 
					-- one service package thus the validity period is associated with a single service package **
	start Date NOT NULL, -- It contains the start date of the subscription
	valid int NOT NULL DEFAULT 0,  -- If the external service accepts the billing, the order is marked as valid 
	totalVaue float NOT NULL, --  It also contains the total value
	FOREIGN KEY (packageId, monthsNumber) REFERENCES ValidityPeriod(packageId, monthsNumber) ON DELETE CASCADE ON UPDATE CASCADE ,
	CONSTRAINT ’totalChk’ CHECK (totalValue = monthlyFee*monthsNumber + (SELECT sum(monthlyFee) FROM ProductCustomerOrder WHERE customerOrderId = id)*monthsNumber),
	CONSTRAINT ‘validityCheck’ CHECK( monthsNumber = (SELECT monthsNumber FROM ValidityPeriod WHERE packageId = packageId))
    );

-- When the same user causes three failed payments, an alert is created in a dedicated auditing table,
CREATE TABLE AuditingTable (
	username varchar(50) NOT NULL UNIQUE PRIMARY KEY, -- with the user username
	email varchar(50) NOT NULL UNIQUE, -- with the user email
	lastRejectionAmount float NOT NULL, -- the amount of the last rejection
	lastRejectionDate Date NOT NULL, -- the date of the last rejection
	lastRejectionTime Time NOT NULL, -- the time of the last rejection
	FOREIGN KEY (username) REFERENCES User(username) ON DELETE CASCADE ON UPDATE CASCADE
    );
	
-- Service and its specializations

-- Services are of four types:
CREATE TABLE Service (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name varchar(50) NOT NULL
    );

-- fixed phone,
CREATE TABLE FixedPhone (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- mobile phone,
-- The mobile phone service specifies 
CREATE TABLE MobilePhone (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	minNumber int NOT NULL, -- the number of minutes included in the package 
	smsNumber int NOT NULL, -- the number of SMSs included in the package 
	minFee float NOT NULL, -- plus the fee for extra minutes 
	smsFee float NOT NULL, -- plus the fee for extra SMSs
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- mobile internet
-- The mobile internet services specify : 
CREATE TABLE MobileInternet (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	gbNumber int NOT NULL, -- the number of Gigabytes included in the package
	gbFee float NOT NULL, -- and the fee for extra Gigabytes
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- fixed internet
-- The fixed internet services specify 
CREATE TABLE FixedInternet (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	gbNumber int NOT NULL, -- the number of Gigabytes included in the package
	gbFee float NOT NULL, -- and the fee for extra Gigabytes
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- ----------------------------------------------------------------------------------------

-- An optional product has a name and a monthly fee independent of the validity period duration. 
-- The validity period of an optional product is the same as the validity period that the user has chosen for the service package
CREATE TABLE OptionalProduct (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY,
	name varchar(50) NOT NULL,
	monthlyFee float NOT NULL
    );

-- Service Package and Weak Entities

-- A service package  
CREATE TABLE ServicePackage (
	id int NOT NULL AUTO_INCREMENT PRIMARY KEY, -- has an ID
	name varchar(50) NOT NULL -- and a name (e.g., “Basic”, “Family”, “Business”, “All Inclusive”, etc). 
	);
	
CREATE TABLE ValidityPeriod (
	packageId int NOT NULL, -- A service package must be associated with one validity period
	monthsNumber int NOT NULL, -- A validity period specifies the number of months (12, 24, or 36)
	monthlyFee float NOT NULL, -- Each validity period has a different monthly fee (e.g., 20€/month for 12 months, 18€/month for 24 months, and 15€ /month for 36 months).
	PRIMARY KEY (packageId,monthsNumber), 
	FOREIGN KEY (packageId) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT CHECK (monthsNumber=12 OR monthsNumber=24 OR monthsNumber=36)
    );
	

-- If the external service accepts the billing, the order is marked as valid and a service activation schedule is created for the user

CREATE TABLE ServiceActivationSchedule (
	serviceId int NOT NULL, -- A service activation schedule is a record of the services
	--  and optional products (see above)
	activationDate Date NOT NULL, -- With their date of activation 
	deactivationDate Date NOT NULL, --  With their date of deactivation
	FOREIGN KEY (username) REFERENCES User(username), -- TODO: Penso che nel caso in cui lo user venga cancellato sia comunque necessario mantenere questa tavola per motivi di contabilità
	FOREIGN KEY (serviceId) REFERENCES Service(id) -- TODO: Come sopra 
	);

-- M:M RELATIONS ---------------------------------------------------------------------------------------------

-- A package may be associated with one or more optional products (e.g., an SMS news feed, an internet TV channel, etc.)
-- The same optional product can be offered in different service packages. !!!
CREATE TABLE offersProducts (
	packageId int NOT NULL,
	productId int NOT NULL,
	PRIMARY KEY (packageId, productId),
	FOREIGN KEY (packageId) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (productId) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- A service package comprises one or more services. No additional constraints are specified, thus we assume that
-- there is a N:N relation between service packages and services
CREATE TABLE includesServices (
	packageId int NOT NULL,
	serviceId int NOT NULL,
	PRIMARY KEY (packageId, serviceId),
	FOREIGN KEY (packageId) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (serviceId) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE
    );

-- N:N relation between products and customer orders (which optional products are put in which customer order)
CREATE TABLE purchasesProducts (
	customerOrderId int NOT NULL,
	productId int NOT NULL,
	PRIMARY KEY (customerOrderId, productId),
	FOREIGN KEY (customerOrderId) REFERENCES CustomerOrder(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (productId) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE
    );
