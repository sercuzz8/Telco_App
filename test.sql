-- Testing part:

INSERT INTO User (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO User (username, password, email) VALUES ('ale', 'ale', 'ale@ale.com');
INSERT INTO User (username, password, email) VALUES ('paolo', 'paolo', 'paolo@paolo.com');
INSERT INTO User (username, password, email) VALUES ('donald', 'donald', 'donald@d.com');
INSERT INTO User (username, password, email) VALUES ('fabio', 'fabio', 'fabio@fa.it');
INSERT INTO User (username, password, email) VALUES ('marco', 'fabio', 'marco@mar.it');


INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ServicePackage (id, name) VALUES (2,"Deluxe");

INSERT INTO FixedPhone VALUES (1);
INSERT INTO MobilePhone VALUES (1, 100, 50, 0.5, 0.2);
INSERT INTO MobileInternet VALUES (1, 50, 0.7);
INSERT INTO FixedInternet VALUES (1, 150, 0.2);

INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 24, 10.5);
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 36, 9.5);

INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (2, 12, 30);
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (2, 24, 27);
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (2, 36, 25);

INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (1, "Radio Addition", 10.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (3, "Stuff", 15.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (4, "Metfixplus", 30.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (5, "Cable change", 7.0);

INSERT INTO offersProducts (packageId, productId) VALUES (1,1);
INSERT INTO offersProducts (packageId, productId) VALUES (1,2);
INSERT INTO offersProducts (packageId, productId) VALUES (2,1);
INSERT INTO offersProducts (packageId, productId) VALUES (2,2);
INSERT INTO offersProducts (packageId, productId) VALUES (2,3);
INSERT INTO offersProducts (packageId, productId) VALUES (2,4);
INSERT INTO offersProducts (packageId, productId) VALUES (2,5);

INSERT INTO CustomerOrder (id, date, hour, start, user, package , months) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months) VALUES (2, '2021-02-01', '13:00', '2021-04-01' ,"ale", 1, 24);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months) VALUES (3, '2021-02-01', '13:00', '2021-04-01' ,"paolo", 1, 12);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months) VALUES (4, '2021-02-01', '13:00', '2021-04-01' ,"donald", 2, 36);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months) VALUES (5, '2021-01-01', '13:00', '2021-03-01' ,"fabio", 1, 12);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months) VALUES (6, '2021-01-01', '13:00', '2021-03-01' ,"marco", 2, 24);

INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,1);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,2);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (2,1);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (3,1);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (4,1);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (4,4);


UPDATE CustomerOrder SET valid=1 WHERE id=1;
UPDATE CustomerOrder SET valid=1 WHERE id=2;
UPDATE CustomerOrder SET valid=1 WHERE id=3;
UPDATE CustomerOrder SET valid=1 WHERE id=4;

UPDATE CustomerOrder SET rejected=1 WHERE id=5;
UPDATE CustomerOrder SET rejected=2 WHERE id=5;
UPDATE CustomerOrder SET rejected=3 WHERE id=5;

UPDATE CustomerOrder SET rejected=1 WHERE id=6;

SELECT * FROM ServiceActivationSchedule;

SELECT * FROM purchasesProducts;

SELECT * FROM PackageValidityPeriod;

SELECT * FROM ValiditySaleProduct;

SELECT * FROM AVGProductsSold;

SELECT * FROM InsolventUsers;

SELECT * FROM BestSellers;

---------------------------------------------------------------------
/*
-- 1. Avoid duplicate mail
DELETE FROM User WHERE username='sergio';
DELETE FROM User WHERE username='ale';
INSERT INTO User (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO User (username, password, email) VALUES ('ale', 'ale', 'sergio@sergio.com');
-- Result: Ale not written because of duplicate email = OK

-- 3. No two different services (e.g. Mobile and Fixed) with the same ID

INSERT INTO FixedPhone VALUES (1);
INSERT INTO MobilePhone VALUES (1, 1, 1, 1.0, 1.0);
INSERT INTO MobileInternet VALUES (1, 1, 1.0);
INSERT INTO FixedInternet VALUES (1, 1, 1.0);

SELECT * FROM Service;
SELECT * FROM FixedPhone;
SELECT * FROM MobilePhone;
SELECT * FROM MobileInternet;
SELECT * FROM FixedInternet;

-- Result: There are now Services 1,2,3,4 with FixedPhone=1, MobilePhone=2, MobileInternet=3, FixedInternet=4

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
SELECT name FROM OptionalProduct WHERE id in ( SELECT productId FROM offersProducts WHERE packageId=1);
-- RESULT: both products in one service package = OK

-- 7. A customer can buy only optional products offered in the package

-- 8. Total Value of A customer order

DELETE FROM User WHERE username='sergio';
DELETE FROM ServicePackage WHERE id=1;
DELETE FROM ValidityPeriod WHERE packageId=1 AND monthsNumber=12;
DELETE FROM OptionalProduct WHERE id=1;
DELETE FROM OptionalProduct WHERE id=2;
DELETE FROM offersProducts WHERE packageId=1;
DELETE FROM choosesProducts WHERE customerOrderId=1;
DELETE FROM CustomerOrder WHERE id=1;
INSERT INTO User (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (2, "TV Addition", 15.0);
INSERT INTO offersProducts (packageId, productId) VALUES (1,1);
INSERT INTO offersProducts (packageId, productId) VALUES (1,2);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,1);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,2);
SELECT totalValue FROM CustomerOrder WHERE id=1;
-- Result: totalValue = 450

-- 9. The email on the auditing table can be only that of the user

DELETE FROM User WHERE username='sergio';
INSERT INTO User (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO Auditing (username, email, lastRejectionAmount, lastRejectionDate, lastRejectionTime) VALUES ("sergio", "not@email.com", 0.7, 2021-01-01, 11:00:00);
-- Result: constraint on email violated

-- 10. One user can't buy a product not offered with the package

INSERT INTO User (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (3, "Stuff", 15.0);
INSERT INTO offersProducts (packageId, productId) VALUES (1,1);
INSERT INTO offersProducts (packageId, productId) VALUES (1,2);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,1);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,2);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,3);
SELECT * FROM choosesProducts;

-- Result: The INSERTion of product 3 is blocked

-- 11. A user is rejected its payment

INSERT INTO User (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (3, "Stuff", 15.0);
INSERT INTO offersProducts (packageId, productId) VALUES (1,1);
INSERT INTO offersProducts (packageId, productId) VALUES (1,2);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,1);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,2);
UPDATE CustomerOrder SET rejected=1 WHERE id=1;
SELECT * FROM User;
SELECT * FROM Auditing;

-- Result: user marked as insolvent

-- 12. A user fails three payments

INSERT INTO User (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO ServicePackage (id, name) VALUES (1,"Basic");
INSERT INTO ValidityPeriod (packageId, monthsNumber, monthlyFee) VALUES (1, 12, 12.5);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OptionalProduct (id, name, monthlyFee) VALUES (3, "Stuff", 15.0);
INSERT INTO offersProducts (packageId, productId) VALUES (1,1);
INSERT INTO offersProducts (packageId, productId) VALUES (1,2);
INSERT INTO CustomerOrder (id, date, hour, start, user, package , months) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,1);
INSERT INTO choosesProducts (customerOrderId, productId) VALUES (1,2);
UPDATE CustomerOrder SET rejected=1 WHERE id=1;
UPDATE CustomerOrder SET rejected=2 WHERE id=1;
UPDATE CustomerOrder SET rejected=3 WHERE id=1;
SELECT * FROM Auditing;

-- Result: An auditing entry is created

-- 13. Deletion of Service

INSERT INTO MobilePhone VALUES (1, 1, 1, 1.0, 1.0);
INSERT INTO MobilePhone VALUES (2, 1, 1, 1.0, 1.0);
DELETE FROM Service WHERE (id=1);
SELECT * FROM Service;
SELECT * FROM MobilePhone;

-- Result: operated*/


/*SET @productList = (SELECT COUNT(productId) FROM choosesProducts WHERE customerOrderId=new.id);
			BEGIN
  			WHILE @productList > 0 DO
			SET @tmp = (SELECT productId FROM choosesProducts WHERE customerOrderId=new.id ORDER BY productId ASC LIMIT @productList-1,@productList);
    		-- SET @tmp = @productList;
			INSERT INTO purchasesProducts (package, user, product) VALUES (new.package, new.user, @tmp);
    		SET @productList = @productList - 1;
  			END WHILE;
			END;*/