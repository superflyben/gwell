## GWELL Automation Functions
This repository contains four functions that comprise a Matlab GUI for a geothermal well-bore modeling program - GWELL - developed at Lawrence Berkeley National Lab (LBNL) using the Fortran programming language. Put all 4 files in your working directory along with the gwell executable, and run the program by typing 'gwell' at a Matlab command prompt. Note the GWELL source code is written in Fortran and must be obtained directly from LBNL and compiled with a compiler appropriate for your system. The Matlab code in this repository operates as pre- and post-processor for the compiled executable.

### Function List
1. gwell.m - executive function which routes program flow through other 3 functions. Input file iteration handled here.
2. gwell_input.m - Handles user input for well-bore geometry, number and depth of feed zones and other physical parameters
3. gwell_run.m - Generates GWELL input file, and executes the program with newly created input file.
4. gwell_plot.m - Reads output files and visualizes the data.

### Video Demo
A brief [video demonstration](gwell_demo.mov "Video Demo") of GWELL usage.
