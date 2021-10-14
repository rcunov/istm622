use pos;
START TRANSACTION;
	SET autocommit=0;
	INSERT INTO Customer VALUES (99999,'Remington','Cunov','rcunov@tamu.edu','42 Wallaby Way','1997-05-03','75310');
	INSERT INTO `Order`(id,customerID) VALUES (99999,99999);
	INSERT INTO OrderLine VALUES (99999,17,1),(99999,27,1),(99999,57,1); 
COMMIT;

use pos;
START TRANSACTION;
	SET autocommit=0;
	INSERT INTO Customer VALUES (99998,'David','Gomillion','dgomillion@tamu.edu','123 Home Drive','1970-01-01','76205'); 
	INSERT INTO `Order`(id,customerID) VALUES (99998,99997);
	INSERT INTO OrderLine VALUES (99998,18,2),(99998,28,2),(99998,58,2);
COMMIT;

