
###  CHANGE THESE  ###
ww=0.700
chunk=7
part=1




#######################################################################################################################
###     no changes below here                                                                                       ###
###     (except for getting restart file part)                                                                      ###
#######################################################################################################################

templatedir=../TEMPLATES
scriptdir=../SCRIPTS

# Only do once?
if [ "$part" = 1 ] ; then
    mdfile=md.inp.init
else
    mdfile=md.inp
fi

${scriptdir}/gen_res.py ${templatedir}/${mdfile} ${templatedir}/res.inp ${templatedir}/res.post.inp
if [ -f info.txt ] ; then rm info.txt ; fi

startlist=( -22.0 -16.5 -10.5 1.0 7.0 14.5 18.5 )
endlist=( -17.0 -11.0 0.5 6.5 14.0 18.0 22.0 )

j=$(($chunk-1))
start="${startlist[$j]}"
end="${endlist[$j]}"
echo "$start $end"

### ACTUAL SET UP
WWname=$(printf "%03.0f" $(echo $ww*1000 | bc))
prev=$(($part-1))
i=0
for cec in $(seq $start 0.5 $end) ; do
    printf -v dir "%03d" $i
    if [ ! -d $dir ] ; then
        mkdir $dir
    fi

    echo "$dir  $cec" 
    # make plumed files
    sed "s/@@@CEC/$cec/g;s/@@@WW/$ww/g;s/@@@PART/$part/g;s/@@@PREV/$prev/;s/@@@FOLDER/$dir/g" ${templatedir}/plumed_cec.dat > $dir/plumed_cec.dat
    sed "s/@@@CEC/$cec/g;s/@@@WW/$ww/g;s/@@@PART/$part/g;s/@@@PREV/$prev/;s/@@@FOLDER/$dir/g" ${templatedir}/plumed_ww.dat > $dir/plumed_ww.dat

    # get plumed-cec-tmp.dat
    ${scriptdir}/rm_print.py <(sed "s/@@@CEC/$cec/" ${templatedir}/plumed_cec.dat ) $dir/plumed_cec-tmp.dat cvx

    sed "s/@@@FOLDER/${dir}/g" ${templatedir}/plumed_reus.inp > ${dir}/plumed_reus.inp

    # make md.inp
    sed "s/@@@CEC/$cec/g;s/@@@WW/$ww/g;s/@@@PART/$part/g;s/@@@PREV/$prev/;s/@@@FOLDER/$dir/g" ${templatedir}/${mdfile} > $dir/md.inp

    # cp res.inp res.post.inp
    sed "s/@@@CEC/$cec/g;s/@@@WW/$ww/g;s/@@@PART/$part/g;s/@@@PREV/$prev/;s/@@@FOLDER/$dir/g" ${templatedir}/res.inp > $dir/res.inp
    sed "s/@@@CEC/$cec/g;s/@@@WW/$ww/g;s/@@@PART/$part/g;s/@@@PREV/$prev/;s/@@@FOLDER/$dir/g" ${templatedir}/res.post.inp > $dir/res.post.inp

    sed "s/@@@PART/$part/g" ${templatedir}/cmd_b4_run.inp > cmd_b4_run.inp

    #restartf0=../restarts/restart.lql_${cec}_${ww}_1-0
    #restartf1=../restarts/restart.lql_${cec}_${ww}_1-1
    #if [ -f $restartf1 ] ; then
    #    restname=restart.lql_${cec}_${ww}_1-1
    #    restartf=$restartf1
    #    cp $restartf $dir
    #elif [ -f $restartf0 ] ; then
    #    restname=restart.lql_${cec}_${ww}_1-0
    #    restartf=$restartf0
    #    cp $restartf $dir
    #else 
    #    echo "MISSING $restartf0"
    #    restartf=""
    #fi
    #if [ ! -f $restartf ] ; then
    #    echo "MISSING $restartf"
    #else
    #    cp $restartf $dir
    #fi
    restname="restart.lql_${cec}_0.700_1-0"

    sed "s/@@@RESTART/$restname/g;s/@@@CEC/$cec/g;s/@@@WW/$ww/g;s/@@@PART/$part/g;s/@@@PREV/$prev/;s/@@@FOLDER/$dir/g" ${templatedir}/${mdfile} > $dir/md.inp


    echo "$dir  $cec" >> info.txt

    i=$(($i+1))
done

sed "s/@@@NWINS/$i/;s/@@@PART/$part/g;s/@@@WW/$WWname/;s/@@@CHUNK/$chunk/" ${templatedir}/blank.sub > remd.$part.sub

echo "Setup $i windows"

${scriptdir}/write_ini.sh $i
mv remd.ini remd.${part}.in
