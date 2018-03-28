#!/bin/bash -ex
#Jenkins script for TPGAnalysis and ECAL conditions' validation

echo "Running automated fast track validation script. Will compare ECAL trigger primitives rate difference for two different sets of conditions "
echo "reference and test sqlite files"
echo "usage: ./tpganalysis_jenkins_2018.sh $sqlite1 $sqlite2 $week $year"

###############################
dataset=Run2017D/SinglePhoton/RAW/v1
#GT=94X_dataRun2_v2
GT=100X_dataRun2_v1
reference=302635
sqlite1=$1
sqlite2=$2
week=$3
year=$4
nevents=1000
INSTALL=true
RUN=true
###############################

datasetpath=`echo ${dataset} | tr '/' '_'`

#export CMSREL=CMSSW_9_4_0_pre3
#export RELNAME=TPLasVal_940pre3
export CMSREL=CMSSW_10_0_0
export RELNAME=TPLasVal_1000
export SCRAM_ARCH=slc6_amd64_gcc630

if ${INSTALL}; then
scram p -n $RELNAME CMSSW $CMSREL
cd $RELNAME/src
eval `scram runtime -sh`

git cms-init
#oldgit remote add cms-l1t-offline git@github.com:cms-l1t-offline/cmssw.git
##oldgit fetch cms-l1t-offline
#oldgit fetch https://github.com/cms-l1t-offline/cmssw.git
#oldgit cms-merge-topic -u cms-l1t-offline:l1t-integration-v97.1
git remote add cms-l1t-offline git@github.com:cms-l1t-offline/cmssw.git
git fetch cms-l1t-offline l1t-integration-CMSSW_10_0_0
git cms-merge-topic -u cms-l1t-offline:l1t-integration-v97.17-v2

git cms-addpkg L1Trigger/L1TCommon
git cms-addpkg L1Trigger/L1TMuon
#oldgit clone --depth 1 https://github.com/cms-l1t-offline/L1Trigger-L1TMuon.git L1Trigger/L1TMuon/data
git clone https://github.com/cms-l1t-offline/L1Trigger-L1TMuon.git L1Trigger/L1TMuon/data
# git cms-addpkg L1Trigger/L1TCalorimeter #not sure if needed
# git clone https://github.com/cms-l1t-offline/L1Trigger-L1TCalorimeter.git L1Trigger/L1TCalorimeter/data #gives an error

scram b -j $(getconf _NPROCESSORS_ONLN)
#cp -r /eos/cms/store/caf/user/ecaltrg/EcalTPGAnalysis .
git clone --depth 1 -b tpganalysis_jenkins https://gitlab.cern.ch/ECALPFG/EcalTPGAnalysis.git
export USER_CXXFLAGS="-Wno-delete-non-virtual-dtor -Wno-error=unused-but-set-variable -Wno-error=unused-variable -Wno-error=sign-compare -Wno-error=reorder"
scram b -j $(getconf _NPROCESSORS_ONLN)
else
cd $RELNAME/src
fi
eval `scram runtime -sh`
cd EcalTPGAnalysis/Scripts/TriggerAnalysis
if ${RUN}; then
wget http://cern.ch/ecaltrg/EcalLin/EcalTPG_${sqlite1}_moved_to_1.db
wget http://cern.ch/ecaltrg/EcalLin/EcalTPG_${sqlite2}_moved_to_1.db

#./runTPGbatchLC_jenkins_2018.sh jenkins $reference $dataset $GT $nevents $sqlite1 &
./runTPGbatchLC_jenkins_2018.sh jenkins $reference $dataset $GT $nevents $sqlite2 &
wait
fi
#cp addhist_jenkins_2018.sh log_and_results/${reference}-${datasetpath}-LC-IOV_${sqlite1}-batch/.
#pushd log_and_results/${reference}-${datasetpath}-LC-IOV_${sqlite1}-batch/
#./addhist_jenkins_2018.sh ${sqlite1} &
#popd
cp addhist_jenkins_2018.sh log_and_results/${reference}-${datasetpath}-LC-IOV_${sqlite2}-batch/.
pushd log_and_results/${reference}-${datasetpath}-LC-IOV_${sqlite2}-batch/
./addhist_jenkins_2018.sh ${sqlite2} &
popd
wait

#mv log_and_results/${reference}-${datasetpath}-LC-IOV_${sqlite1}-batch/newhistoTPG_${sqlite1}_eg12.root ../../TPGPlotting/plots/.

wget http://cern.ch/ecaltrg/ReferenceNTuples/TPG/newhistoTPG_${sqlite1}_eg12.root  
mv newhistoTPG_${sqlite1}_eg12.root ../../TPGPlotting/plots/.

mv log_and_results/${reference}-${datasetpath}-LC-IOV_${sqlite2}-batch/newhistoTPG_${sqlite2}_eg12.root ../../TPGPlotting/plots/.

cd ../../TPGPlotting/plots/

./validationplots_jenkins_2018.sh $sqlite1 $sqlite2 $reference $week

