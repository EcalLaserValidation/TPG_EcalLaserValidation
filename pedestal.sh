#usage ./pedestal.sh 
week=`date +%V`
#week=`date +%W`   0 to 52 or must be 1 to 53 (+%V)
#week=$(($week+1))   # discrepancy official calendar 2025 - lxplus date command
#previous_week=date -d "last week" +%V
pweek=$(($week-1))
#pweek=$(($week-2))
dir_pedes=../../public/ECAL/PEDES_2026
new=`awk '{print $1}' ${dir_pedes}/in_${week}_prompt.txt`
old=`awk '{print $1}' ${dir_pedes}/in_${pweek}_prompt.txt`

#week=07
new=401418
old=401351

if [ -f /eos/project/e/ecaltrg/www/DBPedestals/Pedes_${new}.db ]; then rm /eos/project/e/ecaltrg/www/DBPedestals/Pedes_${new}.db;fi

cp ${dir_pedes}/Pedes_${new}.db /eos/project/e/ecaltrg/www/DBPedestals/.

git pull
cp ToRun/NewToRun_pedestal.txt ToRun/NewToRun.txt
sed -e "s/sqlite1/$old/g"  ToRun/NewToRun_pedestal.txt > ToRun/NewToRun.txt
sed -e "s/sqlite2/$new/g"  -i ToRun/NewToRun.txt
sed -e "s/ww/$week/g"  -i ToRun/NewToRun.txt

cp new_pedestal.sh new.sh

git add ToRun/NewToRun.txt
git commit -a -m "validate pedestal $new/$old"

git push

