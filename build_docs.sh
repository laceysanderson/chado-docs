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
outDir="/home/ubuntu/workspace/chado-docs"
##  - Absolute path to directory containing templates.
##     NOTE: This must be within a full checkout of SchemaSpy :-(
templateDir="/home/ubuntu/workspace/schemaspy/src/main/resources/layout"


## Setup the Database
## ./scripts/setup_db.sh

## Generate Docs for each module.
##=================
modules=(general db cv contact pub organism sequence companalysis phenotype genetic map phylogeny expression library stock project mage cell_line natural_diversity)

## Create the output directory.
mkdir $outDir

## For each module.
for module in "${modules[@]}"; do

    ## Make a directory for the module-specific docs
    mkdir "$outDir/$module"
    
    ## Generate the module-specific docs
    java -jar $SchemeSpyJar -t pgsql -dp $PsqlDriverJar -db $DB -u $DBUSER -p $DBPASS -hostOptionalPort localhost -o $outDir/$module -s $module
done