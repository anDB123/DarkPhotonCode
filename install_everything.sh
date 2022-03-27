#Change to the correct version of python, gcc and gfortran
#Python 3.7.6 , gcc (GCC) 8.3.0 , GNU Fortran (GCC) 8.3.0
source /cvmfs/sft.cern.ch/lcg/releases/LCG_98python3/Python/3.7.6/x86_64-centos7-gcc8-opt/Python-env.sh
#installing Modified Madgraph (MG5_aMC_v3_2_0_leptonfromproton)
wget https://cernbox.cern.ch/index.php/s/rF9uL520UaMrASK/download
unzip download
rm download
#installing Abelian Model
wget http://insti.physics.sunysb.edu/~curtin/HAHM_MG5model/HAHM_MG5model_v3.tar.gz
tar -xf HAHM_MG5model_v3.tar.gz
cp -r ./HAHM_MG5model_v3/HAHM_variableMW_v3_UFO ./MG5_aMC_v3_2_0_leptonfromproton/models
rm HAHM_MG5model_v3.tar.gz 
rm -r HAHM_MG5model_v3/
python3 ./MG5_aMC_v3_2_0_leptonfromproton/bin/mg5_aMC
set auto_convert_model T
import model HAHM_variableMW_v3_UFO
#installing LHAPDF (this is the longest step)
install lhapdf6
#test for installation
generate mu+ mu+ > mu+ mu+
add process mu- mu- > mu- mu-
output 
launch
done
set lhc 13
set pdlabel lhapdf
set lhaid 82400
set ptl 20
set etal 2.4
set MZp 5
set WZP auto
set eta 1
done
exit
#should have worked!!!
