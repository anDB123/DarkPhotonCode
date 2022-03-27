source /cvmfs/sft.cern.ch/lcg/releases/LCG_98python3/matplotlib/3.1.0/x86_64-centos7-gcc8-opt/matplotlib-env.sh
source /cvmfs/sft.cern.ch/lcg/releases/LCG_98python3/numpy/1.18.2/x86_64-centos7-gcc8-opt/numpy-env.sh
source /cvmfs/sft.cern.ch/lcg/releases/LCG_98python3/Python/3.7.6/x86_64-centos7-gcc8-opt/Python-env.sh;
cd /higgs-data1/abrown/
#Variable Declaration

export independent_variable="DARK_PHOTON_MASS"
export independent_variable_label="Mass"
export independent_variable_unit="(GeV)"
export scan_name="${independent_variable}_scan"
export process_name="same_sign_muon_scattering"

START=0
END=10
NUM_OF_RUNS=10

#Plot Parameters
export PLOT_TITLE="$independent_variable_label vs Cross Section"
export x_label="${independent_variable_label} ${independent_variable_unit}"
export y_label="Cross Section (pb)"
#Run Parameters
export ETA=1
export DARK_PHOTON_MASS=5
export PT_CUTOFF=10.0
export ETA_CUTOFF=5.0
export LHC_COM_ENERGY=13.0
export NUMBER_OF_EVENTS=1000
export EVENT_PROCESSES="mu+Smu-S>Smu+Smu-" #S is for space (removed later)
export BIN_NUMBER="100"
export MAIN_DIRECTORY="/higgs-data1/abrown/"

export madgraph_runs_file="madgraph_runs"
export RUNFILE_DIRECTORY="run_files"
export SCRIPTS_DIR="remote_scriptsV2"
export SCAN_DIR="./${process_name}/${scan_name}/"
#LOOP STARTS

param_array=(
DARK_PHOTON_MASS
ETA
PT_CUTOFF
ETA_CUTOFF
LHC_COM_ENERGY
NUMBER_OF_EVENTS
EVENT_PROCESSES
CROSS_SECTION
CROSS_SECTION_UNCERTAINTY
SPECIFIC_FILE_STRUCTURE)



DIFF=`echo "($END-$START)/$NUM_OF_RUNS" | bc -l`
for ((c=0; c<=$NUM_OF_RUNS; c++))
do
	VALUE=$(echo "scale=3; ($START+$DIFF*$c)/1" |bc -l)
	eval "export $independent_variable=$VALUE" #  <-----------------change this depdending on your independent variable
	#Create .lhe files
	
	#file to run create_event_files.sh for many runs with different variables
	echo "Doing run for a ${independent_variable} of ${!independent_variable}";

	export SPECIFIC_FILE_STRUCTURE="./${process_name}/${scan_name}/mass${DARK_PHOTON_MASS}_eta${ETA}/" #used as basis for placing everything
	export RUNFILE_OUTPUT="${SPECIFIC_FILE_STRUCTURE}runfile.run" 
	export MADGRAPH_RUN_OUTPUT="${madgraph_runs_file}/${SPECIFIC_FILE_STRUCTURE}"
	mkdir -p ${SPECIFIC_FILE_STRUCTURE}
	mkdir -p ${MADGRAPH_RUN_OUTPUT}
	#save all file locations to a csv
	echo "${SPECIFIC_FILE_STRUCTURE}" >> ${process_name}/${scan_name}/all_runs.csv

	python3 ${MAIN_DIRECTORY}/${SCRIPTS_DIR}/create_run_file.py
	python3 ${MAIN_DIRECTORY}/MG5_aMC_v3_2_0_leptonfromproton/bin/mg5_aMC ${RUNFILE_OUTPUT};

	cp ${MADGRAPH_RUN_OUTPUT}/crossx.html ${SPECIFIC_FILE_STRUCTURE}
	cp ${MADGRAPH_RUN_OUTPUT}/Events/run_01/unweighted_events.lhe.gz ${SPECIFIC_FILE_STRUCTURE}
	gzip -d -f ${SPECIFIC_FILE_STRUCTURE}unweighted_events.lhe.gz
	#save parameters for each lhe (for plot labels)
	echo "DARK_PHOTON_MASS,$DARK_PHOTON_MASS" > ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "ETA,$ETA" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "PT_CUTOFF,$PT_CUTOFF" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "ETA_CUTOFF,$ETA_CUTOFF" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "LHC_COM_ENERGY,$LHC_COM_ENERGY" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "NUMBER_OF_EVENTS,$NUMBER_OF_EVENTS" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "EVENT_PROCESSES,$EVENT_PROCESSES" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	crossx_location=${SPECIFIC_FILE_STRUCTURE}/crossx.html
	CROSS_SECTION=$(echo $(grep 'results.html' $crossx_location)|grep -oP '(?<=results.html"> ).*?(?= <font face=symbol>&#177)')
	CROSS_SECTION_UNCERTAINTY=$(echo $(grep 'results.html' $crossx_location)|grep -oP '(?<=t face=symbol>&#177;</font> ).*?(?= </a>)')
	echo "CROSS_SECTION,$CROSS_SECTION" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "CROSS_SECTION_UNCERTAINTY,$CROSS_SECTION_UNCERTAINTY" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "SPECIFIC_FILE_STRUCTURE, $SPECIFIC_FILE_STRUCTURE" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	#${MAIN_DIRECTORY}/${SCRIPTS_DIR}/run_herwig.sh
	#save parameters of scan file to csv
		
done
#LOOP ENDS
echo "DARK_PHOTON_MASS,$DARK_PHOTON_MASS" > ${SCAN_DIR}/scan_params.csv
echo "scan_name,$scan_name">>${SCAN_DIR}/scan_params.csv
echo "process_name,$process_name">>${SCAN_DIR}/scan_params.csv
echo "MAIN_DIRECTORY,$MAIN_DIRECTORY">>${SCAN_DIR}/scan_params.csv          
echo "madgraph_runs_file,$madgraph_runs_file">>${SCAN_DIR}/scan_params.csv
echo "RUNFILE_DIRECTORY,$RUNFILE_DIRECTORY">>${SCAN_DIR}/scan_params.csv                 
echo "SCRIPTS_DIR,$SCRIPTS_DIR">>${SCAN_DIR}/scan_params.csv
echo "SCAN_DIR,$SCAN_DIR">>${SCAN_DIR}/scan_params.csv
echo "SPECIFIC_FILE_STRUCTURE,$SPECIFIC_FILE_STRUCTURE">>${SCAN_DIR}/scan_params.csv                    
echo "RUNFILE_OUTPUT,$RUNFILE_OUTPUT">>${SCAN_DIR}/scan_params.csv                 
echo "MADGRAPH_RUN_OUTPUT,$MADGRAPH_RUN_OUTPUT">>${SCAN_DIR}/scan_params.csv                 
echo "independent_variable,$independent_variable">>${SCAN_DIR}/scan_params.csv          
echo "independent_variable_unit,$independent_variable_unit">>${SCAN_DIR}/scan_params.csv              
echo "PLOT_TITLE,$PLOT_TITLE">>${SCAN_DIR}/scan_params.csv                 
echo "x_label,$x_label">>${SCAN_DIR}/scan_params.csv                
echo "y_label,$y_label">>${SCAN_DIR}/scan_params.csv                 
#Run Parameters
echo "ETA,$ETA">>${SCAN_DIR}/scan_params.csv
echo "DARK_PHOTON_MASS,$DARK_PHOTON_MASS">>${SCAN_DIR}/scan_params.csv
echo "PT_CUTOFF,$PT_CUTOFF">>${SCAN_DIR}/scan_params.csv
echo "ETA_CUTOFF,$ETA_CUTOFF">>${SCAN_DIR}/scan_params.csv          
echo "LHC_COM_ENERGY,$LHC_COM_ENERGY">>${SCAN_DIR}/scan_params.csv
echo "NUMBER_OF_EVENTS,$NUMBER_OF_EVENTS">>${SCAN_DIR}/scan_params.csv
echo "EVENT_PROCESSES,$EVENT_PROCESSES">>${SCAN_DIR}/scan_params.csv
echo "BIN_NUMBER,$BIN_NUMBER">>${SCAN_DIR}/scan_params.csv
