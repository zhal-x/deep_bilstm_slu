#!/bin/sh
F1_file="F1.txt"
rm -f $F1_file
rm -f atis_ensemble_result.txt
cntk_v="/cygdrive/d/repos/cntk/x64/Release/cntk.exe"

train_file="atis.train.ctf" 
test_file="atis.test.ctf"

layers=(4 3 2 2 1 1 1 1)
rate=(10 10 10 20 10 20 40 80)

for ((i=0; i<${#layers[@]}; i++))
do
    models_=""
    layer=${layers[$i]}
    r=${rate[$i]} 
    l1=$(echo "scale=5; "$r" * 0.001" | bc)
    l2=$(echo "scale=5; "$l1" * 0.5"  | bc)
    l3=$(echo "scale=5; "$l1" * 0.1"  | bc)
    l="$l1"*2:"$l2"*12:"$l3"
    
    model="atis"
    for((n=1;n<=20;n+=2)) 
    do
        u=`printf "%04d" $r`
        v=`printf "%04d" $n`
        modeld=$model"_"$layer"_"$u"_"$v
        if [ ! -f $modeld/result.txt ]
        then
            echo $cntk_v configFile=$model.cntk command=TrainTagger deviceId=0 randomSeedOffset=$n modelDir="$modeld" learningRates="$l" train_file="$train_file" numLayers="$layer" std_name="log_Train"
            $cntk_v configFile=$model.cntk command=TrainTagger deviceId=0 randomSeedOffset=$n modelDir="$modeld" learningRates="$l" train_file="$train_file" numLayers="$layer" std_name="log_Train"
            $cntk_v configFile=$model.cntk command=OutputTagger deviceId=0 modelDir="$modeld" test_file="$test_file" std_name="log_out_label" output_name="label"
            paste -d' ' data/test.ref $modeld/label.final > $modeld/output.txt
            cat $modeld/output.txt | perl -ne '{chomp;s/\r//g;print $_,"\n";}' | perl conlleval.pl | grep "accuracy" > $modeld/result.txt
        fi
        awk '{print $8}' "$modeld/result.txt" >> $F1_file 
        models_=$models_" "$modeld/label.final
    done
    python ensemble_vote.py $models_ > atis_p.label
    paste -d' ' data/test.ref atis_p.label > atis_p_output.txt
    cat atis_p_output.txt | perl -ne '{chomp;s/\r//g;print $_,"\n";}' | perl conlleval.pl | grep "accuracy" >> atis_ensemble_result.txt
done

rm -f atis_p_output.txt atis_p.label
