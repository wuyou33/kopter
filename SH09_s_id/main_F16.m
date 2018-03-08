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
flightEnvelopePoint.altitude_ft = 10000;


%Load plotting options
FsClass.setPlottingOptions()

%Generate and linearize model of F-16
cd([dirWork.main '/SIDPAC_V2.0/F16_NLS_V1.1'])
gen_f16_model
cd(dirWork.main)