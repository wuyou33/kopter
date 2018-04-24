%Script

clc;
clear all

rng(1);

options = optimset('fmincon');
options = optimset(options, 'Display', 'iter-detailed');
options = optimset(options, )