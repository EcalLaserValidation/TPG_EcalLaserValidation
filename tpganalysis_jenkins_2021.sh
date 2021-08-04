#!/bin/bash -ex
#Jenkins script for TPGAnalysis and ECAL conditions' validation

echo "Running automated fast track validation script. Will compare ECAL trigger primitives rate difference for two different sets of conditions "
echo "reference and test sqlite files"
echo "usage: ./tpganalysis_jenkins_2021.sh $sqlite1 $sqlite2 $week $year $(getconf _NPROCESSORS_ONLN)"

###############################
dataset=Run2018C/ZeroBias/RAW
GT=112X_dataRun2_v9
reference=320040
sqlite1=$1
sqlite2=$2
week=$3
year=$4
#nevents=1000
nevents=1000
INSTALL=true
RUN=true
###############################

datasetpath=`echo ${dataset} | tr '/' '_'`


export CMSREL=CMSSW_11_2_0
export RELNAME=TPLasVal_1120
export SCRAM_ARCH=slc7_amd64_gcc900

if ${INSTALL}; then
scram p -n $RELNAME CMSSW $CMSREL
cd $RELNAME/src
eval `scram runtime -sh`

git cms-init
git remote add cms-l1t-offline git@github.com:cms-l1t-offline/cmssw.git
git fetch cms-l1t-offline l1t-integration-CMSSW_11_2_0
git cms-merge-topic -u cms-l1t-offline:l1t-integration-v105.13
git cms-addpkg L1Trigger/Configuration
git cms-addpkg L1Trigger/L1TMuon
git clone https://github.com/cms-l1t-offline/L1Trigger-L1TMuon.git L1Trigger/L1TMuon/data
git cms-addpkg L1Trigger/L1TCalorimeter
git clone https://github.com/cms-l1t-offline/L1Trigger-L1TCalorimeter.git L1Trigger/L1TCalorimeter/data
git cms-checkdeps -A -a

scram b -j $(getconf _NPROCESSORS_ONLN)
#git clone --depth 1 -b main https://github.com/CMS-ECAL-Trigger-Group/EcalTPGAnalysis.git
git clone --depth 1 -b main git@github.com:CMS-ECAL-Trigger-Group/EcalTPGAnalysis.git
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

./runTPGbatchLC_jenkins_2021.sh jenkins $reference $dataset $GT $nevents $sqlite1 $(getconf _NPROCESSORS_ONLN) &
wait
./runTPGbatchLC_jenkins_2021.sh jenkins $reference $dataset $GT $nevents $sqlite2 $(getconf _NPROCESSORS_ONLN) &
wait
fi
cp addhist_jenkins_2021.sh log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite1}_batch/.
pushd log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite1}_batch/
./addhist_jenkins_2021.sh ${sqlite1} &
popd
cp addhist_jenkins_2021.sh log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite2}_batch/.
pushd log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite2}_batch/
./addhist_jenkins_2021.sh ${sqlite2} &
popd
wait

mv log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite1}_batch/newhistoTPG_${sqlite1}.root ../../TPGPlotting/plots/.

#wget http://cern.ch/ecaltrg/ReferenceNTuples/TPG/newhistoTPG_${sqlite1}.root  
#mv newhistoTPG_${sqlite1}.root ../../TPGPlotting/plots/.

mv log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite2}_batch/newhistoTPG_${sqlite2}.root ../../TPGPlotting/plots/.

cd ../../TPGPlotting/plots/

./validationplots_jenkins_2021.sh $sqlite1 $sqlite2 $reference $week ${datasetpath}

