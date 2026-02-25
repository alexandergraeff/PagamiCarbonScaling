Alex Graeff <alexander.graeff@usda.gov>
February 2026

_______________________________________________________________________________

Project

Pagami Creek Fire - Scaling Carbon Emissions from Upland Forests

_______________________________________________________________________________

Purpose

Summarize biomass data, grouped by forest type, to estimate carbon losses from 
the Pagami Creek Fire in upland plots. 

_______________________________________________________________________________

Environment Reproduction

This project uses [`renv`](https://rstudio.github.io/renv/) to ensure a 
reproducible R package environment.
Follow these steps to get started:

1. Install R and RStudio

2. Set up the environment
	- Open the .Rproj file (Carbon Scaling.Rproj)
	- Find, open, and run scripts/environmentSetup.R"

This will:

Install renv if it’s not already installed
Restore all packages from renv.lock

Once the environment is ready, you can run all scripts.

_______________________________________________________________________________

Git

- This is a local git repository
- Though no changes are anticipated by anyone other than the author, any 
  changes to the directory should be added to the Git history.

_______________________________________________________________________________

Notes

Biomass calculations in the raw data were made by Sue Lietz. Metadata is 
included in the file, but not all supporting data for biomass calculations are 
supplied in this directory. For more information about biomass calculations, 
contact the author.

_______________________________________________________________________________

Contents

Root Directory: Carbon Scaling
	- Carbon Scaling.Rproj
		- Open this to run scripts
	- cols.csv
		- Contains definitions for columns of tables in /output

1.	├───data
2. 	│   ├───processed
3. 	│   ├───raw
4. 	│   └───reference
5.	├───output
6. 	│   ├───figures
7. 	│   └───tables
8.	├───renv
9.	└───scripts


2. Output biomass data file which was used for downstream analyses.
3. The raw file with biomass data.
4. Reference data for joining:
	- forestTypes.csv - FIA forest type designations for each plot - see
	  notes below in this document for forest type determination.
	- severityCrn_forestType_plot.csv - additional plot reference data
	  including other forest type designations and burn severity
5. Analysis outputs
8. Environment snapshot data, controlled by the renv package
9. Contains scripts for forest type determination, environment setup, and 
   analysis.
	- analysis.Rmd - summarize and visualize data, generates outputs
	- environmentCapture.R - used to replicate R environment, should be
	  ran before running forestTypes.R or analysis.Rmd
	- environmentSetup.R - captures R environment, not needed outside of 
	  development
	- forestTypes.R - determines forest types for plots using Forest 
	  Inventory and Analysis (FIA) rules with biomass as a proxy

_______________________________________________________________________________
	
Generation of Forest Types

- FIA rules were applied to determine forest types, using biomass as a proxy in 
  place of basal area.

- Softwood biomass was summed and divided by the plot total biomass to 
  determine the softwood proportion. 
	- Softwoods >= 50 percent of biomass --> softwood forest type 
	- Softwoods < 50 percent of biomass --> hardwood forest type

- Forest types were generally represented by the species in the group with the 
  highest biomass proportion. However, some exceptions apply. 

	“mixed hardwood‑pine forest types (401–409) apply when the 
	pine/redcedar component is 25–49% of stocking.”
		--> if pine 25–49%, then Other pine / hardwood

	"WHITE/RED/JACK PINE GROUP: In these pure pine forest types, stocking 
	of the pine component needs to be at least 50 percent."

	For (red maple I divided lowland vs. upland (708 vs 809) using a 
	lowland associate biomass threshold: if (FRNI + THOC + PIMA) / 
	Total ≥ 20%, assign 708 (lowland), else 809 (upland).

 - See scripts/forestTypes.R

_______________________________________________________________________________
_______________________________________________________________________________


	
