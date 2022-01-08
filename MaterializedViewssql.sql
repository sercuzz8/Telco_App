CREATE TABLE averageproductsold (
	package int PRIMARY KEY,
    avgProductSold int
);

INSERT INTO averageproductsold
SELECT package, avg(productsSold) as avgProductSold
FROM (	SELECT c.id as orderId, c.package, count(*) as productsSold
		FROM CUSTOMERORDER c JOIN choosesproducts ON  customerorder = c.id
		GROUP BY c.id, c.package) AS productsSoldPerOrder 
GROUP BY package; 

-- the trigger activates when a new order is created, it counts all the products included in the order and compute the new average for the service package selected in the order 
delimiter //
CREATE TRIGGER newOrder
AFTER INSERT ON CUSTOMERORDER
FOR EACH ROW
BEGIN
	SET @productsPerOrder = 0;
    SET @oldAvg = 0;
    
    SELECT count(*)
    FROM choosesproducts
    WHERE customerorder = new.id
    GROUP BY customerorder
    INTO @productsPerOrder;
    
    SELECT avgProductSold
    FROM averageProductSold
    WHERE package = new.package
    INTO @oldAvg;
    
    SET @newAvg = (@oldAvg + @productsPerOrder) / 2;
    
    UPDATE averageproductsold
    SET avgProductSold = @newAvg
    WHERE package = new.package;
END //
delimiter;

INSERT INTO BESTSELLER
SELECT p.product, COUNT(*) AS NUM
FROM SERVICEACTIVATIONSCHEDULE AS s, purchasesproducts as p
WHERE s.package = p.package AND s.customer=p.customer
GROUP BY p.product
ORDER BY NUM DESC;

INSERT INTO INSOLVENTCUSTOMER
SELECT c.customer, c.id, a.lastrejectiondate
FROM CUSTOMERORDER c LEFT JOIN AUDITING a ON c.customer=a.customer
WHERE rejected>0
ORDER BY c.customer ASC;
 
INSERT INTO PURCHASEPERVALIDITY
SELECT package, months, COUNT(*)
FROM CUSTOMERORDER	
GROUP BY package, months
ORDER BY package, TIMESTAMPDIFF(MONTH,activationdate,deactivationdate);
-- ho modificato la query di creazione di questa view poichè ritengo il validity period come un'entità scelta nell'ordine 
-- che prescinde da activation e deactivatio
-- inoltre possiamo riferci direttamente a customer order poichè l'ordine è creato
-- soltanto dopo che l'opeazione di pagamneto va a buon fine


-- same thing as before, we can directly use customerorder
INSERT INTO PURCHASEPERPACKAGE
SELECT package, COUNT(*)
FROM CUSTOMERORDER 
GROUP BY package
ORDER BY package ASC;

INSERT INTO SALEPERPACKAGE
SELECT s.package, SUM(c.totalValue), SUM(v.monthsnumber*v.monthlyfee)
FROM SERVICEACTIVATIONSCHEDULE AS s, CUSTOMERORDER AS c, VALIDITYPERIOD as v
WHERE s.package = c.package AND s.customer=c.customer AND c.package=v.package AND c.months=v.monthsnumber
GROUP BY s.package
ORDER BY s.package ASC;



