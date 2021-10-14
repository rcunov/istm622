use pos;
call spCalculateTotals;
call spFillMVProductCustomers;

CREATE OR REPLACE TABLE pos.HistoricalPricing
    (id INT NOT NULL AUTO_INCREMENT,
    productID INT NOT NULL,
    changeTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    oldPrice DECIMAL (5,2),
    newPrice DECIMAL (5,2),
    PRIMARY KEY (id),
    FOREIGN KEY (productID) REFERENCES pos.Product(id) ON UPDATE RESTRICT
    ) ENGINE=INNODB;

DELIMITER //

-- orderline before insert
CREATE OR REPLACE 
    TRIGGER tr_InsertOL BEFORE INSERT
    ON pos.OrderLine FOR EACH ROW
BEGIN
    SET NEW.unitPrice = (SELECT price FROM Product WHERE id=NEW.productID);
    SET NEW.totalPrice = (NEW.quantity * new.unitPrice);
END //

-- orderline before update
CREATE OR REPLACE
    TRIGGER tr_AddOL BEFORE UPDATE
    ON pos.OrderLine FOR EACH ROW
BEGIN
    SET NEW.unitPrice = (SELECT price FROM Product WHERE id=NEW.productID);
    SET NEW.totalPrice = (NEW.quantity * new.unitPrice);
END //

-- orderline after insert
CREATE OR REPLACE
    TRIGGER tr_InsertO AFTER INSERT
    ON pos.OrderLine FOR EACH ROW
BEGIN
    UPDATE `Order`
    SET `Order`.totalPrice = (SELECT Total FROM v_Totals WHERE orderID=id);
    call spFillMVProductCustomers;
END //

-- order after update
CREATE OR REPLACE
    TRIGGER tr_UpdateO AFTER UPDATE
    ON pos.OrderLine FOR EACH ROW
BEGIN
    UPDATE `Order`
    SET `Order`.totalPrice = (SELECT Total FROM v_Totals WHERE orderID=id);
    call spFillMVProductCustomers;
END //

-- order after delete
CREATE OR REPLACE
    TRIGGER tr_DeleteO AFTER DELETE
    ON pos.OrderLine FOR EACH ROW
BEGIN
    UPDATE `Order`
    SET `Order`.totalPrice = (SELECT Total FROM v_Totals WHERE orderID=id);
    call spFillMVProductCustomers;
END //

-- oldprice after update
CREATE OR REPLACE
    TRIGGER tr_UpdateHistoricalPricing AFTER UPDATE
    ON pos.Product FOR EACH ROW
BEGIN
    IF OLD.price != NEW.price THEN
    INSERT INTO HistoricalPricing (productID,oldPrice,newPrice)
    VALUES (NEW.id,OLD.price,NEW.price);
    
    UPDATE OrderLine
    LEFT JOIN Product ON OrderLine.productID = Product.id
    SET OrderLine.unitPrice = Product.price
    WHERE new.id = OrderLine.productID;
    
    END IF;
END //

DELIMITER ;
