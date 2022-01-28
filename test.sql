INSERT INTO SERVICE(id, servicetype) VALUES (1, 'fixed_phone');
INSERT INTO SERVICE(id, servicetype, minnumber, smsnumber, minfee, smsfee) VALUES (2, 'mobile_phone', 100, 50, 0.5, 0.2);
INSERT INTO SERVICE(id, servicetype, gbnumber, gbfee) VALUES (3, 'fixed_internet', 50, 0.7);
INSERT INTO SERVICE(id, servicetype, gbnumber, gbfee) VALUES (4, 'mobile_internet', 150, 0.2);

INSERT INTO EMPLOYEE (code, password) VALUES ('1234', '1234');
INSERT INTO EMPLOYEE (code, password) VALUES ('5678', '5678');

INSERT INTO SERVICEPACKAGE (id, name) VALUES (1,"Basic");
INSERT INTO SERVICEPACKAGE (id, name) VALUES (2,"Deluxe");

INSERT INTO includesservices(package, service) VALUES (1, 1);
INSERT INTO includesservices(package, service) VALUES (1, 3);
INSERT INTO includesservices(package, service) VALUES (2, 1);
INSERT INTO includesservices(package, service) VALUES (2, 2);
INSERT INTO includesservices(package, service) VALUES (2, 3);
INSERT INTO includesservices(package, service) VALUES (2, 4);

INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 12, 12.5);
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 24, 10.5);
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 36, 9.5);

INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (2, 12, 30);
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (2, 24, 27);
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (2, 36, 25);

INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (1, "Radio Addition", 10.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (3, "Stuff", 15.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (4, "Metfixplus", 30.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (5, "Cable change", 7.0);

INSERT INTO offersproducts (package, product) VALUES (1,1);
INSERT INTO offersproducts (package, product) VALUES (1,2);
INSERT INTO offersproducts (package, product) VALUES (2,1);
INSERT INTO offersproducts (package, product) VALUES (2,2);
INSERT INTO offersproducts (package, product) VALUES (2,3);
INSERT INTO offersproducts (package, product) VALUES (2,4);
INSERT INTO offersproducts (package, product) VALUES (2,5);

-- Testing part:

INSERT INTO CUSTOMER (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO CUSTOMER (username, password, email) VALUES ('ale', 'ale', 'ale@ale.com');
INSERT INTO CUSTOMER (username, password, email) VALUES ('paolo', 'paolo', 'paolo@paolo.com');
INSERT INTO CUSTOMER (username, password, email) VALUES ('donald', 'donald', 'donald@d.com');
INSERT INTO CUSTOMER (username, password, email) VALUES ('fabio', 'fabio', 'fabio@fa.it');
INSERT INTO CUSTOMER (username, password, email) VALUES ('marco', 'fabio', 'marco@mar.it');

INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12);
INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (2, '2021-02-01', '13:00', '2021-04-01' ,"ale", 1, 24);
INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (3, '2021-02-01', '13:00', '2021-04-01' ,"paolo", 1, 12);
INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (4, '2021-02-01', '13:00', '2021-04-01' ,"donald", 2, 36);
INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (5, '2021-01-01', '13:00', '2021-03-01' ,"fabio", 1, 12);
INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (6, '2021-01-01', '13:00', '2021-03-01' ,"marco", 2, 24);
INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (7, '2021-05-01', '13:00', '2021-08-01' ,"marco", 1, 12);

INSERT INTO choosesproducts (customerorder, product) VALUES (1,1);
INSERT INTO choosesproducts (customerorder, product) VALUES (1,2);
INSERT INTO choosesproducts (customerorder, product) VALUES (2,1);
INSERT INTO choosesproducts (customerorder, product) VALUES (3,1);
INSERT INTO choosesproducts (customerorder, product) VALUES (4,1);
INSERT INTO choosesproducts (customerorder, product) VALUES (4,4);
INSERT INTO choosesproducts (customerorder, product) VALUES (5,1);
INSERT INTO choosesproducts (customerorder, product) VALUES (7,2);


UPDATE CUSTOMERORDER SET valid=1 WHERE id=1;
UPDATE CUSTOMERORDER SET valid=1 WHERE id=2;
UPDATE CUSTOMERORDER SET valid=1 WHERE id=3;
UPDATE CUSTOMERORDER SET valid=1 WHERE id=4;

UPDATE CUSTOMERORDER SET rejected=1 WHERE id=5;
UPDATE CUSTOMERORDER SET rejected=2 WHERE id=5;
UPDATE CUSTOMERORDER SET rejected=3 WHERE id=5;

UPDATE CUSTOMERORDER SET rejected=1 WHERE id=6;

-- UPDATE CUSTOMERORDER SET valid=1 WHERE id=6;

SELECT * FROM CUSTOMER;

SELECT * FROM CUSTOMERORDER;

SELECT * FROM SERVICEACTIVATIONSCHEDULE;

SELECT * FROM PURCHASEPERPACKAGE;

SELECT * FROM PURCHASEPERVALIDITY;

SELECT * FROM SALEPERPACKAGE;

SELECT s.package, s.customer, COUNT(*) FROM SERVICEACTIVATIONSCHEDULE s 
	JOIN purchasesproducts p ON s.package=p.package AND s.customer=p.customer 
    GROUP BY s.package, s.customer
    ORDER BY s.package; 

SELECT * FROM AVERAGEPRODUCTSOLD;

SELECT * FROM INSOLVENTCUSTOMER;

SELECT * FROM BESTSELLER;

-- -------------------------------------------------------------------
/*
-- 1. Avoid duplicate mail
DELETE FROM CUSTOMER WHERE username='sergio';
DELETE FROM CUSTOMER WHERE username='ale';
INSERT INTO CUSTOMER (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO CUSTOMER (username, password, email) VALUES ('ale', 'ale', 'sergio@sergio.com');
-- Result: Ale not written because of duplicate email = OK

-- 3. No two different services (e.g. Mobile and Fixed) with the same ID

INSERT INTO FixedPhone VALUES (1);
INSERT INTO MobilePhone VALUES (1, 1, 1, 1.0, 1.0);
INSERT INTO MobileInternet VALUES (1, 1, 1.0);
INSERT INTO FixedInternet VALUES (1, 1, 1.0);

SELECT * FROM SERVICE;
SELECT * FROM FixedPhone;
SELECT * FROM MobilePhone;
SELECT * FROM MobileInternet;
SELECT * FROM FixedInternet;

-- Result: There are now Services 1,2,3,4 with FixedPhone=1, MobilePhone=2, MobileInternet=3, FixedInternet=4

-- 4. No validity period without any package
DELETE FROM SERVICEPACKAGE WHERE id=1 AND monthsnumber=12;
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 12, 12.5);
INSERT INTO SERVICEPACKAGE (id, name) VALUES (1,"Basic");
-- Result: Not operated because no parent = OK
DELETE FROM SERVICEPACKAGE WHERE id=1;
INSERT INTO SERVICEPACKAGE (id, name) VALUES (1,"Basic");
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 12, 12.5);
-- Result: OK

-- 5. Only 12,24,36 Months in VALIDITYPERIOD
DELETE FROM SERVICEPACKAGE WHERE id=1;
INSERT INTO SERVICEPACKAGE (id, name) VALUES (1,"Basic");
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 11, 12.5);
-- Result: Not operated because constraint on number of months is violated
DELETE FROM SERVICEPACKAGE WHERE id=1;
INSERT INTO SERVICEPACKAGE (id, name) VALUES (1,"Basic");
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 12, 12.5);
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 24, 12.5);
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 36, 12.5);
-- RESULT: OK

-- 6.  A package may be associated with one or more optional products
DELETE FROM SERVICEPACKAGE WHERE id=1;
DELETE FROM VALIDITYPERIOD WHERE package=1 AND monthsnumber=12;
DELETE FROM OPTIONALPRODUCT WHERE id=1;
DELETE FROM OPTIONALPRODUCT WHERE id=2;
DELETE FROM offersproducts WHERE package=1;
INSERT INTO SERVICEPACKAGE (id, name) VALUES (1,"Basic");
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 12, 12.5);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (2, "TV Addition", 15.0);
INSERT INTO offersproducts (package, product) VALUES (1,1);
INSERT INTO offersproducts (package, product) VALUES (1,2);
SELECT name FROM OPTIONALPRODUCT WHERE id in ( SELECT product FROM offersproducts WHERE package=1);
-- RESULT: both products in one service package = OK

-- 7. A customer can buy only optional products offered in the package

-- 8. Total Value of A customer order

DELETE FROM CUSTOMER WHERE username='sergio';
DELETE FROM SERVICEPACKAGE WHERE id=1;
DELETE FROM VALIDITYPERIOD WHERE package=1 AND monthsnumber=12;
DELETE FROM OPTIONALPRODUCT WHERE id=1;
DELETE FROM OPTIONALPRODUCT WHERE id=2;
DELETE FROM offersproducts WHERE package=1;
DELETE FROM choosesproducts WHERE customerOrder=1;
DELETE FROM CUSTOMERORDER WHERE id=1;
INSERT INTO CUSTOMER (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO SERVICEPACKAGE (id, name) VALUES (1,"Basic");
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 12, 12.5);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (2, "TV Addition", 15.0);
INSERT INTO offersproducts (package, product) VALUES (1,1);
INSERT INTO offersproducts (package, product) VALUES (1,2);
INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12);
INSERT INTO choosesproducts (customerOrder, product) VALUES (1,1);
INSERT INTO choosesproducts (customerOrder, product) VALUES (1,2);
SELECT totalValue FROM CUSTOMERORDER WHERE id=1;
-- Result: totalValue = 450

-- 9. The email on the auditing table can be only that of the customer

DELETE FROM CUSTOMER WHERE username='sergio';
INSERT INTO CUSTOMER (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO AUDITING (username, email, lastrejectionamount, lastrejectiondate, lastrejectiontime) VALUES ("sergio", "not@email.com", 0.7, 2021-01-01, 11:00:00);
-- Result: constraint on email violated

-- 10. One customer can't buy a product not offered with the package

INSERT INTO CUSTOMER (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO SERVICEPACKAGE (id, name) VALUES (1,"Basic");
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 12, 12.5);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (3, "Stuff", 15.0);
INSERT INTO offersproducts (package, product) VALUES (1,1);
INSERT INTO offersproducts (package, product) VALUES (1,2);
INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12);
INSERT INTO choosesproducts (customerOrder, product) VALUES (1,1);
INSERT INTO choosesproducts (customerOrder, product) VALUES (1,2);
INSERT INTO choosesproducts (customerOrder, product) VALUES (1,3);
SELECT * FROM choosesproducts;

-- Result: The INSERTion of product 3 is blocked

-- 11. A customer is rejected its payment

INSERT INTO CUSTOMER (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO SERVICEPACKAGE (id, name) VALUES (1,"Basic");
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 12, 12.5);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (3, "Stuff", 15.0);
INSERT INTO offersproducts (package, product) VALUES (1,1);
INSERT INTO offersproducts (package, product) VALUES (1,2);
INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12);
INSERT INTO choosesproducts (customerOrder, product) VALUES (1,1);
INSERT INTO choosesproducts (customerOrder, product) VALUES (1,2);
UPDATE CUSTOMERORDER SET rejected=1 WHERE id=1;
SELECT * FROM CUSTOMER;
SELECT * FROM AUDITING;

-- Result: customer marked as insolvent

-- 12. A customer fails three payments

INSERT INTO CUSTOMER (username, password, email) VALUES ('sergio', 'sergio', 'sergio@sergio.com');
INSERT INTO SERVICEPACKAGE (id, name) VALUES (1,"Basic");
INSERT INTO VALIDITYPERIOD (package, monthsnumber, monthlyfee) VALUES (1, 12, 12.5);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (1, "SMS Addition", 10.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (2, "TV Addition", 15.0);
INSERT INTO OPTIONALPRODUCT (id, name, monthlyfee) VALUES (3, "Stuff", 15.0);
INSERT INTO offersproducts (package, product) VALUES (1,1);
INSERT INTO offersproducts (package, product) VALUES (1,2);
INSERT INTO CUSTOMERORDER (id, date, hour, start, customer, package , months) VALUES (1, '2021-01-01', '13:00', '2021-03-01' ,"sergio", 1, 12);
INSERT INTO choosesproducts (customerOrder, product) VALUES (1,1);
INSERT INTO choosesproducts (customerOrder, product) VALUES (1,2);
UPDATE CUSTOMERORDER SET rejected=1 WHERE id=1;
UPDATE CUSTOMERORDER SET rejected=2 WHERE id=1;
UPDATE CUSTOMERORDER SET rejected=3 WHERE id=1;
SELECT * FROM AUDITING;

-- Result: An auditing entry is created

-- 13. Deletion of SERVICE

INSERT INTO MobilePhone VALUES (1, 1, 1, 1.0, 1.0);
INSERT INTO MobilePhone VALUES (2, 1, 1, 1.0, 1.0);
DELETE FROM SERVICE WHERE (id=1);
SELECT * FROM SERVICE;
SELECT * FROM MobilePhone;

-- Result: operated*/
