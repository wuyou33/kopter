
%Get timeseries collection from sim output
[outFromSimCol] = FsClass.outFromSimFn(states, forces, inputs, accels);
clearvars states forces inputs accels

FsClass.plotOutput(outFromSimCol, plotSet);

