clear all
clc
restoredefaultpath

%Main code
dirWork.main = pwd;

SIDPAC_startup; %Load SIDPAC functions to path

%Global variables
global plotSet 
global flightEnvelopePoint

% Define flight envelope point
flightEnvelopePoint.vel_kts = 300;
flightEnvelopePoint.altitude_ft = 12000;


%Load plotting options
FsClass.setPlottingOptions()

%Generate model for F16
[initVals] = FsClass.initF16Model(dirWork);