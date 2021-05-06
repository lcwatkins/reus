outf='remd.ini'
nwins=$1

if [ "$nwins" = "" ] ; then
    printf "Give # wins"
fi


printf "T 1 1 298.00\n\n" > $outf
printf "V $nwins ''\n" >> $outf

for i in $(seq 0 $(($nwins-1))) ; do 
    printf "'%03d/plumed_reus.inp'\n" $i >> $outf
done

printf "\nLAMMPS md md md.inp res.inp res.post.inp\n\n" >> $outf

printf "HREMD 500 1000\n\n" >> $outf

printf "SEPARATE ''\n\n" >> $outf

printf "RESTART 'restart'\n\n" >> $outf

printf "COMMAND_BEFORE_RUN 'cmd_b4_run.inp'\n\n" >> $outf

