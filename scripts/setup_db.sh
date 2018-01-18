#!/bin/bash
##
## Build Documentation for the GMOD Chado Schema using SchemaSpy.
##
## Requirements:
##  1. Database user should have the ability to create databases.
##  2. SchemaSpy & PostgreSQL driver jars must be available.

## Parameters
##=================
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
OutDir="/home/ubuntu/workspace/chado-docs"

## Setup the Database
##=================
## In order to use SchemaSpy to generate module-specific documentation, we need
## to make the modules something more concrete then comments ;-p. As such, we
## create a schema per module.
echo "SETUP THE DATABASE"
for i in {1..30}; do echo -n "="; done; echo ""

## Connection string for psql not including the database. 
connectionString=""
echo "Connection String: psql $connectionString"

## Empty and re-create the datbase for a clean slate.
echo ""
echo "Refresh the database..."
for i in {1..30}; do echo -n "-"; done; echo ""
psql $connectionString -c "DROP DATABASE $DB"
psql $connectionString -c "CREATE DATABASE $DB WITH OWNER $DBUSER"

## First load the full schema into a "Chado" schema 
## for use when generating the full documentation.
echo ""
echo "Create the full 'Chado' schema..."
for i in {1..30}; do echo -n "-"; done; echo ""
psql $connectionString --db $DB -c "CREATE SCHEMA chado;"
psql "dbname=$DB options=--search_path=chado" < $ChadoRepo/chado/schemas/1.31/default_schema.sql

## List of chado modules. Order is Very important since this is the order SQL
## will be loaded in and chado is a complex web of dependencies ;-p.
modules=(general db cv contact pub organism sequence companalysis phenotype genetic map phylogeny expression library stock project mage cell_line natural_diversity)

## Create schemas for each module.
echo ""
echo "Create a schema for each chado module..."
for i in {1..30}; do echo -n "-"; done; echo ""
for module in "${modules[@]}"; do
    psql $connectionString --db $DB -c "CREATE SCHEMA $module;"
done

## Populate each schema with the tables for that module.
echo ""
echo "Populate Schemas with the tables for that module..."
for i in {1..30}; do echo -n "-"; done; echo ""

searchPath="public"
for module in "${modules[@]}"; do

    ## Being Verbose
    for i in {1..30}; do echo -n "."; done; echo ""
    echo "MODULE: $module"
    for i in {1..30}; do echo -n "."; done; echo ""
    
    ## Actually working ;-).
    ## We use the search path to ensure that foreign keys can cross schema boundries
    searchPath="$module,$searchPath"
    psql "dbname=$DB options=--search_path=$searchPath" < $ChadoRepo/chado/modules/$module/$module.sql
done