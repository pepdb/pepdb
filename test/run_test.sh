#!/bin/bash
DB_PATH='testdata/test.db'
DB_DUMP='testdata/test.sql'


echo "creating database for testing"
if [ -f $DB_PATH ]
then
  rm $DB_PATH
fi

sqlite3 $DB_PATH < $DB_DUMP


echo "starting functional tests with cucumber"
cucumber integration/features/

echo "starting module test with rspec"
#spec/run_all_specs.sh

