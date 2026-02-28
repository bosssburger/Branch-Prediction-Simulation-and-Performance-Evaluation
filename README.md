# Branch-Prediction-Simulation-and-Performance-Evaluation

This repo contains a school project I worked on in which I implemented four different types of branch prediction (Bimodal, two-level adaptive, local history, and g-share) and wrote analysis of each one's performance. Each prediction type can be performance tested with a variable amount of storage overhead calculated using the passed values for the number of history bits, number of entires in the history table, and number of counter bits as appropriate. In order to asssit with my analysis, I went beyond the project requirements and wrote a script in bash to automate the benchmarking process for some given program traces.

## Usage
Running make will build the executable branchsim necessary for the automation script to run. To benchmark trace files, place the trace files in a directory called "traces" in the root. 

Within the automation script run-real-traces.sh, you must modify the outer for loop to include the names of the traces you would like to benchmark. If you wish to change the storage overhead limits, simply pass a different storage value to the provided functions for each predictor type.

Use command ````bash chmod +x ./run-real-traces.sh```` to make the script runnable then ````bash ./run-real-traces.sh```` to run the automation.
