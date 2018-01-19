#!/bin/bash
##
## Build Documentation for the GMOD Chado Schema using SchemaSpy.
##
## Requirements:
##  1. Database user should have the ability to create databases.
##  2. SchemaSpy & PostgreSQL driver jars must be available.

#######################################
## Parameters
#######################################

##  - Database connection details (should already exist).
DB="chado"
DBUSER="chado"
DBPASS="chado"
##  - Absolute path to jars.
SchemeSpyJar="/home/ubuntu/workspace/schemaspy-6.0.0-rc2.jar"
PsqlDriverJar="/home/ubuntu/workspace/postgresql-42.1.4.jar"
##  - Absolute path to cloned Chado repository.
ChadoRepo="/home/ubuntu/workspace/Chado"
##  - Absolute path to generate the documantation at.
outDir="/home/ubuntu/workspace/Chado/docs"

## List of chado modules. Order is Very important since this is the order SQL
## will be loaded in and chado is a complex web of dependencies ;-p.
modules=(general db cv contact pub organism sequence companalysis phenotype genetic map phylogeny expression library stock project mage cell_line natural_diversity)

#######################################
## Setup the Database
#######################################

## SchemaSpy generates documentation based on a given database/schema combination. 
## We would like the typical full table listing of all chado tables, since it is 
## convient when looking up a specific table. However, with 209 tables this can be 
## very overwhelming for new users. As such we would also like module-specific 
## documentation. The difficulty comes in that currently "modules" in chado are 
## simply comments in the SQL which don't even make it into the database. Thus we 
## are arbitrarily making each module a schema in order to generate the 
## documentation as we would like.

echo ""
echo ""
echo "SETUP THE DATABASE"
for i in {1..30}; do echo -n "="; done; echo ""

## Defined a connection string for psql not including the database. 
## Currently this is empty as it wasn't needed on my development machine.
## However, I have included it in case it's needed for the Docker instance that 
## will be built.
## Use `psql [connection string] --db [database name]`
connectionString=""
echo "Connection String: psql $connectionString"

## Empty and re-create the database for a clean slate.
echo ""
echo "Refresh the database..."
for i in {1..30}; do echo -n "-"; done; echo ""
psql $connectionString -c "DROP DATABASE $DB"
psql $connectionString -c "CREATE DATABASE $DB WITH OWNER $DBUSER"

## First we want to load Chado normally, for use in generating the main documentation
## listing the full 209 tables.
## @todo figure out why this is producing errors.
echo ""
echo "Create the full 'Chado' schema..."
for i in {1..30}; do echo -n "-"; done; echo ""
psql $connectionString --db $DB -c "CREATE SCHEMA chado;"
echo "Currently the SQL is loaded by module below. This should be fixed in the future to use the default SQL for the current version."
# psql "dbname=$DB options=--search_path=chado" < $ChadoRepo/chado/schemas/1.31/default_schema.sql

## Create a Schema per module and load the SQL for it 
## using the module-specific SQL files in the Chado Repository.
echo ""
echo "Populate Schemas with the tables for that module..."
for i in {1..30}; do echo -n "-"; done; echo ""

searchPath="public"
for module in "${modules[@]}"; do

    ## Being Verbose
    for i in {1..30}; do echo -n "."; done; echo ""
    echo "MODULE: $module"
    for i in {1..30}; do echo -n "."; done; echo ""
    
    ## Create a Schema for the module.
    psql $connectionString --db $DB -c "CREATE SCHEMA $module;"
    
    ## We use the search path to ensure that foreign keys can cross schema boundries.
    ## This should be a reverse order list of the modules added already. The
    ## module you are currently loading SQL for MUST BE FIRST in order to ensure
    ## the tables are created in the correct schema.
    searchPath="$module,$searchPath"
    # @debug echo "Search Path: $searchPath"
    
    ## Load into the full chado schema
    ## @todo remove in favour of full load above
    # @debug echo psql "dbname=$DB options=--search_path=chado"
    psql "dbname=$DB options=--search_path=chado" < $ChadoRepo/chado/modules/$module/$module.sql
    
    ## Load into the module-specific schema
    # @debug echo psql "dbname=$DB options=--search_path=$searchPath"
    psql "dbname=$DB options=--search_path=$searchPath" < $ChadoRepo/chado/modules/$module/$module.sql

done

#######################################
## Generate the Documentation
#######################################

echo ""
echo ""
echo "GENERATING THE DOCUMENTATION"
for i in {1..30}; do echo -n "="; done; echo ""

## Create the output directory if it doesn't already exist.
mkdir -p $outDir

## Transfer in the main SQL, images, etc.
cp ./src/* $outDir/

##=====================================
## Generate the Main Docs for all tables.
##=====================================
echo ""
for i in {1..30}; do echo -n "-"; done; echo ""
echo "Generate the main index with the full table listing..."
for i in {1..30}; do echo -n "-"; done; echo ""

java -jar $SchemeSpyJar -t pgsql -dp $PsqlDriverJar -db $DB -u $DBUSER -p $DBPASS -hostOptionalPort localhost -template ./main_template -o $outDir -s chado
    
##=====================================
## Generate Docs for each module.
##=====================================

echo ""
for i in {1..30}; do echo -n "-"; done; echo ""
echo "Generate the per-module documentation..."
for i in {1..30}; do echo -n "-"; done; echo ""

## For each module.
for module in "${modules[@]}"; do

    ## Being Verbose
    for i in {1..30}; do echo -n "."; done; echo ""
    echo "MODULE: $module"
    for i in {1..30}; do echo -n "."; done; echo ""
    
    ## Make a directory for the module-specific docs
    mkdir -p "$outDir/$module"
    
    ## Generate the module-specific docs
    java -jar $SchemeSpyJar -t pgsql -dp $PsqlDriverJar -db $DB -u $DBUSER -p $DBPASS -hostOptionalPort localhost -template ./module_template -o $outDir/$module -s $module
done