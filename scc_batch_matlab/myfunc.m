function myfunc(rank, outname)
%function myfunc(rank, outname)
disp('This is a MATLAB function m-file')
if rank == 1
  disp(['Perform a task with rank ' num2str(rank)])
else
  disp(['Perform another task with rank ' num2str(rank)])
end
% alternatively, may construct outname here with "rank"
save(outname,'rank');    % save data as mat-file
end
