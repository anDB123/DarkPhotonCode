cd /home/andrew/abrown/
#Give the scan location
scan_name=$scan_name
scan_variable=$independent_var
export SCAN_LOCATION="/home/andrew/new_install/${process_name}/${scan_variable}_scan/"
SCAN_CSV="$SCAN_LOCATION/scan_params.csv"
FILES_CSV="$SCAN_LOCATION/all_runs.csv"
export BIN_NUMBER=100
#Loop through scan parameters
independent_variable_array=()
cross_section_array=()
cross_section_error_array=()
histogram_count=0
histograms_to_compare_array=(2 5 7)
comparison_histograms=()
while IFS=, read -r param_name param_value;
do
	export $param_name=$param_value
done < "$SCAN_CSV"
#loop through files, make histograms and fill cross section plot
while IFS=, read -r file_location;
do
	while IFS=, read -r param_name param_value;
	do
		echo "$param_name = $param_value"
		export $param_name="$param_value" #overwrite for specific plot
	done < "$file_location/run_params.csv"
	export independent_variable_value=${!independent_variable}
	#python3 ./remote_scriptsV2/plot_histogram.py
	independent_variable_array+=(${!independent_variable})
	if [ -z "$CROSS_SECTION" ];
	then
		cross_section_array+=(0)
		cross_section_error_array+=(0)
	else
		cross_section_array+=(${CROSS_SECTION})
		cross_section_error_array+=(${CROSS_SECTION_UNCERTAINTY})
	fi
	#add histograms to comparison array
	let histogram_count+=1
	echo "histogram_count=$histogram_count"
	if [[ " ${histograms_to_compare_array[*]} " =~ " ${histogram_count} " ]]; then
    # whatever you want to do when array contains value
    	comparison_histograms+=($file_location)
    	echo "added $file_location to compared histograms"
	fi

		
done < "$FILES_CSV"

export cross_section_file="$SCAN_LOCATION/cross_sections.csv"
echo "creating cross section file"
>$cross_section_file
for i in ${!independent_variable_array[@]}
do
	echo "${independent_variable_array[$i]},${cross_section_array[$i]},${cross_section_error_array[$i]}">>$cross_section_file
done
echo "creating plot"
python3 ./remote_scriptsV2/plot_cross_section.py

rm ${SCAN_DIR}/comparison_histograms.csv
for i in ${comparison_histograms[@]}
do
echo "$i" >> ${SCAN_DIR}/comparison_histograms.csv
done
python3 ./remote_scriptsV2/comparison_histograms.py