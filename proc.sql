DELIMITER //

ALTER TABLE pos.OrderLine
ADD COLUMN IF NOT EXISTS OrderLine.unitPrice DECIMAL(4,2),
ADD COLUMN IF NOT EXISTS OrderLine.totalPrice DECIMAL(5,2);
ALTER TABLE pos.`Order`
ADD COLUMN IF NOT EXISTS pos.`Order`.totalPrice DECIMAL(5,2);

CREATE OR REPLACE VIEW v_Totals AS
	SELECT pos.OrderLine.orderID, 
	SUM(pos.OrderLine.totalPrice) AS 'Total'
	FROM pos.OrderLine
	GROUP BY pos.OrderLine.orderID;

CREATE OR REPLACE PROCEDURE spCalculateTotals()
BEGIN
	UPDATE pos.OrderLine
	LEFT JOIN pos.Product ON 
		pos.OrderLine.productID = pos.Product.id
	SET pos.OrderLine.unitPrice = pos.Product.price
	WHERE pos.Product.id IN (
	SELECT pos.OrderLine.productID
	FROM pos.OrderLine
	WHERE pos.OrderLine.unitPrice IS NULL);

	UPDATE pos.OrderLine
	LEFT JOIN pos.Product ON 
		pos.OrderLine.productID = pos.Product.id
	SET pos.OrderLine.totalPrice = 
	pos.OrderLine.unitPrice * pos.OrderLine.quantity
	WHERE pos.Product.id IN (
	SELECT pos.OrderLine.productID 
	FROM pos.OrderLine
	WHERE pos.OrderLine.totalPrice IS NULL);

	UPDATE pos.`Order` 
	SET totalPrice = (
	SELECT Total 
	FROM v_Totals 
	WHERE orderID = id);
END //

CREATE OR REPLACE PROCEDURE spCalculateTotalsLoop()
BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE oid, pid INT;
	DECLARE pri DECIMAL(5,2);
	DECLARE olcur CURSOR FOR 
		SELECT OrderLine.orderID, OrderLine.productID, 
			Product.price 
		FROM OrderLine 
		LEFT JOIN Product 
		ON pos.OrderLine.productID = pos.Product.id;	
	DECLARE ocur CURSOR FOR SELECT id FROM pos.`Order`;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN olcur;
	ol_loop: LOOP
	FETCH olcur INTO oid, pid, pri;
	IF done THEN LEAVE ol_loop; END IF;
	UPDATE OrderLine
	SET unitPrice = pri
	WHERE orderID = oid AND productID = pid 
	AND unitPrice IS NULL;
	UPDATE OrderLine
	SET totalPrice = pri * quantity
	WHERE orderID = oid AND productID = pid 
	AND totalPrice IS NULL;
	END LOOP ol_loop;
	CLOSE olcur;
	SET done = FALSE;

	OPEN ocur;
	o_loop: LOOP
	FETCH ocur INTO oid;
	IF done THEN LEAVE o_loop; END IF;
	UPDATE pos.`Order`
	SET totalPrice = (
		SELECT SUM(OrderLine.totalPrice) 
		FROM OrderLine 
		WHERE OrderLine.orderID = oid
		GROUP BY OrderLine.orderID)
	WHERE `Order`.id = oid;
	END LOOP o_loop;
	CLOSE ocur;
	SET done = FALSE;
END //

CREATE OR REPLACE PROCEDURE spFillMVProductCustomers()
BEGIN
	DELETE FROM mv_ProductCustomers;

	INSERT INTO mv_ProductCustomers 
	SELECT DISTINCT p.app,
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
END //

DELIMITER ;
