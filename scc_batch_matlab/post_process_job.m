#!/bin/csh
# this script is a companion script for submitmjobs for MATLAB apps
# a number of individual tasks has been submitted to queue via submitmjobs
# With hold_jid, this queued post processing job will start only after all
# previous jobs have been completed. For this example, myfunc writes 
# the rank (task)  number to a file for each task. The post processing job
# then load these files and write them to a single file, combine_output.mat:

unsetenv DISPLAY
# IMPORTANT: DONOT indent any of the below statements
matlab -nojvm -singleCompThread  << MATLAB_ENV
ntasks = $MATLAB_NTASKS
for task=1:ntasks
load(['output' num2str(task)],'rank')
a(task) = rank;
end
save('combine_output','a')
exit
MATLAB_ENV
# keep this line to ensure a newline
