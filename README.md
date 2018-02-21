# TPG_EcalLaserValidation

CMS-ECAL_TPGAnalysis (9_4_0_pre3)

## This houses scripts to run the ECALTPGAnalysis of CMS with jenkins jobs 
## It runs on Jenkins in order to validate the ECAL conditions (laser corrections, pedestals...)

## To trigger the running new.sh is included in the jenkins system cron jobs
## runs only when the input configuration file of new.sh is modified

## To modify ToRun/NewtoRun.txt anywhere, do:

```bash
git clone https://github.com/EcalLaserValidation/TPG_EcalLaserValidation.git
```
## edit ToRun/NewtoRun.txt with new conditions
week 40
year 2017
run1 304093 =sqlite1
run2 304204 =sqlite2

# For the automated procedure of the conditions validation, 
# ToRun/NewtoRun.txt is modified by a cron job then
 
# new.sh runs a script
./tpganalysis_jenkins_2018.sh $sqlite1 $sqlite2 $week $year 

## ======================================================================================================================
## THE FOLLOWING DESCRIBES THE STEPS BUT DOES NOT NEED TO BE DONE MANUALLY, ALL DONE BY THE PREVIOUS SCRIPT

# tpganalysis_jenkins_2018.sh runs scripts housed and updated here:
https://gitlab.cern.ch/ECALPFG/EcalTPGAnalysis/tree/tpganalysis_jenkins

# inside the script there is a link to where the sqlite files can be downloaded from: these are the same one that L1 emulation can use 
wget http://cern.ch/ecaltrg/EcalLin/EcalTPG_${sqlite1}_moved_to_1.db
wget http://cern.ch/ecaltrg/EcalLin/EcalTPG_${sqlite2}_moved_to_1.db

# The jobs can then be run:
./runTPGbatchLC_jenkins_2018.sh jenkins $reference $dataset $GT $nevents $sqlite1 &
./runTPGbatchLC_jenkins_2018.sh jenkins $reference $dataset $GT $nevents $sqlite2 &

## ======================================================================================================================




# The output of jenkins can be found here:
wget http://cmssdt.cern.ch/SDT/jenkins-artifacts/TPG_EcalLaserValidation/TPGAnalysis-2018-$week-$sqlite1-$sqlite2.tgz  

# the slides for the validation are produced here:
http://ecaltrg.web.cern.ch/ecaltrg/TPGAnalysis/2018/Slides/

 
 

