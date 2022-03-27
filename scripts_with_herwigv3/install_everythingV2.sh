#Before running this you will need to:
#install python2
#install python3
#install cython
#install numpy
#Python 3.7.6
sudo apt install software-properties-common
sudo add-apt-repository ppa:ubuntu-toolchain-r/test



sudo apt-get install m4

sudo apt-get install python
sudo apt-get install python3
sudo apt install python3-pip
pip install numpy
sudo apt-get install g++-8
sudo apt-get install gcc-8
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 800 --slave /usr/bin/g++ g++ /usr/bin/g++-8
sudo apt-get install -y gfortran-8
sudo update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-8 50

#gcc (GCC) 8.3.0
#GNU Fortran (GCC) 8.3.0
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

STRING=(
"install lhapdf6 \n"
"set auto_convert_model T \n"
"import model HAHM_variableMW_v3_UFO \n"
"generate mu+ mu+ > mu+ mu+ \n"
"add process mu- mu- > mu- mu- \n"
"output temp_folder\n"
"launch \n"
"done \n"
"set lhc 13 \n"
"set pdlabel lhapdf \n"
"set lhaid 82400 \n"
"set ptl 20 \n"
"set etal 2.4 \n"
"set MZp 5 \n"
"set WZP auto \n"
"set eta 1 \n"
"done  \n"
"exit \n"
)
echo -e ${STRING[@]} > lhapdf_install.run
python3 ./MG5_aMC_v3_2_0_leptonfromproton/bin/mg5_aMC lhapdf_install.run
rm lhapdf_install.run #cleanup
rm -r temp_folder
#should have worked!!!


sed -i "s|# automatic_html_opening = True|automatic_html_opening = False|" ./MG5_aMC_v3_2_0_leptonfromproton/input/mg5_configuration.txt
wget https://herwig.hepforge.org/downloads/herwig-bootstrap
chmod +x ./herwig-bootstrap
./herwig-bootstrap ./herwig --build-gcc -j 4
wget http://lhapdfsets.web.cern.ch/lhapdfsets/current/LUXlep-NNPDF31_nlo_as_0118_luxqed.tar.gz
tar -xf LUXlep-NNPDF31_nlo_as_0118_luxqed.tar.gz
cp -r LUXlep-NNPDF31_nlo_as_0118_luxqed ./herwig/share/LHAPDF
#should now work
mkdir rivet
