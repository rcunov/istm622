DROP DATABASE IF EXISTS pos;
CREATE DATABASE pos;

CREATE TABLE pos.Zip (
        zip INT NOT NULL,
        city TEXT,
        `state` TEXT,
        PRIMARY KEY (zip)
) ENGINE=INNODB;

CREATE TABLE pos.Customer (
        id INT NOT NULL,
        firstName TEXT,
        lastName TEXT,
        email TEXT,
        address TEXT,
        birthDate DATE,
        zip INT NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (zip) REFERENCES Zip (zip)
) ENGINE=INNODB;

CREATE TABLE pos.Order (
        id INT NOT NULL,
        customerID INT NOT NULL,
        PRIMARY KEY (id),
        FOREIGN KEY (customerID) REFERENCES Customer (id)
) ENGINE=INNODB;

CREATE TABLE pos.Product (
        id INT NOT NULL,
        app TEXT,
        price DECIMAL(4,2),
        PRIMARY KEY (id)
) ENGINE=INNODB;

LOAD DATA LOCAL INFILE './Customer.csv'
INTO TABLE pos.Zip
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@id,@firstName,@lastName,@email,@address,@co6,@co7,@co8,@birthDate)
SET zip = @co8, city = @co6, state= @co7;

LOAD DATA LOCAL INFILE './Customer.csv'
INTO TABLE pos.Customer
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(@co1,@co2,@co3,@co4,@co5,@co6,@co7,@co8,@co9)
SET id = @co1, firstName = @co2, lastName = @co3, email = @co4, address = @co5, birthDate = STR_TO_DATE(@co9, '%m/%d/%Y'), zip = @co8;

LOAD DATA LOCAL INFILE './Product.csv'
INTO TABLE pos.Product
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(id,app,@co3)
SET price = REPLACE(@co3, '$', '');

LOAD DATA LOCAL INFILE './Order.csv'
INTO TABLE pos.Order
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE pos.Import (
	orderId INT,
	productId INT
) ENGINE=INNODB;

LOAD DATA LOCAL INFILE './OrderLine.csv'
INTO TABLE pos.Import
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

CREATE TABLE pos.OrderLine (
        orderID INT,
        productID INT,
        quantity INT,
        PRIMARY KEY (orderID, productID),
        FOREIGN KEY (orderID) REFERENCES `Order` (id),
        FOREIGN KEY (productID) REFERENCES Product (id)
) ENGINE=INNODB;

INSERT INTO pos.OrderLine
SELECT orderID, productID,
COUNT(*) AS quantity
FROM pos.Import
GROUP BY orderID, productID;

DROP TABLE pos.Import;
