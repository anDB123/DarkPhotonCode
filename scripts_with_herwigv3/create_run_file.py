import numpy as np
import os
dark_photon_mass = float(os.environ["DARK_PHOTON_MASS"])
lhc_com_energy = float(os.environ["LHC_COM_ENERGY"])
transverse_momentum_cutoff = float(os.environ["PT_CUTOFF"]) #in GeV
eta_cutoff = float(os.environ["ETA_CUTOFF"])
mixing_parameter = float(os.environ["MIXING_PARAMETER"])
number_of_events = int(os.environ["NUMBER_OF_EVENTS"]) #for cross section purposes
event_processes = os.environ["event_process_array"].split('C')
specific_file_structure = os.environ["SPECIFIC_FILE_STRUCTURE"]
madgraph_run_output = os.environ["MADGRAPH_RUN_OUTPUT"]


lines = []
lines = np.append(lines,"import model HAHM_variableMW_v3_UFO")
for event_process in event_processes:
    event_process=event_process.replace("S"," ")
    lines = np.append(lines,"add process %s"%event_process)
lines = np.append(lines,"output %s"%madgraph_run_output)
lines = np.append(lines,"launch")
lines = np.append(lines,"done")
lines = np.append(lines,"set nevents %d"%number_of_events)
lines = np.append(lines,"set lhc %d"%lhc_com_energy)
lines = np.append(lines,"set pdlabel lhapdf")
lines = np.append(lines,"set lhaid 82400")
lines = np.append(lines,"set ptl %f" % transverse_momentum_cutoff)
lines = np.append(lines,"set etal %f" %eta_cutoff)
lines = np.append(lines,"set mzdinput %f" % dark_photon_mass)
lines = np.append(lines,"set wzp auto")
epsilon=mixing_parameter*0.876801 #multiplied by cos theta_w
lines = np.append(lines,"set epsilon %f"%epsilon)
lines = np.append(lines,"set kap 0.00000000001")
lines = np.append(lines,"done")

with open("%s/runfile.run"%(specific_file_structure), 'w') as f:
    for line in lines:
        f.write(line)
        f.write('\n')
