-- Testing part:

-- 1. Avoid duplicate mail
DELETE FROM User WHERE username='sergio';
DELETE FROM User WHERE username='ale';
INSERT INTO User (username, password, email, insolvent) VALUES ('sergio', 'sergio', 'sergio@sergio.com', 0);
INSERT INTO User (username, password, email, insolvent) VALUES ('ale', 'ale', 'sergio@sergio.com', 0);
-- Result: Ale not written because of duplicate email = OK

-- 3. No two different services (e.g. Mobile and Fixed) with the same ID
-- RESULT: 

-- 4. No validity period without any package
DELETE FROM ServicePackage WHERE id=1 AND monthsNumber=12;
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
-- Result: Not operated because no parent = OK
DELETE FROM ServicePackage WHERE id=1;
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
-- Result: OK


-- 5. Only 12,24,36 Months in ValidityPeriod    
DELETE FROM ServicePackage WHERE id=1;
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 11, 12.5);
-- Result: Not operated because constraint on number of months is violated
DELETE FROM ServicePackage WHERE id=1;
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 24, 12.5);
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 36, 12.5);
-- RESULT: OK

-- 6.  A package may be associated with one or more optional products
DELETE FROM ServicePackage WHERE id=1;
DELETE FROM ValidityPeriod WHERE packageId=1 AND monthsNumber=12;
DELETE FROM OptionalProduct WHERE id=1;
DELETE FROM OptionalProduct WHERE id=2;
DELETE FROM offersProducts WHERE packageId=1;
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (2, "TV Addition", 15.0);
INSERT INTO offersProducts (packageId, productId) VALUES (1,1);
INSERT INTO offersProducts (packageId, productId) VALUES (1,2);
SELECT name FROM OptionalProduct WHERE id in ( SELECT productId from offersProducts WHERE packageId=1);
-- RESULT: both products in one service package = OK

-- 7. A customer can buy only optional products offered in the package

-- 8. Total Value of A customer order

DELETE FROM User WHERE username='sergio';
DELETE FROM ServicePackage WHERE id=1;
DELETE FROM ValidityPeriod WHERE packageId=1 AND monthsNumber=12;
DELETE FROM OptionalProduct WHERE id=1;
DELETE FROM OptionalProduct WHERE id=2;
DELETE FROM offersProducts WHERE packageId=1;
DELETE FROM purchasesProducts WHERE customerOrderId=1;
DELETE FROM CustomerOrder WHERE id=1;
INSERT INTO User (username, password, email, insolvent) VALUES ('sergio', 'sergio', 'sergio@sergio.com', 0);
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (2, "TV Addition", 15.0);
INSERT INTO offersProducts (packageId, productId) VALUES (1,1);
INSERT INTO offersProducts (packageId, productId) VALUES (1,2);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months, rejected, totalValue) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12, 0, 0);
INSERT INTO purchasesProducts (customerOrderId, productId) VALUES (1,1);
INSERT INTO purchasesProducts (customerOrderId, productId) VALUES (1,2);
SELECT totalValue FROM CustomerOrder WHERE id=1;
-- Result: totalValue = 450

-- 9. The email on the auditing table can be only that of the user

DELETE FROM User WHERE username='sergio';
INSERT INTO User (username, password, email, insolvent) VALUES ('sergio', 'sergio', 'sergio@sergio.com', 0);
INSERT INTO Auditing (username, email, lastRejectionAmount, lastRejectionDate, lastRejectionTime) VALUES ("sergio", "not@email.com", 0.7, 2021-01-01, 11:00:00);
-- Result: constraint on email violated


insert into FixedPhone values (1);
insert into MobilePhone values (1, 1, 1, 1.0, 1.0);
insert into MobileInternet values (1, 1, 1.0);
insert into FixedInternet values (1, 1, 1.0);

select * from Service;
select * from FixedPhone;
select * from MobilePhone;
select * from MobileInternet;
select * from FixedInternet;

--

insert into MobilePhone values (1, 1, 1, 1.0, 1.0);
insert into MobilePhone values (1, 1, 1, 1.0, 1.0);
select * from Service;
select * from FixedPhone;
select * from MobilePhone;
select * from MobileInternet;
select * from FixedInternet;

--

INSERT INTO User (username, password, email, insolvent) VALUES ('sergio', 'sergio', 'sergio@sergio.com', 0);
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (3, "Stuff", 15.0);
INSERT INTO offersProducts (packageId, productId) VALUES (1,1);
INSERT INTO offersProducts (packageId, productId) VALUES (1,2);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months, rejected, totalValue) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12, 0, 0);
INSERT INTO purchasesProducts (customerOrderId, productId) VALUES (1,1);
INSERT INTO purchasesProducts (customerOrderId, productId) VALUES (1,2);
INSERT INTO purchasesProducts (customerOrderId, productId) VALUES (1,3);
select * from purchasesProducts;

--

INSERT INTO User (username, password, email, insolvent) VALUES ('sergio', 'sergio', 'sergio@sergio.com', 0);
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (3, "Stuff", 15.0);
INSERT INTO offersProducts (packageId, productId) VALUES (1,1);
INSERT INTO offersProducts (packageId, productId) VALUES (1,2);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months, rejected, totalValue) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12, 0, 0);
INSERT INTO purchasesProducts (customerOrderId, productId) VALUES (1,1);
INSERT INTO purchasesProducts (customerOrderId, productId) VALUES (1,2);
UPDATE CustomerOrder SET rejected=1 WHERE id=1;
select * from User;
select * from Auditing;

--

INSERT INTO User (username, password, email, insolvent) VALUES ('sergio', 'sergio', 'sergio@sergio.com', 0);
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (3, "Stuff", 15.0);
INSERT INTO offersProducts (packageId, productId) VALUES (1,1);
INSERT INTO offersProducts (packageId, productId) VALUES (1,2);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months, rejected, totalValue) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12, 0, 0);
INSERT INTO purchasesProducts (customerOrderId, productId) VALUES (1,1);
INSERT INTO purchasesProducts (customerOrderId, productId) VALUES (1,2);
UPDATE CustomerOrder SET rejected=1 WHERE id=1;
UPDATE CustomerOrder SET rejected=2 WHERE id=1;
UPDATE CustomerOrder SET rejected=3 WHERE id=1;
select * from Auditing;

--

insert into MobilePhone values (1, 1, 1, 1.0, 1.0);
insert into MobilePhone values (2, 1, 1, 1.0, 1.0);
DELETE FROM Service WHERE (id=1);
select * from Service;
select * from MobilePhone;


