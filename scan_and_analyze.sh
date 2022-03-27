export scripts_dir="scripts_with_herwig"
export independent_var="PT_CUTOFF" 
export independent_label="Transverse/Momentum/Cutoff" 
export independent_unit="(GeV)" 

export process_name="SM_opposite_sign_muon_scattering5" 
export event_process1="mu+Smu+S>Smu+Smu+S/zp" 
export event_process2="mu-Smu-S>Smu-Smu-S/zp"
export scan_array=(5)
export title_prefix="SM/only/"

./$scripts_dir/copy_scripts_to_server.sh

sshpass -p "f31t03y89t[k ;jpeg k;wlm" ssh -t abrown@higgs.hep.manchester.ac.uk "
echo 'connection started';
export independent_var='$independent_var';
export independent_label='$independent_label';
export independent_unit='$independent_unit';
export process_name='$process_name';
export event_process1='$event_process1';
export event_process2='$event_process2';
export scan_array='${scan_array[@]}';
export title_prefix='$title_prefix';
cd /higgs-data1/abrown;
rm -r /higgs-data1/abrown/$process_name/${independent_var}_scan
./$scripts_dir/scan_variableV3.sh;
"
rm -r ./$process_name/${independent_var}_scan
./$scripts_dir/download_lhe_dir.sh
./$scripts_dir/plot_variable.sh