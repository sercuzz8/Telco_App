
-- ENTITIES

-- User and Weak Entities

--The consumer application has a public Landing page with a form for login and a form for registration.
CREATE TABLE User (
	id varchar(16) NOT NULL UNIQUE, -- ** see auditing table ** -- 
	username varchar(50) NOT NULL UNIQUE, -- Registration requires a username,
	password varchar(16) NOT NULL, -- Registration requires a password
	email varchar(50) NOT NULL UNIQUE,  -- Registration requires an email
	insolvent int default '0', -- If the external service rejects the billing, the order is put in the rejected status and the user is flagged
					-- as insolvent.
	PRIMARY KEY (id));
	

CREATE TABLE CustomerOrder (
	-- The order is associated with the chosen optional products.. 	
	-- The order is associated with the validity period of its service package
	id int NOT NULL AUTO_INCREMENT, -- an ID of creation
	date Date NOT NULL, -- a date of creation
	hour Time NOT NULL, -- an hour of creation
	userId varchar(16) NOT NULL UNIQUE, -- The order is associated with the user
	packageId int NOT NULL, -- The order is associated with the service package, 
	start Date NOT NULL, -- It contains the start date of the subscription
	valid int NOT NULL DEFAULT ‘0’,  -- If the external service accepts the billing, the order is marked as valid 
	monthsNumber int NOT NULL,
	monthlyFee float NOT NULL,
	totalVaue float NOT NULL, --  It also contains the total value
	PRIMARY KEY(id),
	FOREIGN KEY (packageId) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (monthsNumber, monthlyFee) REFERENCES ValidityPeriod(monthsNumber, monthlyFee) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT ’totalChk’ CHECK (totalValue = monthlyFee*monthsNumber + (’SELECT sum(monthlyFee) FROM ProductCustomerOrder WHERE customerOrderId = id’)*monthsNumber),
	CONSTRAINT ‘validitiCheck’ CHECK((monthsNumber, monthlyFee) = (‘SELECT monthsNumber, monthlyFee FROM ValidityPeriod WHERE packageId = packageId’))

-- When the same user causes three failed payments, an alert is created in a dedicated auditing table, with the user Id, username, email, and the amount, date and time of the last rejection.

CREATE TABLE AuditingTable (
	userId varchar(16) NOT NULL UNIQUE,
	username varchar(50) NOT NULL UNIQUE,
	email varchar(50) NOT NULL UNIQUE,
	lastRejectionAmount float NOT NULL,
	lastRejectionDate Date NOT NULL,
	lastRejectionTime Time NOT NULL,
	PRIMARY KEY (userId)
	FOREIGN KEY (userId) REFERENCES User(id) ON DELETE CASCADE ON UPDATE CASCADE);
	
-- Service and its specializations

-- Services are of four types: fixed phone, mobile phone, fixed internet,and mobile internet.
CREATE TABLE Service (
	id int NOT NULL AUTO_INCREMENT,
	name varchar(50) not null,
	PRIMARY KEY(id));


CREATE TABLE FixedPhone (
	id int NOT NULL AUTO_INCREMENT,
	PRIMARY KEY (id),
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE);

 
-- The mobile phone service specifies 
CREATE TABLE MobilePhone (
	id int NOT NULL AUTO_INCREMENT,
	minNumber int NOT NULL, -- the number of minutes included in the package 
	smsNumber int NOT NULL, -- the number of SMSs included in the package 
	minFee float NOT NULL, -- plus the fee for extra minutes 
	smsFee float NOT NULL, -- 
	PRIMARY KEY (id),
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE);

-- The mobile internet services specify : 
CREATE TABLE MobileInternet (
	id int NOT NULL AUTO_INCREMENT,
	gbNumber int NOT NULL, -- the number of Gigabytes included in the package
	gbFee float NOT NULL, -- and the fee for extra Gigabytes
	PRIMARY KEY (id),
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE);

-- The fixed internet services specify 
CREATE TABLE FixedInternet (
	id int NOT NULL AUTO_INCREMENT,
	gbNumber int NOT NULL, -- the number of Gigabytes included in the package
	gbFee float NOT NULL, -- and the fee for extra Gigabytes
	PRIMARY KEY (id),
	FOREIGN KEY (id) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE);

-- ----------------------------------------------------------------------------------------


-- An optional product has a name and a monthly fee independent of the validity period
--duration. 
CREATE TABLE OptionalProduct (
	id int NOT NULL AUTO_INCREMENT,
	name varchar(50) NOT NULL,
	monthlyFee float NOT NULL,
	-- validity period the same as the service package
	PRIMARY KEY (id));

-- Service Package and Weak Entities

-- A service package  
CREATE TABLE ServicePackage (
	id int NOT NULL AUTO_INCREMENT, -- has an ID
	name varchar(50) NOT NULL, -- and a name (e.g., “Basic”, “Family”, “Business”, “All Inclusive”, etc). 
	PRIMARY KEY (id));
	
CREATE TABLE ValidityPeriod (
	packageId int NOT NULL, -- A service package must be associated with one validity period
	monthsNumber int NOT NULL, -- A validity period specifies the number of months (12, 24, or 36)
	monthlyFee float NOT NULL, -- Each validity period has a different monthly fee (e.g., 20€/month for 12 months, 18€/month for 24 months, and 15€ /month for 36 months).
	customerOrderId int NOT NULL,
	PRIMARY KEY (packageId), 
	FOREIGN KEY (packageId) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (customerOrderId) REFERENCES CustomerOrder(id) ON DELETE CASCADE ON UPDATE CASCADE,
	CONSTRAINT 'fixedNumber' CHECK (monthsNumber=12 OR monthsNumber=24 OR monthsNumber=36));
	-- The validity period of an optional product is the same as the validity period that the user has chosen for the service package

-- If the external service accepts the billing, the order is marked as valid and a service activation schedule is created for the user

CREATE TABLE ServiceActivationSchedule (
	userId varchar(50) NOT NULL, -- To activate for the user
	serviceId int NOT NULL, -- A service activation schedule is a record of the services
	--  and optional products 
	activationDate Date NOT NULL, -- With their date of activation 
	deactivationDate Date NOT NULL, --  With their date of deactivation
	PRIMARY KEY (userId),
	FOREIGN KEY (userId) REFERENCES User(id) --TODO: Penso che nel caso in cui lo user venga cancellato sia comunque necessario mantenere questa tavola per motivi di contabilità
	FOREIGN KEY (serviceId) REFERENCES Service(id) --TODO: Come sopra
)

-- M:M RELATIONS ---------------------------------------------------------------------------------------------

-- A package may be associated with one or more optional products (e.g., an SMS news feed, an internet TV channel, etc.)
-- The same optional product can be offered in different service packages. !!!
CREATE TABLE PackageProduct (
	packageId int NOT NULL,
	productId int NOT NULL,
	PRIMARY KEY (packageId, productId),
	FOREIGN KEY (packageId) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (productId) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE);

-- A service package comprises one or more services. No additional constraints are specified, thus we assume that
-- there is a N:N relation between service packages and services
CREATE TABLE PackageService (
	packageId int NOT NULL,
	serviceId int NOT NULL,
	PRIMARY KEY (packageId, serviceId),
	FOREIGN KEY (packageId) REFERENCES ServicePackage(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (serviceId) REFERENCES Service(id) ON DELETE CASCADE ON UPDATE CASCADE);

-- N:N relation between products and customer orders (which optional products are put in which customer order)
CREATE TABLE ProductCustomerOrder (
	customerOrderId int NOT NULL,
	productId int NOT NULL,
	PRIMARY KEY (customerOrderId, productId),
	FOREIGN KEY (customerOrderId) REFERENCES CustomerOrder(id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (productId) REFERENCES OptionalProduct(id) ON DELETE CASCADE ON UPDATE CASCADE);

-- -----------------------------------------------------------------------------------------------------------------

