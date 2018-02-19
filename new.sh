#!/bin/bash 
file=`ls ToRun/`
echo $file
if [ -f ToRun/$file ]
then
echo ToRun/$file
    year=`grep "year" ToRun/$file | awk '{print $2}'`
    week=`grep "week" ToRun/$file | awk '{print $2}'`
    sqlite1=`grep "run1" ToRun/$file | awk '{print $2}'`
    sqlite2=`grep "run2" ToRun/$file | awk '{print $2}'`
mv ToRun/$file RunFiles/.
echo "./tpganalysis_jenkins_2018.sh $sqlite1 $sqlite2 $week $year"
./tpganalysis_jenkins_2018.sh $sqlite1 $sqlite2 $week $year 
else
echo "No new files"
fi

