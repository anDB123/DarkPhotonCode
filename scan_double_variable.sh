#Code to scan 
export MAIN_DIRECTORY="/home/andrew/abrown/" #CHANGE THIS TO tgething if I forgot!!!!
cd $MAIN_DIRECTORY

source $MAIN_DIRECTORY/$SCRIPTS_DIR/scan_variable_function.sh #<--------------- Most of the operation code is in here

#independent variable stuff
export independent_var1="MIXING_PARAMETER" 
export independent_var1_label="Kinetic/Mixing/Parameter" 
export independent_var1_array=(0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9)

export independent_var2="DARK_PHOTON_MASS" 
export independent_var2_label="Kinetic/Mixing/Parameter" 
export independent_var2_array=(1 2 3 4 5 6 7 8 9 10)

export rivet_analyses_array=("no_cuts" "basic_cuts")
#run fixed parameters (independent variables will be overwritten so keep it here)
export MIXING_PARAMETER=0.5
export DARK_PHOTON_MASS=5
export PT_CUTOFF=10.0
export ETA_CUTOFF=2.5
export LHC_COM_ENERGY=13.0
export NUMBER_OF_EVENTS=1000
export BIN_NUMBER=100

#file naming stuff
export process_name="opposite_sign_muon_scattering" 
export scan_name="${independent_var1}_scan"
export SCAN_DIR="./${process_name}/${scan_name}/"

export SCRIPTS_DIR="/scripts_with_herwigv3/"
export madgraph_runs_file="madgraph_runs"
export RUNFILE_DIRECTORY="run_files"

#source /cvmfs/sft.cern.ch/lcg/releases/LCG_98python3/matplotlib/3.1.0/x86_64-centos7-gcc8-opt/matplotlib-env.sh
#source /cvmfs/sft.cern.ch/lcg/releases/LCG_98python3/numpy/1.18.2/x86_64-centos7-gcc8-opt/numpy-env.sh
#source /cvmfs/sft.cern.ch/lcg/releases/LCG_98python3/Python/3.7.6/x86_64-centos7-gcc8-opt/Python-env.sh;
#source /cvmfs/sft.cern.ch/lcg/releases/LCG_96b/MCGenerators/rivet/2.7.2b/x86_64-centos7-gcc8-opt/rivetenv-genser.sh

#rm -r ${MAIN_DIRECTORY}$process_name/${independent_var1}_scan #will overwrite previous runs if you let it

#will rewrite these within the scan_variable_function
rm ${SCAN_DIR}/all_runs.csv
rm ${SCAN_DIR}/all_containers.csv
rm ${SCAN_DIR}/all_backgrounds.csv
rm ${SCAN_DIR}/all_analyses.csv

scan_variable()
{
#2D scan across 2 variables
#Stage 1: Define File structure
#Stage 2: Running Madgraph 
#Stage 3: Running Herwig
#Stage 4: Running Rivet
#Stage 5: Save Parameters for use in Plots
if [ $background -eq "1" ]
    then
echo "${event_name}" >> ${SCAN_DIR}/all_backgrounds.csv;
fi
#LOOP STARTS
for b in ${independent_var1_array[@]}
do
eval "${independent_var1}=$b" 
echo "Doing $event_name run for a ${independent_var1} of ${!independent_var1}";
for c in ${independent_var2_array[@]}
do
	eval "${independent_var2}=$c" 
	echo "Doing $event_name run for a ${independent_var2} of ${!independent_var2}";

#----------------------------------------------------------------------STAGE 1: File Structure------------------------------------------------------------------------------
    #this is the entire file structure code 
	export CONTAINING_FOLDER="${SCAN_DIR}/m${DARK_PHOTON_MASS}_mx${MIXING_PARAMETER}_ptc${PT_CUTOFF}_etc${ETA_CUTOFF}"
	export SPECIFIC_FILE_STRUCTURE="${CONTAINING_FOLDER}/${event_name}/" #used as basis for placing everything
	export MADGRAPH_RUN_OUTPUT="${madgraph_runs_file}/${SPECIFIC_FILE_STRUCTURE}"

    if [ $background -eq "1" ]
    then
        export CONTAINING_FOLDER="${SCAN_DIR}"
        export SPECIFIC_FILE_STRUCTURE="${CONTAINING_FOLDER}/${event_name}/" 
        export MADGRAPH_RUN_OUTPUT="${madgraph_runs_file}/${SPECIFIC_FILE_STRUCTURE}"
    fi

    mkdir -p ${SPECIFIC_FILE_STRUCTURE}
	mkdir -p ${MADGRAPH_RUN_OUTPUT}
#----------------------------------------------------------------------STAGE 2: Madgraph------------------------------------------------------------------------------
	echo "creating run file"
	python3 ${MAIN_DIRECTORY}/${SCRIPTS_DIR}/create_run_file.py

    #checks for lhe file before running rivet
	if [ -f "$SPECIFIC_FILE_STRUCTURE/unweighted_events.lhe" ]; then
		echo "LHE file already exists, skipping madgraph"
	else 
		echo "running madgraph"
		{
			python3 ${MAIN_DIRECTORY}/MG5_aMC_v3_2_0_leptonfromproton/bin/mg5_aMC "${SPECIFIC_FILE_STRUCTURE}/runfile.run"
		} >/dev/null 2>&1 #makes madgraph silent
		cp ${MADGRAPH_RUN_OUTPUT}/Events/run_01/unweighted_events.lhe.gz ${SPECIFIC_FILE_STRUCTURE}
		gzip -d -f ${SPECIFIC_FILE_STRUCTURE}unweighted_events.lhe.gz
	fi

    #copies feynman diagrams to the directory
	rm -r $SPECIFIC_FILE_STRUCTURE/feynman_diagrams/
	mkdir $SPECIFIC_FILE_STRUCTURE/feynman_diagrams/
	diagram_number=1
	for i in ${MADGRAPH_RUN_OUTPUT}/SubProcesses/*/matrix*.ps; do # Whitespace-safe but not recursive.
		cp -p $i $SPECIFIC_FILE_STRUCTURE/feynman_diagrams/diagrams$diagram_number.ps
		let diagram_number=diagram_number+1
	done
    #gets the cross section from the cross section file (might not need if we can integrate)
    cp ${MADGRAPH_RUN_OUTPUT}/crossx.html ${SPECIFIC_FILE_STRUCTURE}/crossx.html 
	crossx_location=${SPECIFIC_FILE_STRUCTURE}/crossx.html
	CROSS_SECTION=$(echo $(grep 'results.html' $crossx_location)|grep -oP '(?<=results.html"> ).*?(?= <font face=symbol>&#177)')
	CROSS_SECTION_UNCERTAINTY=$(echo $(grep 'results.html' $crossx_location)|grep -oP '(?<=t face=symbol>&#177;</font> ).*?(?= </a>)')

#----------------------------------------------------------------------STAGE 3: Herwig------------------------------------------------------------------------------
	#activate herwig
	source ${MAIN_DIRECTORY}herwig/bin/activate
	lhe_name=unweighted_events # name of lhe file
	filename="${SPECIFIC_FILE_STRUCTURE}${lhe_name}" 

    #checks if hepmc file has already been made
	if [ -f "$SPECIFIC_FILE_STRUCTURE/unweighted_events.hepmc" ]; then
		echo "hepmc file already exists, skipping herwig"
	else 
		echo "running herwig"
		echo "Activating Herwig"
		let N=${NUMBER_OF_EVENTS}-10
		cp LHE_LepByLep.in ${SPECIFIC_FILE_STRUCTURE}LHE_LepByLep.in
		sed -i "s|set LesHouchesReader:FileName file.lhe|set LesHouchesReader:FileName ${filename}.lhe|" ${SPECIFIC_FILE_STRUCTURE}LHE_LepByLep.in
		Herwig read ${SPECIFIC_FILE_STRUCTURE}LHE_LepByLep.in
		Herwig run LHE.run -N ${N}
		mv LHE.hepmc ${filename}.hepmc
		#cleans up directory
		rm LHE-EvtGen.log
		rm LHE.log
		rm LHE.out
		rm LHE.run
	fi
#----------------------------------------------------------------------STAGE 4: Rivet------------------------------------------------------------------------------
    for rivet_analysis in ${rivet_analyses_array[@]} #loops through all analyses
    do
        analysis_output_name="${lhe_name}_${rivet_analysis}"
        #checks for csv before running rivet
        if [ -f "$SPECIFIC_FILE_STRUCTURE/${analysis_output_name}.csv" ]; then
            echo "csv file already exists, skipping rivet"
        else 
            echo "running rivet for $rivet_analysis"
            export RIVET_ANALYSIS_PATH="${MAIN_DIRECTORY}rivet/"
            rivet -q --analysis=$rivet_analysis -o ${filename}.yoda ${filename}.hepmc &> ${SPECIFIC_FILE_STRUCTURE}log.${analysis_output_name}.out
            grep data ${SPECIFIC_FILE_STRUCTURE}log.${analysis_output_name}.out > ${SPECIFIC_FILE_STRUCTURE}${analysis_output_name}.csv
            sed -i "s/Rivet.Analysis.${rivet_analysis}: INFO  data: //" ${SPECIFIC_FILE_STRUCTURE}/${analysis_output_name}.csv #<---------------work out how to remove lines with letters (rivet debug outputs )
            sed -i "s/Rivet.Analysis.${rivet_analysis}: INFO  data: //" ${SPECIFIC_FILE_STRUCTURE}/${analysis_output_name}.csv

            mkdir -p "${SPECIFIC_FILE_STRUCTURE}/${rivet_analysis}_histograms"
            mkdir -p ${CONTAINING_FOLDER}/${rivet_analysis}_comparison_histograms
        fi
    done
	deactivate #deactivates HERWIG 
#----------------------------------------------------------------------STAGE 5: Store Params------------------------------------------------------------------------------
	#save parameters of scan file to csv
	rm ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "Dark Photon Mass,GeV,$DARK_PHOTON_MASS" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "$\epsilon \cos \\theta _w$,,$MIXING_PARAMETER" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "Transverse Momentum Cutoff,GeV,$PT_CUTOFF" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "Eta Cutoff,,$ETA_CUTOFF" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "LHC COM Energy,TeV,$LHC_COM_ENERGY" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "Number of Events,,$NUMBER_OF_EVENTS" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "Cross Section,pb,$CROSS_SECTION +/- $CROSS_SECTION_UNCERTAINTY" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	echo "Event Processes,,$printable_event_process_array" >> ${SPECIFIC_FILE_STRUCTURE}run_params.csv
	
	#save all file locations to a csv
    if grep -q "${SPECIFIC_FILE_STRUCTURE}" "${SCAN_DIR}/all_runs.csv"; then echo "";
    else
	    echo "${SPECIFIC_FILE_STRUCTURE}" >> ${SCAN_DIR}/all_runs.csv
    fi
	if grep -q "${CONTAINING_FOLDER}" "${SCAN_DIR}/all_containers.csv"; then echo "";
	else
		echo "${CONTAINING_FOLDER}" >> ${SCAN_DIR}/all_containers.csv;
	fi

    for rivet_analysis in ${rivet_analyses_array[@]}
    do
        if grep -q "${rivet_analysis}" "${SCAN_DIR}/all_analyses.csv"; then echo "";
        else
            echo "${rivet_analysis}" >> ${SCAN_DIR}/all_analyses.csv;
        fi
    done
done
done
#LOOP ENDS
}

#--------------------------------------------------------------------event generation---------------------------------------------------------------------
export event_name="BSM"
export background="0"
export event_process1="mu+ mu+ > mu+ mu+ /h2 " #for BSM only use /aSz , for SM only use /zp
export event_process2="mu- mu- > mu- mu- /h2" #/h2 is to remove doubly charged higgs
export printable_event_process_array="${event_name}NEWL$event_process1 NEWL$event_process2"
event_process1=$(echo "$event_process1" | tr ' ' 'S') #replaces spaces with S
event_process2=$(echo "$event_process2" | tr ' ' 'S')
export event_process_array="${event_process1}AND${event_process2}" #use AND between events
scan_variable

export event_name="SM"
export background="1"
echo "doing $event_name events"
export event_process1="mu+ mu+ > mu+ mu+ /zp h2" #for BSM only use /aSz , for SM only use /zp
export event_process2="mu- mu- > mu- mu- /zp h2"
export printable_event_process_array="${event_name}NEWL${event_process1}NEWL${event_process2}"
event_process1=$(echo "$event_process1" | tr ' ' 'S')
event_process2=$(echo "$event_process2" | tr ' ' 'S')
export event_process_array="${event_process1}AND${event_process2}"#use AND between events
scan_variable

#export event_name="double_lepton_weak_production"
export background="1"
#echo "doing $event_name events"
#export event_process1="p p > w+ w+ > mu+ mu+ vl vl j j QCD=0 /h h2 zp g" #for BSM only use /aSz , for SM only use /zp
#export printable_event_process_array="${event_name}NEWL$event_process1"
#event_process1=$(echo "$event_process1" | tr ' ' 'S')
#export event_process_array="$event_process1" #use ! between events
#scan_variable


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
independent_var1
independent_var1_label
independent_var1_unit
PLOT_TITLE
x_label
y_label
MIXING_PARAMETER
DARK_PHOTON_MASS
PT_CUTOFF
ETA_CUTOFF
LHC_COM_ENERGY
NUMBER_OF_EVENTS
event_process_array
BIN_NUMBER)
for i in ${scan_params_array[@]}
do
echo "$i,${!i}" >> ${SCAN_DIR}/scan_params.csv
done
