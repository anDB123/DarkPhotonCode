# DarkPhotonCode
Code for investigating Hadron-Hadron induced dark photon events. 
Created during an MPhys project supervised by Darren Price and Michaela Queitsch-Maitland.

For more information on dark photons, wikipedia has a good summary. https://en.wikipedia.org/wiki/Dark_photon

Idea of the code:
The code produces a 2 dimensional scan of dark photon parameters.
The 2 scanned parameters are Dark photon mass and Kinetic Mixing parameter.

the main file is scan_double.sh

How the code works:

You start by defiing many parameters which are based on either the LHC or the ATLAS detector.
ETA- Kinetic mixing parameter
DARK_PHOTON_MASS - Mass of Dark photon in MeV
PT_CUTOFF- The minimum Transverse Momentum
ETA_CUTOFF - Maximum Pseudorapidity
LHC_COM_ENERGY - Centre of Mass Energy of LHC (TeV)
NUMBER_OF_EVENTS - Number of events generated (higher takes longer)
BIN_NUMBER - Number of bins for the Histogram)
MAIN_DIRECTORY - Directory for files to be saved to

The code will then loop through the SCAN ARRAYS and running the code for each one.

LOOP STARTS
1. Sets up directories
2. Creates run file for the specific mass and mixing
3. Runs Madgraph with the run file
4. copies relevant files from the madgraph output (.lhe file)
5. run herwig on madgraph output file (.hepmc file)
6. run rivet on the .hepmc file to get (.csv file)
LOOP ENDS

Run python analysis on the .csv files
