% Old code
% dirWork.linearDataSH09_folder = [dirWork.main '/fromFlightPhysics/FL_LTI_models'];
% loadInitial.FL_data_sel = 1; %1,2,3,4,5,6
% SH09lin = FsClass.loadSH09_lin(dirWork, loadInitial);

clear all
clc

dirWork.main = pwd;

if ispc
    path(path,[dirWork.main,'\functions']),
elseif isunix
    path(path,[dirWork.main,'/functions']),
end
% Main code

dirWork.FTfolder = [dirWork.main '/flightTestData/P2-J17-01-FT0038/data'];

ftDataStruct = FsClass.importDataFlightTestDataAll(dirWork);

cd(dirWork.main)	