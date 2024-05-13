#!/bin/bash -ex
#Jenkins script for TPGAnalysis and ECAL conditions' validation

echo "Running automated fast track validation script. Will compare ECAL trigger primitives rate difference for two different sets of conditions "
echo "reference and test sqlite files"
echo "usage: ./tpganalysis_jenkins_2024.sh $sqlite1 $sqlite2 $week $year $(getconf _NPROCESSORS_ONLN)"

###############################
dataset=Run2024D-v1/ZeroBias/RAW
GT=140X_dataRun3_Prompt_v2
#GT=130X_dataRun3_Prompt_v3
reference=380446
sqlite1=$1
sqlite2=$2
week=$3
year=$4
#nevents=1000
nevents=800
INSTALL=true
RUN=true
###############################

datasetpath=`echo ${dataset} | tr '/' '_'`


#export CMSREL=CMSSW_13_1_0_pre4
export CMSREL=CMSSW_14_0_6
#export RELNAME=TPLasVal_1310pre4
export RELNAME=TPLasVal_1406
#export SCRAM_ARCH=slc7_amd64_gcc11
export SCRAM_ARCH=el8_amd64_gcc12

if ${INSTALL}; then
scram p -n $RELNAME CMSSW $CMSREL
cd $RELNAME/src
eval `scram runtime -sh`

git cms-init
git clone https://github.com/cms-l1t-offline/L1Trigger-L1TCalorimeter.git L1Trigger/L1TCalorimeter/data

git cms-checkdeps -A -a

scram b -j $(getconf _NPROCESSORS_ONLN)
#git clone --depth 1 -b main https://github.com/CMS-ECAL-Trigger-Group/EcalTPGAnalysis.git
git clone --depth 1 -b main git@github.com:CMS-ECAL-Trigger-Group/EcalTPGAnalysis.git
export USER_CXXFLAGS="-Wno-delete-non-virtual-dtor -Wno-error=unused-but-set-variable -Wno-error=unused-variable -Wno-error=sign-compare -Wno-error=reorder"
scram b -j $(getconf _NPROCESSORS_ONLN)
cp runListFiles_${reference}_path.txt $RELNAME/src/EcalTPGAnalysis/Scripts/TriggerAnalysis/.
else
cd $RELNAME/src
fi
eval `scram runtime -sh`
cd EcalTPGAnalysis/Scripts/TriggerAnalysis
if ${RUN}; then
#wget http://cern.ch/ecaltrg/EcalLin/EcalTPG_${sqlite1}_moved_to_1.db
wget http://cern.ch/ecaltrg/EcalLin/EcalTPG_${sqlite2}_moved_to_1.db

#./runTPGbatchLC_jenkins_2024.sh jenkins $reference $dataset $GT $nevents $sqlite1 $(getconf _NPROCESSORS_ONLN) &
#wait
./runTPGbatchLC_jenkins_2024.sh jenkins $reference $dataset $GT $nevents $sqlite2 $(getconf _NPROCESSORS_ONLN) &
wait
fi
#cp addhist_jenkins_2024.sh log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite1}_batch/.
#pushd log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite1}_batch/
#./addhist_jenkins_2024.sh ${sqlite1} &
#popd
cp addhist_jenkins_2024.sh log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite2}_batch/.
pushd log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite2}_batch/
./addhist_jenkins_2024.sh ${sqlite2} &
popd
wait

#mv log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite1}_batch/newhistoTPG_${sqlite1}.root ../../TPGPlotting/plots/.

if [[ `wget -S --spider https://cmssdt.cern.ch/SDT/public/EcalLaserValidation/TPG_EcalLaserValidation/TPGAnalysis_${sqlite1}/newhistoTPG_${sqlite1}.root 2>&1 | grep 'HTTP/1.1 200 OK'` ]]
	then 
    	wget https://cmssdt.cern.ch/SDT/public/EcalLaserValidation/TPG_EcalLaserValidation/TPGAnalysis_${sqlite1}/newhistoTPG_${sqlite1}.root
	else
		if [[ `wget -S --spider https://ecaltrg.web.cern.ch/ecaltrg/ReferenceNTuples/TPG/newhistoTPG_${sqlite1}.root  2>&1 | grep 'HTTP/1.1 200 OK'` ]]
		then
		wget https://cern.ch/ecaltrg/ReferenceNTuples/TPG/newhistoTPG_${sqlite1}.root  
		else
   		#cp output_ref_349295_pedestal.log output_ref_${1}_${3}.log
    		mail -s "TPG_validation failed to find reference ${sqlite1} running jenkins" ecaltrg@cern.ch <<< "TPG_validation failed to find reference ${sqlite1}"
		fi
fi

mv newhistoTPG_${sqlite1}.root ../../TPGPlotting/plots/.

mv log_and_results/${reference}_${datasetpath}_LC_IOV_${sqlite2}_batch/newhistoTPG_${sqlite2}.root ../../TPGPlotting/plots/.

cd ../../TPGPlotting/plots/

./validationplots_jenkins_2024.sh $sqlite1 $sqlite2 $reference $week $year

