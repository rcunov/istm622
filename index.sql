CREATE OR REPLACE INDEX index_app on pos.Product(app);
CREATE OR REPLACE FULLTEXT INDEX index_PCust on pos.mv_ProductCustomers(customers);

