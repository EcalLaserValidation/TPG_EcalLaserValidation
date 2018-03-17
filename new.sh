#!/bin/bash -ex
file=`ls ToRun/`
echo $file
if [ -f ToRun/$file ]
then
echo ToRun/$file
    year=`grep "year" ToRun/$file | awk '{print $2}'`
    week=`grep "week" ToRun/$file | awk '{print $2}'`
    sqlite1=`grep "run1" ToRun/$file | awk '{print $2}'`
    sqlite2=`grep "run2" ToRun/$file | awk '{print $2}'`
cd ..
rm -rf HLT_EcalLaserValidation
git init
git clone https://github.com/EcalLaserValidation/HLT_EcalLaserValidation.git
#git clone ssh://git@github.com/EcalLaserValidation/HLT_EcalLaserValidation.git
cd HLT_EcalLaserValidation
cp ../TPG_EcalLaserValidation/ToRun/$file ToRun/NewToRun.txt
git commit -a -m "update ToRun files: trigger a new validation for IoV=$sqlite2"
#git remote set-url origin ssh://git@github.com/EcalLaserValidation/HLT_EcalLaserValidation.git
git push
cd ../TPG_EcalLaserValidation 
mv ToRun/$file RunFiles/.
git commit -a -m "clean ToRun files"
#git remote set-url origin ssh://git@github.com/EcalLaserValidation/TPG_EcalLaserValidation.git
git push
echo "./tpganalysis_jenkins_2018.sh $sqlite1 $sqlite2 $week $year"
./tpganalysis_jenkins_2018.sh $sqlite1 $sqlite2 $week $year
else
echo "No new files"
fi

