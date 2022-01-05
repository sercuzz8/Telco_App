/*CREATE TABLE averageproductsold (
	package int PRIMARY KEY,
    avgProductSold int
);

INSERT INTO averageproductsold
SELECT package, avg(productsSold) as avgProductSold
FROM (	SELECT c.id as orderId, c.package, count(*) as productsSold
		FROM CUSTOMERORDER c JOIN choosesproducts ON  customerorder = c.id
		GROUP BY c.id, c.package) AS productsSoldPerOrder 
GROUP BY package;   */     
	
CREATE TABLE bestsellers (
	product int PRIMARY KEY,
    numOfSales int
);

INSERT INTO bestsellers
SELECT p.product, COUNT(*) AS NUM
FROM SERVICEACTIVATIONSCHEDULE AS s, purchasesproducts as p
WHERE s.package = p.package AND s.customer=p.customer
GROUP BY p.product
ORDER BY NUM DESC;

-- bestsellers triggers
-- new product in optional product
CREATE TRIGGER add_product
AFTER INSERT ON OPTIONALPRODUCT
FOR EACH ROW
INSERT INTO bestsellers VALUES (new.id, 0);
-- delete product from optional product
CREATE TRIGGER remove_product
AFTER DELETE ON OPTIONALPRODUCT
FOR EACH ROW
DELETE FROM bestsellers WHERE product=old.id;
-- update product in bestsellers
delimiter //
CREATE TRIGGER update_product
AFTER INSERT ON purchasesproducts
FOR EACH ROW
BEGIN
	SET @old_sales = 0;
        
	SELECT IFNULL(numOfSales,0)
	FROM bestsellers
	WHERE product = new.product
	INTO @old_sales;
	
	SET @new_sales = @old_sales + 1;
	UPDATE bestsellers SET numOfSales = @new_sales WHERE product = new.product;
END//
delimiter ;
    
CREATE TABLE insolventcustomers (
	insolvent int PRIMARY KEY,
    rejectedOrder int,
    alertDate date
);

INSERT INTO insolventcustomers
SELECT c.customer, c.id, a.lastrejectiondate
FROM CUSTOMERORDER c LEFT JOIN AUDITING a ON c.customer=a.customer
WHERE rejected>0
ORDER BY c.customer ASC;

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
    
    INSERT INTO insolventcustomers VALUES 
    (new.customer,@suspended_order,new.lastrejectiondate);
END//
delimiter ;

CREATE TRIGGER remove_insolvent
AFTER DELETE ON AUDITING
FOR EACH ROW
DELETE FROM insolventcustomers WHERE customer=old.customer AND alertDate = old.lastrejectiondate;
 

CREATE TABLE packagevalidityperiod (
	package int PRIMARY KEY,
    months int,
    purchases int
);

INSERT INTO packagevalidityperiod
SELECT package, months, COUNT(*)
FROM CUSTOMERORDER	
GROUP BY package, months
ORDER BY package, TIMESTAMPDIFF(MONTH,activationdate,deactivationdate);
-- ho modificato la query di creazione di questa view poichè ritengo il validity period come un'entità scelta nell'ordine 
-- che prescinde da activation e deactivatio
-- inoltre possiamo riferci direttamente a customer order poichè l'ordine è creato
-- soltanto dopo che l'opeazione di pagamneto va a buon fine
delimiter //
CREATE TRIGGER insert_new_package_purchease
AFTER INSERT ON CUSTOMERORDER
FOR EACH ROW
BEGIN
	SET @old_purchases = 0;
    SELECT purchases
    FROM packagevalidityperiod
    WHERE package = new.package AND months = new.months
    INTO @old_purchases;
    
    SET @new_purchases = @old_purchases + 1;
    UPDATE packagevalidityperiod SET purchases = @new_purchases WHERE package = new.package AND months = new.months;
END//
delimiter ;
-- new service package
CREATE TRIGGER new_package
AFTER INSERT ON SERVICEPACKAGE
FOR EACH ROW 
INSERT INTO packagevalidityperiod VALUES (new.id,12,0);
INSERT INTO packagevalidityperiod VALUES (new.id,24,0);
INSERT INTO packagevalidityperiod VALUES (new.id,36,0);
-- delete service package
CREATE TRIGGER delete_package
AFTER DELETE ON SERVICEPACKAGE
FOR EACH ROW
DELETE FROM packagevalidityperiod WHERE package = old.id;
-- delete validity period
CREATE TRIGGER delete_validity
AFTER DELETE ON VALIDITYPERIOD
FOR EACH ROW 
DELETE FROM packagevalidityperiod WHERE package = old.package AND months = old.months;

CREATE TABLE purchasespackage (
	package int PRIMARY KEY,
    purchases int
);
-- same thing as before, we can directly use customerorder
INSERT INTO purchasespackage
SELECT package, COUNT(*)
FROM CUSTOMERORDER 
GROUP BY package
ORDER BY package ASC;

delimiter //
CREATE TRIGGER update_purchases
AFTER INSERT ON CUSTOMERORDER
FOR EACH ROW
BEGIN
	SET @old_purchases = 0;
    SELECT purchases
    FROM purchasespackage
    WHERE package = new.package 
    INTO @old_purchases;
    
    SET @new_purchases = @old_purchases + 1;
    UPDATE purchasespackage SET purchases = @new_purchases WHERE package = new.package;
END//
delimiter ;
-- delete service package
CREATE TRIGGER delete_pack
AFTER DELETE ON SERVICEPACKAGE
FOR EACH ROW
DELETE FROM purchasespackage WHERE package = old.id;
-- new service package
CREATE TRIGGER new_pack
AFTER INSERT ON SERVICEPACKAGE
FOR EACH ROW 
INSERT INTO purchasespackage VALUES (new.id,0);

CREATE TABLE validitysaleproduct (
	package int PRIMARY KEY,
    withProducts int,
    withoutProducts int
);

INSERT INTO validitysaleproduct
SELECT s.package, SUM(c.totalValue), SUM(v.monthsnumber*v.monthlyfee)
FROM SERVICEACTIVATIONSCHEDULE AS s, CUSTOMERORDER AS c, VALIDITYPERIOD as v
WHERE s.package = c.package AND s.customer=c.customer AND c.package=v.package AND c.months=v.monthsnumber
GROUP BY s.package
ORDER BY s.package ASC;

delimiter //
CREATE TRIGGER new_sale
AFTER INSERT ON CUSTOMERORDER
FOR EACH ROW
BEGIN
	SET @old_withProd = 0;
    SET @old_withoutProd = 0;
    SET @vp_value = 0;
    SELECT withProducts, withoutProducts
    FROM validitysaleproduct
    WHERE package = new.package
    INTO @old_withProd,@old_withoutProd;
    
    SELECT monthsnumber*monthlyfee
    FROM VALIDITYPERIOD
    WHERE package = new.package AND monthsnumber = new.months
    INTO @vp_value;
    
    SET @new_withProd = @old_withProd + new.totalValue;
    SET @new_withoutProd = @old_withoutProd + @vp_value;
    
    UPDATE validitysaleproduct SET withProducts = @new_withProd, withoutProducts=@new_withoutProd
    WHERE package = new.package;
END//
delimiter ;


