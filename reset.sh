#!/bin/bash

mysql -u root -p'GradeMe!!!' pos < ~/etl.sql
mysql -u root -p'GradeMe!!!' pos < ~/views.sql
mysql -u root -p'GradeMe!!!' pos < ~/index.sql
#mysql -u root -p'GradeMe!!!' pos < ~/transactions.sql
mysql -u root -p'GradeMe!!!' pos < ~/proc.sql
mysql -u root -p'GradeMe!!!' pos < ~/triggers.sql

