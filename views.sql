USE pos;
/* -------------------------------------------------- */
CREATE OR REPLACE VIEW v_Customers AS 
SELECT DISTINCT	  c.lastName, 
	  	  c.firstName, 
		  c.email, 
		  c.address,
		  z.city,
		  z.state,
		  z.zip
FROM		  Customer c 
JOIN	  	  Zip z
ON	  	  c.zip = z.zip
ORDER BY  	  c.lastName, c.firstName, c.birthDate;
/* -------------------------------------------------- */
CREATE OR REPLACE VIEW v_CustomerProducts AS
SELECT DISTINCT	  c.lastName,
	  c.firstName,
	  GROUP_CONCAT(
	  	DISTINCT app 
	  	ORDER BY app SEPARATOR ','
	  	) AS app
FROM	  Customer c
LEFT JOIN `Order` o
ON	  c.id = o.customerID
LEFT JOIN OrderLine ol
ON 	  o.id = ol.orderID
LEFT JOIN Product p
ON	  ol.productID = p.id
GROUP BY  c.id
ORDER BY  c.lastName, c.firstName;
/* -------------------------------------------------- */
CREATE OR REPLACE VIEW v_ProductCustomers AS 
SELECT DISTINCT   p.app, 
		  p.id AS `productID`, 
		  GROUP_CONCAT(
			DISTINCT c.firstName, ' ', c.lastName 
			ORDER BY  c.lastName, c.firstName 
			SEPARATOR ','
			) AS `Customers`
FROM      Customer c
RIGHT JOIN `Order` o
ON        c.id = o.customerID
RIGHT JOIN OrderLine ol
ON        o.id = ol.orderID
RIGHT JOIN Product p
ON        ol.productID = p.id
GROUP BY  p.id
ORDER BY  c.lastName, c.firstName;
/* -------------------------------------------------- */
DROP TABLE IF EXISTS mv_ProductCustomers;

CREATE TABLE mv_ProductCustomers (
	app text,
	productID int NOT NULL,
	customers text,
	PRIMARY KEY (productID)
) ENGINE=INNODB;

INSERT INTO mv_ProductCustomers 
SELECT DISTINCT   p.app,
       	  p.id AS `productID`,
          GROUP_CONCAT(
                DISTINCT c.firstName, ' ', c.lastName
                ORDER BY  c.lastName, c.firstName
                SEPARATOR ','
                ) AS `Customers`
FROM      Customer c
RIGHT JOIN `Order` o
ON        c.id = o.customerID
RIGHT JOIN OrderLine ol
ON        o.id = ol.orderID
RIGHT JOIN Product p
ON        ol.productID = p.id
GROUP BY  p.id
ORDER BY  c.lastName, c.firstName;
