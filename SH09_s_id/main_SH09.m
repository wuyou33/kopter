clear all
clc
% Main code

dirWork.main = pwd;

dirWork.linearDataSH09_folder = [dirWork.main '/fromFlightPhysics/FL_LTI_models'];

loadInitial.FL_data_sel = 1; %1,2,3,4,5,6

SH09lin = FsClass.loadSH09_lin(dirWork, loadInitial);

cd(dirWork.main)	