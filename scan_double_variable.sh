source /cvmfs/sft.cern.ch/lcg/releases/LCG_98python3/matplotlib/3.1.0/x86_64-centos7-gcc8-opt/matplotlib-env.sh
source /cvmfs/sft.cern.ch/lcg/releases/LCG_98python3/numpy/1.18.2/x86_64-centos7-gcc8-opt/numpy-env.sh
source /cvmfs/sft.cern.ch/lcg/releases/LCG_98python3/Python/3.7.6/x86_64-centos7-gcc8-opt/Python-env.sh;
cd /higgs-data1/abrown/
#Variable Declaration

export independent_variable1="$independent1_var"
export independent_variable1_label="$independent1_label"
export independent_variable1_unit="$independent1_unit"

export independent_variable2="$independent2_var"
export independent_variable2_label="$independent2_label"
export independent_variable2_unit="$independent2_unit"

export scan_name="${independent_variable1}against${independent_variable2}_scan"
export process_name="$process_name"
#for BSM only use /aSz
#for SM only use /zp
export EVENT_PROCESSES="$event_process1" #S is for space (removed later)
export EXTRA_EVENT_PROCESSES="$event_process2" #leave this blank for other processes

SCAN_ARRAY1="$scan_array1"
SCAN_ARRAY2="$scan_array2"

#Plot Parameters
export PLOT_TITLE="$title_prefix$independent_variable1_label/vs/$independent_variable2_label/vs/Cross/Section"
export x_label="${independent_variable1_label}/${independent_variable1_unit}"
export y_label="${independent_variable2_label}/${independent_variable2_unit}"
#Run Parameters
export ETA=0.8
export DARK_PHOTON_MASS=5
export PT_CUTOFF=20.0
export ETA_CUTOFF=2.5
export LHC_COM_ENERGY=13.0
export NUMBER_OF_EVENTS=1000
export BIN_NUMBER="100"
export MAIN_DIRECTORY="/higgs-data1/abrown/"

export madgraph_runs_file="./madgraph_runs"
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
for b in ${SCAN_ARRAY1[@]}
do
	eval "${independent_variable1}=$b"
	#Create .lhe files
	
	#file to run create_event_files.sh for many runs with different variables
	echo "Doing run for a ${independent_variable1} of ${!independent_variable1}";
for c in ${SCAN_ARRAY2[@]}
do
	eval "${independent_variable2}=$c"
	#Create .lhe files
	
	#file to run create_event_files.sh for many runs with different variables
	echo "Doing run for a ${independent_variable2} of ${!independent_variable2}";

	export SPECIFIC_FILE_STRUCTURE="./${process_name}/${scan_name}/m${DARK_PHOTON_MASS}_e${ETA}_ptc${PT_CUTOFF}_etc${ETA_CUTOFF}/" #used as basis for placing everything
	export RUNFILE_OUTPUT="${SPECIFIC_FILE_STRUCTURE}runfile.run" 
	export MADGRAPH_RUN_OUTPUT="${madgraph_runs_file}/${SPECIFIC_FILE_STRUCTURE}"
	mkdir -p ${SPECIFIC_FILE_STRUCTURE}
	mkdir -p ${MADGRAPH_RUN_OUTPUT}
	#save all file locations to a csv
	echo "${SPECIFIC_FILE_STRUCTURE}" >> ${process_name}/${scan_name}/all_runs.csv

	python3 ${MAIN_DIRECTORY}/${SCRIPTS_DIR}/create_run_file.py
	{
		python3 ${MAIN_DIRECTORY}/MG5_aMC_v3_2_0_leptonfromproton/bin/mg5_aMC ${RUNFILE_OUTPUT}
	} >/dev/null 2>&1 #makes madgraph silent

	cp ${MADGRAPH_RUN_OUTPUT}/crossx.html ${SPECIFIC_FILE_STRUCTURE}
	cp ${MADGRAPH_RUN_OUTPUT}/Events/run_01/unweighted_events.lhe.gz ${SPECIFIC_FILE_STRUCTURE}
	gzip -d -f ${SPECIFIC_FILE_STRUCTURE}unweighted_events.lhe.gz
	
	crossx_location=${SPECIFIC_FILE_STRUCTURE}/crossx.html
	CROSS_SECTION=$(echo $(grep 'results.html' $crossx_location)|grep -oP '(?<=results.html"> ).*?(?= <font face=symbol>&#177)')
	CROSS_SECTION_UNCERTAINTY=$(echo $(grep 'results.html' $crossx_location)|grep -oP '(?<=t face=symbol>&#177;</font> ).*?(?= </a>)')

	#save parameters for each lhe (for plot labels)
	for i in ${param_array[@]}
	do
	echo "$i,${!i}" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	done
	#${MAIN_DIRECTORY}/${SCRIPTS_DIR}/run_herwig.sh
	#save parameters of scan file to csv
	#${MAIN_DIRECTORY}/${SCRIPTS_DIR}/run_herwig.sh
done
done
#LOOP ENDS
scan_params_array=(
scan_name
process_name
MAIN_DIRECTORY
madgraph_runs_file
RUNFILE_DIRECTORY
SCRIPTS_DIR
SCAN_DIR
SPECIFIC_FILE_STRUCTURE
RUNFILE_OUTPUT
MADGRAPH_RUN_OUTPUT
independent_variable1
independent_variable1_label
independent_variable1_unit
independent_variable2
independent_variable2_label
independent_variable2_unit
PLOT_TITLE
x_label
y_label
z_label
ETA
DARK_PHOTON_MASS
PT_CUTOFF
ETA_CUTOFF
LHC_COM_ENERGY
NUMBER_OF_EVENTS
EVENT_PROCESSES
BIN_NUMBER)
for i in ${scan_params_array[@]}
do
echo "$i,${!i}" >> ${SCAN_DIR}/scan_params.csv
done
