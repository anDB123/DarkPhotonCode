#requires input of filename (no .lhe suffix) and number of events. Also need to have Will output a hepmc file with same name as input filename
#activates HERWIG, takes an lhe file plus the number of events in the lhe file then outputs a hepmc file

source /higgs-data1/abrown/herwig/bin/activate
save_folder=/higgs-data1/abrown/lhefiles/hepmc_files
lhe_name=unweighted_events
filename="${SPECIFIC_FILE_STRUCTURE}${lhe_name}"
N=${NUMBER_OF_EVENTS}
sed -i "s|set LesHouchesReader:FileName file.lhe|set LesHouchesReader:FileName ${filename}.lhe|" LHE_LepByLep.in
Herwig read LHE_LepByLep.in
Herwig run LHE.run -N ${N}
sed -i "s|set LesHouchesReader:FileName ${filename}.lhe|set LesHouchesReader:FileName file.lhe|" LHE_LepByLep.in
mv LHE.hepmc ${filename}.hepmc

#cleans up directory
rm LHE-EvtGen.log
rm LHE.log
rm LHE.out
rm LHE.run

#deactivates HERWIG 
deactivate
source /cvmfs/sft.cern.ch/lcg/releases/LCG_96b/MCGenerators/rivet/2.7.2b/x86_64-centos7-gcc8-opt/rivetenv-genser.sh
#rivet analysis part outputs a csv
export RIVET_ANALYSIS_PATH="/higgs-data1/abrown/rivet/"
rivet --analysis=hepmc2csv -o ${filename}.yoda ${filename}.hepmc &> ${SPECIFIC_FILE_STRUCTURE}log.${lhe_name}.out
grep data ${SPECIFIC_FILE_STRUCTURE}log.${lhe_name}.out > ${filename}.csv
sed -i 's/Rivet.Analysis.hepmc2csv: INFO  data: //' ${filename}.csv

#moves the hepmc, csv, yoda and log file to different directories (may not be important, just depends what you want out in the end and where it gets put).
#mv ${filename}.hepmc $save_folder
#mv ${filename}.csv /higgs-data1/tgething/lhefiles/csv_files
#mv ${filename}.yoda /higgs-data1/tgething/lhefiles/yoda_files
#mv log.${filename}.out /higgs-data1/tgething/lhefiles/log_files

#removal of crap from the csv (crap=the annoying final line that gets appended
#sed -i 's|Histograms written to /higgs-data1/tgething/lhefiles/lhe_files/${filename}.yoda||' ${filename}.csv