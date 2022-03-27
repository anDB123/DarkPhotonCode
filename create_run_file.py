import numpy as np
import os
dark_photon_mass = float(os.environ["DARK_PHOTON_MASS"])
lhc_com_energy = float(os.environ["LHC_COM_ENERGY"])
transverse_momentum_cutoff = float(os.environ["PT_CUTOFF"]) #in GeV
eta_cutoff = float(os.environ["ETA_CUTOFF"])
eta = float(os.environ["ETA"])
number_of_events = int(os.environ["NUMBER_OF_EVENTS"]) #for cross section purposes
event_processes = os.environ["EVENT_PROCESSES"]
event_processes = event_processes.replace("S"," ")
extra_event_process = os.environ["EXTRA_EVENT_PROCESSES"]
extra_event_process = extra_event_process.replace("S"," ")
runfile_output = os.environ["RUNFILE_OUTPUT"]
madgraph_run_output = os.environ["MADGRAPH_RUN_OUTPUT"]


lines = []
lines = np.append(lines,"import model HAHM_variableMW_v3_UFO")
lines = np.append(lines,"generate %s"%event_processes)
if extra_event_process:
    lines = np.append(lines,"add process %s"%extra_event_process)
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
epsilon=eta*0.876801
lines = np.append(lines,"set epsilon %f"%epsilon)
lines = np.append(lines,"set kap 0.00000000001")
lines = np.append(lines,"done")

with open("%s"%(runfile_output), 'w') as f:
    for line in lines:
        f.write(line)
        f.write('\n')
