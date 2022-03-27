import os
import numpy as np
from numpy import genfromtxt
import matplotlib.pyplot as plt
SCAN_LOCATION=os.environ["SCAN_LOCATION"]
dark_photon_mass = float(os.environ["DARK_PHOTON_MASS"])
eta= float(os.environ["ETA"])
pt_cutoff= float(os.environ["PT_CUTOFF"])
eta_cutoff= float(os.environ["ETA_CUTOFF"])
com_energy = float(os.environ["LHC_COM_ENERGY"])
number_of_events= int(os.environ["NUMBER_OF_EVENTS"])
independent_variable1=os.environ["independent_variable1"]
independent_variable2=os.environ["independent_variable2"]
independent_variable1_label=os.environ["independent_variable1_label"].replace("/"," ")
independent_variable2_label=os.environ["independent_variable2_label"].replace("/"," ")
title = os.environ["PLOT_TITLE"].replace("/"," ")
x_label = os.environ["x_label"].replace("/"," ")
y_label = os.environ["y_label"].replace("/"," ")
z_label = os.environ["z_label"].replace("/"," ")

file_location=os.environ["file_location"]
#sets filepath, mass range and eta range
filepath=os.environ["cross_section_file"]
variables=np.genfromtxt(filepath, delimiter=",")

independent_variable1_values=variables[:,0]
independent_variable2_values=variables[:,1]
cross_section_array=variables[:,2]
cross_section_error_array=variables[:,3]

L=3000
background=0

#cross_sections=np.reshape(cross_section_array,(len(independent_variable1_values),len(independent_variable2_values)))
#No_events=L*cross_sections
#stat_err=np.reshape(cross_section_error_array,(len(independent_variable1_values),len(independent_variable2_values)))
#stat_err=np.sqrt(No_events)
#significance=(No_events-background)/stat_err


independent_variable1_values_unique=[]
for x in independent_variable1_values:
    if x not in independent_variable1_values_unique:
        independent_variable1_values_unique.append(x)
print(independent_variable1_values_unique)

independent_variable2_values_unique=[]
for x in independent_variable2_values:
    if x not in independent_variable2_values_unique:
        independent_variable2_values_unique.append(x)
print(independent_variable2_values_unique)

rows=len(independent_variable1_values_unique)
columns=len(independent_variable2_values_unique)

cross_section_square_array = np.zeros((columns,rows))
cross_section_error_square_array = np.zeros((columns,rows))
print(cross_section_array)
for i in range(0,columns,1):
    for j in range(0,rows,1):
        print(i+columns*j)
        cross_section_square_array[i][j] = cross_section_array[i+columns*j]
        cross_section_error_square_array[i][j] = cross_section_error_array[i+columns*j]


significance=cross_section_square_array
print(file_location)
#plots a contour plot of the cross sections against 
fig = plt.figure(figsize=(12,8)) 
c=plt.contourf(independent_variable1_values_unique, independent_variable2_values_unique, significance)
#plt.contour(eta_range, mass_range, significance, [3,5]) #WiP line to plot the 3swig #and 5sig contour lines
plt.xlabel(x_label ,fontsize=15)
plt.ylabel(y_label ,fontsize=15)
cbar=plt.colorbar(c)
cbar.set_label('Signficance' ,fontsize=15)
plt.savefig("%s/Contour_plot.png"%SCAN_LOCATION)

fig = plt.figure(figsize=(12,8)) 
ax = fig.add_subplot(111)
x=independent_variable1_values_unique
y=independent_variable2_values_unique
z=significance

z_min=np.min(cross_section_array)
z_max=np.max(cross_section_array)
c = ax.pcolormesh(x, y, z, cmap='RdBu', vmin=z_min, vmax=z_max)

# set the limits of the plot to the limits of the data
ax.axis([np.min(x), np.max(x), np.min(y), np.max(y)])
cbar = fig.colorbar(c, ax=ax)
cbar.set_label(z_label, rotation=270, fontsize=15,labelpad=20)

textstr = "Mass = %.2fGeV\n Eta=%.2f \n pt cutoff = %.2f \n eta cutoff = %.2f \n COM Energy = %.2f \nNumber of Events = %d"%(dark_photon_mass, eta, pt_cutoff,eta_cutoff,com_energy,number_of_events)
fig.text(0.3, 0.6,textstr, ha='center', va='center', fontsize=10,bbox={'facecolor': 'white','pad': 10})
ax.set_xlabel(x_label ,fontsize=15)
ax.set_ylabel(y_label ,fontsize=15)
ax.set_title(title, fontsize=15)
plt.savefig("%s/2dhistogram.png"%SCAN_LOCATION)
