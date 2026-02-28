#!/bin/bash
binary="./branchsim"

function validate_test() {

    binary=$1
    trace_name=$2
    p=$3
    k=$4
    c=$5
    s=$6

    config="-p${p} -k${k} -c${c} -s${s}"
    config_name=${trace_name}_${p}_${k}_${c}_${s}

    ${binary} ${config} < traces/${trace_name}.trc > real_output/${config_name}.out
}

function find_best_config_B() {

    best_mispredict=1
    best_config=none
    trace_name=$1
    p=$2
    storage_overhead=$3

    for (( num_entries = 1; num_entries <= storage_overhead; num_entries++ ))
    do
        counter_bits=$(( storage_overhead / num_entries ))
        validate_test "${binary}" "$trace_name" $p $num_entries $counter_bits 4

        config_file=real_output/${trace_name}_${p}_${num_entries}_${counter_bits}_4.out
        curr_mispredict=$(grep "Misprediction Rate:" ${config_file} | awk '{print $3}')

        if (( $(echo "$curr_mispredict < $best_mispredict" | bc -l) )); then
            best_mispredict=$curr_mispredict
            best_config=${p}_${num_entries}_${counter_bits}_4
        fi

    done
    echo "$best_config $best_mispredict"
}

function find_best_config_G() {

    best_mispredict=1
    best_config=none
    trace_name=$1
    p=$2
    storage_overhead=$3
    history_bits=1
    counter_bits=$(( (storage_overhead-1)/2 ))

    while (( (1 << history_bits) * counter_bits + history_bits <= storage_overhead && counter_bits != 0 ))
    do
        validate_test "${binary}" "$trace_name" $p 16 $counter_bits $history_bits

        config_file=real_output/${trace_name}_${p}_16_${counter_bits}_${history_bits}.out
        curr_mispredict=$(grep "Misprediction Rate:" ${config_file} | awk '{print $3}')

        if (( $(echo "$curr_mispredict < $best_mispredict" | bc -l) )); then
            best_mispredict=$curr_mispredict
            best_config=${p}_16_${counter_bits}_${history_bits}
        fi

        (( history_bits++ ))
        counter_bits=$(( (storage_overhead - history_bits) / (1 << history_bits) ))
    done
    echo "$best_config $best_mispredict"
}

function find_best_config_L() {

    best_mispredict=1
    best_config=none
    trace_name=$1
    p=$2
    storage_overhead=$3

    for (( num_entries = 1; num_entries <= storage_overhead / 3; num_entries++ ))
    do
        for (( history_bits = 1; history_bits + (1 << history_bits) <= storage_overhead / num_entries; history_bits++ ))
        do
            counter_bits=$(( (storage_overhead - num_entries * history_bits) / ((1 << history_bits) * num_entries) ))
            if (( counter_bits == 0 )); then
                break
            fi
            validate_test "${binary}" "$trace_name" $p $num_entries $counter_bits $history_bits

            config_file=real_output/${trace_name}_${p}_${num_entries}_${counter_bits}_${history_bits}.out
            curr_mispredict=$(grep "Misprediction Rate:" ${config_file} | awk '{print $3}')

            if (( $(echo "$curr_mispredict < $best_mispredict" | bc -l) )); then
                best_mispredict=$curr_mispredict
                best_config=${p}_${num_entries}_${counter_bits}_${history_bits}
            fi
        done
    done
    mv real_output/${trace_name}_${best_config}.out best_outputs
    rm -rf real_output
    mkdir real_output
    echo "$best_config $best_mispredict"
}

function find_best_config_T() {

    best_mispredict=1
    best_config=none
    trace_name=$1
    p=$2
    storage_overhead=$3

    for (( num_entries = 1; num_entries <= storage_overhead - 2; num_entries++ ))
    do
        for (( history_bits = 1; num_entries * history_bits + (1 << history_bits) <= storage_overhead; history_bits++ ))
        do
            counter_bits=$(( (storage_overhead - num_entries * history_bits) / (1 << history_bits) ))
            if (( counter_bits == 0 )); then
                break
            fi
            validate_test "${binary}" "$trace_name" $p $num_entries $counter_bits $history_bits

            config_file=real_output/${trace_name}_${p}_${num_entries}_${counter_bits}_${history_bits}.out
            curr_mispredict=$(grep "Misprediction Rate:" ${config_file} | awk '{print $3}')

            if (( $(echo "$curr_mispredict < $best_mispredict" | bc -l) )); then
                best_mispredict=$curr_mispredict
                best_config=${p}_${num_entries}_${counter_bits}_${history_bits}
            fi
        done
    done
    mv real_output/${trace_name}_${best_config}.out best_outputs
    rm -rf real_output
    mkdir real_output
    echo "$best_config $best_mispredict"
}

if [ ! -f "${binary}" ]
then
    echo "Executable ${binary}" not found
    exit 1
fi

rm -rf real_output
mkdir real_output

rm -rf best_outputs
mkdir best_outputs

for trace_name in "bzip2" "gcc" "h264ref"
do
    # 32 bits
    echo "=============best 32-bit config $trace_name============="
    find_best_config_B $trace_name B 32
    find_best_config_G $trace_name G 32
    find_best_config_L $trace_name L 32
    find_best_config_T $trace_name T 32

    # 64 bits
    echo "=============best 64-bit config $trace_name============="
    find_best_config_B $trace_name B 64
    find_best_config_G $trace_name G 64
    find_best_config_L $trace_name L 64
    find_best_config_T $trace_name T 64

    # 128 bits
    echo "=============best 128-bit config $trace_name============="
    find_best_config_B $trace_name B 128
    find_best_config_G $trace_name G 128
    find_best_config_L $trace_name L 128
    find_best_config_T $trace_name T 128

    # 256 bits
    echo "=============best 256-bit config $trace_name============="
    find_best_config_B $trace_name B 256
    find_best_config_G $trace_name G 256
    find_best_config_L $trace_name L 256
    find_best_config_T $trace_name T 256

    # 512 bits
    echo "=============best 512-bit config $trace_name============="
    find_best_config_B $trace_name B 512
    find_best_config_G $trace_name G 512
    find_best_config_L $trace_name L 512
    find_best_config_T $trace_name T 512

    # 1024 bits
    echo "=============best 1024-bit config $trace_name============="
    find_best_config_B $trace_name B 1024
    find_best_config_G $trace_name G 1024
    find_best_config_L $trace_name L 1024
    find_best_config_T $trace_name T 1024

    # 2048 bits
    echo "=============best 2048-bit config $trace_name============="
    find_best_config_B $trace_name B 2048
    find_best_config_G $trace_name G 2048
    find_best_config_L $trace_name L 2048
    find_best_config_T $trace_name T 2048

    # 4096 bits
    echo "=============best 4096-bit config $trace_name============="
    find_best_config_B $trace_name B 4096
    find_best_config_G $trace_name G 4096
    find_best_config_L $trace_name L 4096
    find_best_config_T $trace_name T 4096
done
