#!/bin/bash

mysql -u dgomillion -p'GradeMe!!!' pos < ~/etl.sql
mysql -u dgomillion -p'GradeMe!!!' pos < ~/views.sql
mysql -u dgomillion -p'GradeMe!!!' pos < ~/index.sql
#mysql -u dgomillion -p'GradeMe!!!' pos < ~/transactions.sql
mysql -u dgomillion -p'GradeMe!!!' pos < ~/proc.sql
mysql -u dgomillion -p'GradeMe!!!' pos < ~/triggers.sql
