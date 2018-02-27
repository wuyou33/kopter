clc
close all
clear all


%% open simulink 

% model_sel = input('Select SH90 P3 model (trim fwd 100Kts) : \n [1] v1 full state \n [2] v1 redux state  \n [3] v2 full state \n [4] v2 redux state \n: ');
model_sel = input('Select SH90 P3 model (trim fwd 100Kts) : \n [1] rigid blade full state \n [2] rigid blade redux state \n [3] flexible blade full state \n: '); % v2 it is not available

if model_sel == 1

    load P3_FL_model_LTI_100kts_v1_full % excact the same of P3_FL_model_LTI_100kts_rigid.mat

elseif model_sel == 3
    
    load P3_FL_model_LTI_100kts_flex

elseif model_sel == 2 

    redu_sel = input('Select model reduction type : \n [1] balreal-modred \n [2] minreal  \n [3] sminreal \n: ');
    
    if redu_sel == 1
        load P3_FL_model_LTI_100kts_v1_redu_1
    elseif redu_sel == 2
        load P3_FL_model_LTI_100kts_v1_redu_2
    elseif redu_sel == 3
        load P3_FL_model_LTI_100kts_v1_redu_3
    end

% elseif model_sel == 4
%     
%     redu_sel = input('Select model reduction type : \n [1] balreal-modred \n [2] minreal  \n [3] sminreal \n: ');
%     
%     if redu_sel == 1
%         load P3_FL_model_LTI_100kts_v2_redu_1
%     elseif redu_sel == 2
%         load P3_FL_model_LTI_100kts_v2_redu_2
%     elseif resu_sel == 3
%         load P3_FL_model_LTI_100kts_v2_redu_3
%     end
    
end

case_sel = input('Select the case : \n [1] general FCS \n [2] FCS for yaw manouver \n [3] FCS for pitch manouver \n: ');
    
if case_sel == 1
    
    ctrl_sel = input('Select FCS scheme to be tuned : \n [1] only outer loop (for tracking, PI controllers) \n [2] outer loop + inner loop (for stability augmentation and decoupling, static output feedback) \n [3] outer loop + inner loop + roll-off filters \n: ');

elseif case_sel ==2
    
    ctrl_sel = input('Select FCS scheme to be tuned : \n [4] only outer loop PI (on theta phi), YAW open-loop \n [5] outer loop + inner loop PI (on theta phi), YAW open-loop \n [6] outer loop + inner loop PI (on theta phi), YAW closed only on SAS \n [7] only outer loop PID (on theta phi), YAW open-loop \n [8] outer loop + inner loop PID (on theta phi), YAW open-loop \n [9] outer loop + inner loop PID (on theta phi), YAW closed only on SAS \n: '); 
    
elseif case_sel == 3
    
    ctrl_sel = input('Select FCS scheme to be tuned : \n [10] only outer loop PI (on phi r), PITCH open-loop \n [11] only outer loop PID (on phi r), PITCH open-loop \n [12] only outer loop PI (on phi psi), PITCH open-loop \n [13] only outer loop PID (on phi psi), PITCH open-loop \n [14] outer loop + inner loop PI (on phi r), PITCH open-loop \n [15] outer loop + inner loop PI (on phi r), PITCH closed only on SAS \n [16] outer loop + inner loop PID (on phi r), PITCH open-loop \n [17] outer loop + inner loop PID (on phi r), PITCH closed only on SAS \n [18] outer loop + inner loop PI (on phi psi), PITCH open-loop \n [19] outer loop + inner loop PI (on phi psi), PITCH closed only on SAS \n [20] outer loop + inner loop PID (on phi psi), PITCH open-loop \n [21] outer loop + inner loop PID (on phi psi), PITCH closed only on SAS \n: ');
end

if ctrl_sel == 1
    open_system('FCS_only_outer_loop')
elseif ctrl_sel == 2
    open_system('FCS_outer_loop_SAS')
elseif ctrl_sel == 3
    open_system('FCS_outer_loop_SAS_filter')
elseif ctrl_sel == 4
    open_system('FCS_only_outer_loop_yaw_OL')
elseif ctrl_sel == 5
    open_system('FCS_outer_loop_SAS_yaw_OL')  
elseif ctrl_sel == 6
    open_system('FCS_outer_loop_SAS_yaw_CL_on_SAS')
elseif ctrl_sel == 7
    open_system('FCS_only_outer_loop_PID_yaw_OL')    
elseif ctrl_sel == 8
    open_system('FCS_outer_loop_PID_SAS_yaw_OL') 
elseif ctrl_sel == 9
    open_system('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS')     
elseif ctrl_sel == 10
    open_system('FCS_only_outer_loop_pitch_OL')
elseif ctrl_sel == 11
    open_system('FCS_only_outer_loop_PID_pitch_OL')  
elseif ctrl_sel == 12
    open_system('FCS_only_outer_loop_pitch_OL_psi_CL') 
elseif ctrl_sel == 13
    open_system('FCS_only_outer_loop_PID_pitch_OL_psi_CL')     
end

%% load the SH90 P3 LTI model and set it in simulink

if ctrl_sel == 1
    set_param('FCS_only_outer_loop/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_only_outer_loop')
elseif ctrl_sel == 2
    set_param('FCS_outer_loop_SAS/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_outer_loop_SAS')
elseif ctrl_sel == 3
    set_param('FCS_outer_loop_SAS_filter/SH90_P3','A','A','B','B','C','C','D','D')
    % We use lowpass roll filters with cutoff at 40 rad/s to partially enforce the control bandwidth limiting to guard against neglected high-frequency rotor dynamics and measurement noise
    cut_off = 40;
    set_param('FCS_outer_loop_SAS_filter/Roll-off filter LAT','Numerator','cut_off','Denominator','[1 cut_off]')
    set_param('FCS_outer_loop_SAS_filter/Roll-off filter LON','Numerator','cut_off','Denominator','[1 cut_off]')
    set_param('FCS_outer_loop_SAS_filter/Roll-off filter PED','Numerator','cut_off','Denominator','[1 cut_off]')
    save_system('FCS_outer_loop_SAS_filter')
elseif ctrl_sel == 4
    set_param('FCS_only_outer_loop_yaw_OL/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_only_outer_loop_yaw_OL')
elseif ctrl_sel == 5
    set_param('FCS_outer_loop_SAS_yaw_OL/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_outer_loop_SAS_yaw_OL')
elseif ctrl_sel == 6
    set_param('FCS_outer_loop_SAS_yaw_CL_on_SAS/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_outer_loop_SAS_yaw_CL_on_SAS')  
elseif ctrl_sel == 7
    set_param('FCS_only_outer_loop_PID_yaw_OL/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_only_outer_loop_PID_yaw_OL')   
elseif ctrl_sel == 8
    set_param('FCS_outer_loop_PID_SAS_yaw_OL/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_outer_loop_PID_SAS_yaw_OL')  
elseif ctrl_sel == 9
    set_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS')       
elseif ctrl_sel == 10
    set_param('FCS_only_outer_loop_pitch_OL/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_only_outer_loop_pitch_OL')    
elseif ctrl_sel == 11
    set_param('FCS_only_outer_loop_PID_pitch_OL/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_only_outer_loop_PID_pitch_OL')  
elseif ctrl_sel == 12
    set_param('FCS_only_outer_loop_pitch_OL_psi_CL/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_only_outer_loop_pitch_OL_psi_CL')     
elseif ctrl_sel == 13
    set_param('FCS_only_outer_loop_PID_pitch_OL_psi_CL/SH90_P3','A','A','B','B','C','C','D','D')
    save_system('FCS_only_outer_loop_PID_pitch_OL_psi_CL')        
end



%% TUNING REQUIREMENTS DEFINITION

% define the tunable blocks: the 3 PI (all initialized with P=1, I=1)
if ctrl_sel == 1
    ST0 = slTuner('FCS_only_outer_loop',{'PI_phi','PI_theta','PI_r'});
elseif ctrl_sel == 2
    ST0 = slTuner('FCS_outer_loop_SAS',{'PI_phi','PI_theta','PI_r','SAS'});
elseif ctrl_sel == 3
    ST0 = slTuner('FCS_outer_loop_SAS_filter',{'PI_phi','PI_theta','PI_r','SAS'});
elseif ctrl_sel == 4
    ST0 = slTuner('FCS_only_outer_loop_yaw_OL',{'PI_phi','PI_theta'});
elseif ctrl_sel == 5
    ST0 = slTuner('FCS_outer_loop_SAS_yaw_OL',{'PI_phi','PI_theta','SAS'});    
elseif ctrl_sel == 6
    ST0 = slTuner('FCS_outer_loop_SAS_yaw_CL_on_SAS',{'PI_phi','PI_theta','SAS'});
elseif ctrl_sel == 7
    ST0 = slTuner('FCS_only_outer_loop_PID_yaw_OL',{'PID_phi','PID_theta'});   
elseif ctrl_sel == 8
    ST0 = slTuner('FCS_outer_loop_PID_SAS_yaw_OL',{'PID_phi','PID_theta','SAS'}); 
elseif ctrl_sel == 9
    ST0 = slTuner('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS',{'PID_phi','PID_theta','SAS'}); 
elseif ctrl_sel == 10
    ST0 = slTuner('FCS_only_outer_loop_pitch_OL',{'PI_phi','PI_r'});   
elseif ctrl_sel == 11
    ST0 = slTuner('FCS_only_outer_loop_PID_pitch_OL',{'PID_phi','PID_r'});  
elseif ctrl_sel == 12
    ST0 = slTuner('FCS_only_outer_loop_pitch_OL_psi_CL',{'PI_phi','PI_psi'});  
elseif ctrl_sel == 13
    ST0 = slTuner('FCS_only_outer_loop_PID_pitch_OL_psi_CL',{'PID_phi','PID_psi'});    
end

% Mark the I/O signals of interest for setpoint tracking, and identify the plant inputs and outputs (control and measurement signals) where the stability margin are measured

if ctrl_sel == 4 

    addPoint(ST0,{'theta_ref','phi_ref'})   % setpoint commands
    addPoint(ST0,{'theta','phi'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs
    
elseif ctrl_sel == 5 

    addPoint(ST0,{'theta_ref','phi_ref'})   % setpoint commands
    addPoint(ST0,{'theta','phi'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs   
    
elseif ctrl_sel == 6 

    addPoint(ST0,{'theta_ref','phi_ref'})   % setpoint commands
    addPoint(ST0,{'theta','phi'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs      
    
elseif ctrl_sel == 7 

    addPoint(ST0,{'theta_ref','phi_ref'})   % setpoint commands
    addPoint(ST0,{'theta','phi'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs      
    
elseif ctrl_sel == 8 

    addPoint(ST0,{'theta_ref','phi_ref'})   % setpoint commands
    addPoint(ST0,{'theta','phi'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs
    
elseif ctrl_sel == 9 

    addPoint(ST0,{'theta_ref','phi_ref'})   % setpoint commands
    addPoint(ST0,{'theta','phi'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs    

elseif ctrl_sel == 10 

    addPoint(ST0,{'phi_ref','r_ref'})   % setpoint commands
    addPoint(ST0,{'phi','r'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs     
    
elseif ctrl_sel == 11 

    addPoint(ST0,{'phi_ref','r_ref'})   % setpoint commands
    addPoint(ST0,{'phi','r'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs       
    
elseif ctrl_sel == 12 

    addPoint(ST0,{'phi_ref','psi_ref'})   % setpoint commands
    addPoint(ST0,{'phi','psi'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs     
    
    
elseif ctrl_sel == 13 

    addPoint(ST0,{'phi_ref','psi_ref'})   % setpoint commands
    addPoint(ST0,{'phi','psi'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs     
    
else
    
    addPoint(ST0,{'theta_ref','phi_ref','r_ref'})   % setpoint commands
    addPoint(ST0,{'theta','phi','r'})               % corresponding outputs
    addPoint(ST0,{'u','y'});                        % plant inputs and outputs

end

% Define the tuning requirements

% Track setpoint changes in theta, phi, and r with zero steady-state error, rise times of about 2 seconds, minimal overshoot, and minimal cross-coupling
% Tracking requirement: the response of theta, phi, r to step commands theta_ref, phi_ref, r_ref must resemble a decoupled first-order response with a one-second time constant
% Less than 20% mismatch with reference first order model 1/(s+1)

if ctrl_sel == 4 
    
    TrackReq = TuningGoal.StepResp({'theta_ref','phi_ref'},{'theta','phi'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5
    
elseif ctrl_sel == 5  
    
    TrackReq = TuningGoal.StepResp({'theta_ref','phi_ref'},{'theta','phi'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5
    
elseif ctrl_sel == 6  
    
    TrackReq = TuningGoal.StepResp({'theta_ref','phi_ref'},{'theta','phi'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5   
    
elseif ctrl_sel == 7  
    
    TrackReq = TuningGoal.StepResp({'theta_ref','phi_ref'},{'theta','phi'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5       

elseif ctrl_sel == 8 
    
    TrackReq = TuningGoal.StepResp({'theta_ref','phi_ref'},{'theta','phi'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5      

elseif ctrl_sel == 9 
    
    TrackReq = TuningGoal.StepResp({'theta_ref','phi_ref'},{'theta','phi'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5      
    
elseif ctrl_sel == 10  
    
    TrackReq = TuningGoal.StepResp({'phi_ref','r_ref'},{'phi','r'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5    
    
elseif ctrl_sel == 11  
    
    TrackReq = TuningGoal.StepResp({'phi_ref','r_ref'},{'phi','r'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5        
    
elseif ctrl_sel == 12  
    
    TrackReq = TuningGoal.StepResp({'phi_ref','psi_ref'},{'phi','psi'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5    
    
elseif ctrl_sel == 13  
    
    TrackReq = TuningGoal.StepResp({'phi_ref','psi_ref'},{'phi','psi'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5     
    
else
    
    TrackReq = TuningGoal.StepResp({'theta_ref','phi_ref','r_ref'},{'theta','phi','r'},1); %0.2
    TrackReq.RelGap = 0.2; %0.5

end

% Gain and phase margins at plant inputs and outputs: the multivariable gain and phase margins at the plant inputs u and plant outputs y must be at least 5 dB and 40 degrees
MarginReq1 = TuningGoal.Margins('u',5,40);
MarginReq2 = TuningGoal.Margins('y',5,40);

% Limit on fast dynamics: the magnitude of the closed-loop poles must not exceed 25 to prevent fast dynamics and jerky transients
PoleReq = TuningGoal.Poles();
PoleReq.MaxFrequency = 25;

req_sel = input('Select tuning requirements : \n [1] tracking req. \n [2] tracking and gain/phase margin req. \n [3] tracking, gain/phase margin, limit on fast dynamics req. \n: ');

if req_sel == 1
    % apply only tracking requirements for tuning
    Reqs = [TrackReq];
elseif req_sel == 2
    % apply tracking and gain/phase margin requirements for tuning
    Reqs = [TrackReq,MarginReq1,MarginReq2];
elseif req_sel == 3
    % apply all requirements for tuning
    Reqs = [TrackReq,MarginReq1,MarginReq2,PoleReq];
end

% TUNING
[ST1,fSoft,~,Info] = systune(ST0,Reqs);

%% plot results

if ctrl_sel == 4 

    % Plot the tuned responses to step commands in theta, phi:
    T1 = getIOTransfer(ST1,{'theta_ref','phi_ref'},{'theta','phi'});
    figure
    step(T1,5)
    grid on
    
elseif ctrl_sel == 5

    % Plot the tuned responses to step commands in theta, phi:
    T1 = getIOTransfer(ST1,{'theta_ref','phi_ref'},{'theta','phi'});
    figure
    step(T1,5)
    grid on   
    
elseif ctrl_sel == 6

    % Plot the tuned responses to step commands in theta, phi:
    T1 = getIOTransfer(ST1,{'theta_ref','phi_ref'},{'theta','phi'});
    figure
    step(T1,5)
    grid on     
    
elseif ctrl_sel == 7

    % Plot the tuned responses to step commands in theta, phi:
    T1 = getIOTransfer(ST1,{'theta_ref','phi_ref'},{'theta','phi'});
    figure
    step(T1,5)
    grid on        
 
elseif ctrl_sel == 8

    % Plot the tuned responses to step commands in theta, phi:
    T1 = getIOTransfer(ST1,{'theta_ref','phi_ref'},{'theta','phi'});
    figure
    step(T1,5)
    grid on     
    
elseif ctrl_sel == 9

    % Plot the tuned responses to step commands in theta, phi:
    T1 = getIOTransfer(ST1,{'theta_ref','phi_ref'},{'theta','phi'});
    figure
    step(T1,5)
    grid on      
    
elseif ctrl_sel == 10

    % Plot the tuned responses to step commands in theta, phi:
    T1 = getIOTransfer(ST1,{'phi_ref','r_ref'},{'phi','r'});
    figure
    step(T1,5)
    grid on   
 
elseif ctrl_sel == 11

    % Plot the tuned responses to step commands in theta, phi:
    T1 = getIOTransfer(ST1,{'phi_ref','r_ref'},{'phi','r'});
    figure
    step(T1,5)
    grid on     
    
elseif ctrl_sel == 12

    % Plot the tuned responses to step commands in theta, phi:
    T1 = getIOTransfer(ST1,{'phi_ref','psi_ref'},{'phi','psi'});
    figure
    step(T1,5)
    grid on     
    
elseif ctrl_sel == 13

    % Plot the tuned responses to step commands in theta, phi:
    T1 = getIOTransfer(ST1,{'phi_ref','psi_ref'},{'phi','psi'});
    figure
    step(T1,5)
    grid on        
    
else
    
    % Plot the tuned responses to step commands in theta, phi, r:
    T1 = getIOTransfer(ST1,{'theta_ref','phi_ref','r_ref'},{'theta','phi','r'});
    figure
    step(T1,5)
    grid on

end

% View the requirements matching validation

if req_sel == 1

    figure
    viewSpec(TrackReq,ST1,Info)
    title('Req 1: tracking, target response to step command')

elseif req_sel == 2
    
    figure
    viewSpec(TrackReq,ST1,Info)
    title('Req 1: tracking, target response to step command')    

    figure
    viewSpec(MarginReq1,ST1,Info)
    title('Req 2: stability margin on input')

    figure
    viewSpec(MarginReq2,ST1,Info)
    title('Req 3: stability margin on output')

elseif req_sel == 3

    figure
    viewSpec(TrackReq,ST1,Info)
    title('Req 1: tracking, target response to step command')    

    figure
    viewSpec(MarginReq1,ST1,Info)
    title('Req 2: stability margin on input')

    figure
    viewSpec(MarginReq2,ST1,Info)
    title('Req 3: stability margin on output')

    figure
    viewSpec(PoleReq,ST1,Info)
    title('Req 4: Limit on fast dynamics, closed-loop pole location')

end

% View the tuned values of the tunable blocks
showTunable(ST1)

% Write tuning values on blocks
writeBlockValue(ST1)

%% save tuning param and write it on simulink 

if ctrl_sel == 1 
    
    PI_theta_P = str2num(get_param('FCS_only_outer_loop/PI_theta','P'));
    PI_theta_I = str2num(get_param('FCS_only_outer_loop/PI_theta','I'));

    PI_phi_P = str2num(get_param('FCS_only_outer_loop/PI_phi','P'));
    PI_phi_I = str2num(get_param('FCS_only_outer_loop/PI_phi','I'));

    PI_r_P = str2num(get_param('FCS_only_outer_loop/PI_r','P'));
    PI_r_I = str2num(get_param('FCS_only_outer_loop/PI_r','I'));

elseif ctrl_sel == 2

    PI_theta_P = str2num(get_param('FCS_outer_loop_SAS/PI_theta','P'));
    PI_theta_I = str2num(get_param('FCS_outer_loop_SAS/PI_theta','I'));

    PI_phi_P = str2num(get_param('FCS_outer_loop_SAS/PI_phi','P'));
    PI_phi_I = str2num(get_param('FCS_outer_loop_SAS/PI_phi','I'));

    PI_r_P = str2num(get_param('FCS_outer_loop_SAS/PI_r','P'));
    PI_r_I = str2num(get_param('FCS_outer_loop_SAS/PI_r','I'));

    SAS_gain = str2num(get_param('FCS_outer_loop_SAS/SAS','Gain'));
    
elseif ctrl_sel == 3

    PI_theta_P = str2num(get_param('FCS_outer_loop_SAS_filter/PI_theta','P'));
    PI_theta_I = str2num(get_param('FCS_outer_loop_SAS_filter/PI_theta','I'));

    PI_phi_P = str2num(get_param('FCS_outer_loop_SAS_filter/PI_phi','P'));
    PI_phi_I = str2num(get_param('FCS_outer_loop_SAS_filter/PI_phi','I'));

    PI_r_P = str2num(get_param('FCS_outer_loop_SAS_filter/PI_r','P'));
    PI_r_I = str2num(get_param('FCS_outer_loop_SAS_filter/PI_r','I'));

    SAS_gain = str2num(get_param('FCS_outer_loop_SAS_filter/SAS','Gain'));    

elseif ctrl_sel == 4 
    
    PI_theta_P = str2num(get_param('FCS_only_outer_loop_yaw_OL/PI_theta','P'));
    PI_theta_I = str2num(get_param('FCS_only_outer_loop_yaw_OL/PI_theta','I'));

    PI_phi_P = str2num(get_param('FCS_only_outer_loop_yaw_OL/PI_phi','P'));
    PI_phi_I = str2num(get_param('FCS_only_outer_loop_yaw_OL/PI_phi','I')); 

elseif ctrl_sel == 5 
    
    PI_theta_P = str2num(get_param('FCS_outer_loop_SAS_yaw_OL/PI_theta','P'));
    PI_theta_I = str2num(get_param('FCS_outer_loop_SAS_yaw_OL/PI_theta','I'));

    PI_phi_P = str2num(get_param('FCS_outer_loop_SAS_yaw_OL/PI_phi','P'));
    PI_phi_I = str2num(get_param('FCS_outer_loop_SAS_yaw_OL/PI_phi','I')); 
    
    SAS_gain = str2num(get_param('FCS_outer_loop_SAS_yaw_OL/SAS','Gain'));   
    
elseif ctrl_sel == 6 
    
    PI_theta_P = str2num(get_param('FCS_outer_loop_SAS_yaw_CL_on_SAS/PI_theta','P'));
    PI_theta_I = str2num(get_param('FCS_outer_loop_SAS_yaw_CL_on_SAS/PI_theta','I'));

    PI_phi_P = str2num(get_param('FCS_outer_loop_SAS_yaw_CL_on_SAS/PI_phi','P'));
    PI_phi_I = str2num(get_param('FCS_outer_loop_SAS_yaw_CL_on_SAS/PI_phi','I')); 
    
    SAS_gain = str2num(get_param('FCS_outer_loop_SAS_yaw_CL_on_SAS/SAS','Gain')); 
    
elseif ctrl_sel == 7 
    
    PID_theta_P = str2num(get_param('FCS_only_outer_loop_PID_yaw_OL/PID_theta','P'));
    PID_theta_I = str2num(get_param('FCS_only_outer_loop_PID_yaw_OL/PID_theta','I'));
    PID_theta_D = str2num(get_param('FCS_only_outer_loop_PID_yaw_OL/PID_theta','D'));
    PID_theta_N = str2num(get_param('FCS_only_outer_loop_PID_yaw_OL/PID_theta','N'));

    PID_phi_P = str2num(get_param('FCS_only_outer_loop_PID_yaw_OL/PID_phi','P'));
    PID_phi_I = str2num(get_param('FCS_only_outer_loop_PID_yaw_OL/PID_phi','I')); 
    PID_phi_D = str2num(get_param('FCS_only_outer_loop_PID_yaw_OL/PID_phi','D')); 
    PID_phi_N = str2num(get_param('FCS_only_outer_loop_PID_yaw_OL/PID_phi','N'));
    
elseif ctrl_sel == 8 
    
    PID_theta_P = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_OL/PID_theta','P'));
    PID_theta_I = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_OL/PID_theta','I'));
    PID_theta_D = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_OL/PID_theta','D'));
    PID_theta_N = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_OL/PID_theta','N'));

    PID_phi_P = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_OL/PID_phi','P'));
    PID_phi_I = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_OL/PID_phi','I')); 
    PID_phi_D = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_OL/PID_phi','D'));   
    PID_phi_N = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_OL/PID_phi','N'));  
    
    SAS_gain = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_OL/SAS','Gain')); 
    
elseif ctrl_sel == 9 
    
    PID_theta_P = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS/PID_theta','P'));
    PID_theta_I = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS/PID_theta','I'));
    PID_theta_D = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS/PID_theta','D'));
    PID_theta_N = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS/PID_theta','N'));

    PID_phi_P = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS/PID_phi','P'));
    PID_phi_I = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS/PID_phi','I')); 
    PID_phi_D = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS/PID_phi','D'));   
    PID_phi_N = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS/PID_phi','N'));  
    
    SAS_gain = str2num(get_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS/SAS','Gain'));     

elseif ctrl_sel == 10 

    PI_phi_P = str2num(get_param('FCS_only_outer_loop_pitch_OL/PI_phi','P'));
    PI_phi_I = str2num(get_param('FCS_only_outer_loop_pitch_OL/PI_phi','I'));    
    
    PI_r_P = str2num(get_param('FCS_only_outer_loop_pitch_OL/PI_r','P'));
    PI_r_I = str2num(get_param('FCS_only_outer_loop_pitch_OL/PI_r','I')); 

elseif ctrl_sel == 11 

    PID_phi_P = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL/PID_phi','P'));
    PID_phi_I = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL/PID_phi','I'));    
    PID_phi_D = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL/PID_phi','D'));
    
    PID_r_P = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL/PID_r','P'));
    PID_r_I = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL/PID_r','I'));
    PID_r_D = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL/PID_r','D'));
    
elseif ctrl_sel == 12 

    PI_phi_P = str2num(get_param('FCS_only_outer_loop_pitch_OL_psi_CL/PI_phi','P'));
    PI_phi_I = str2num(get_param('FCS_only_outer_loop_pitch_OL_psi_CL/PI_phi','I'));    
    
    PI_psi_P = str2num(get_param('FCS_only_outer_loop_pitch_OL_psi_CL/PI_psi','P'));
    PI_psi_I = str2num(get_param('FCS_only_outer_loop_pitch_OL_psi_CL/PI_psi','I'));    
    
elseif ctrl_sel == 13 

    PID_phi_P = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL_psi_CL/PID_phi','P'));
    PID_phi_I = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL_psi_CL/PID_phi','I'));    
    PID_phi_D = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL_psi_CL/PID_phi','D')); 
    
    PID_psi_P = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL_psi_CL/PID_psi','P'));
    PID_psi_I = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL_psi_CL/PID_psi','I'));     
    PID_psi_D = str2num(get_param('FCS_only_outer_loop_PID_pitch_OL_psi_CL/PID_psi','D'));   
    
end

bdclose

if ctrl_sel == 1 
    
    open_system('FCS_only_outer_loop_tuned')
    set_param('FCS_only_outer_loop_tuned/PI_theta','P','PI_theta_P','I','PI_theta_I')
    set_param('FCS_only_outer_loop_tuned/PI_phi','P','PI_phi_P','I','PI_phi_I')
    set_param('FCS_only_outer_loop_tuned/PI_r','P','PI_r_P','I','PI_r_I')
    save_system('FCS_only_outer_loop_tuned')
    
elseif ctrl_sel == 2 

    open_system('FCS_outer_loop_SAS_tuned')
    set_param('FCS_outer_loop_SAS_tuned/PI_theta','P','PI_theta_P','I','PI_theta_I')
    set_param('FCS_outer_loop_SAS_tuned/PI_phi','P','PI_phi_P','I','PI_phi_I')
    set_param('FCS_outer_loop_SAS_tuned/PI_r','P','PI_r_P','I','PI_r_I')
    set_param('FCS_outer_loop_SAS_tuned/SAS','Gain','SAS_gain')
    save_system('FCS_outer_loop_SAS_tuned')

elseif ctrl_sel == 3 
    
    open_system('FCS_outer_loop_SAS_filter_tuned')
    set_param('FCS_outer_loop_SAS_filter_tuned/PI_theta','P','PI_theta_P','I','PI_theta_I')
    set_param('FCS_outer_loop_SAS_filter_tuned/PI_phi','P','PI_phi_P','I','PI_phi_I')
    set_param('FCS_outer_loop_SAS_filter_tuned/PI_r','P','PI_r_P','I','PI_r_I')
    set_param('FCS_outer_loop_SAS_filter_tuned/SAS','Gain','SAS_gain')
    save_system('FCS_outer_loop_SAS_filter_tuned')
    
elseif ctrl_sel == 4 
    
    open_system('FCS_only_outer_loop_yaw_OL_tuned')
    set_param('FCS_only_outer_loop_yaw_OL_tuned/PI_theta','P','PI_theta_P','I','PI_theta_I')
    set_param('FCS_only_outer_loop_yaw_OL_tuned/PI_phi','P','PI_phi_P','I','PI_phi_I')
    save_system('FCS_only_outer_loop_yaw_OL_tuned')   
    
 elseif ctrl_sel == 5 
    
    open_system('FCS_outer_loop_SAS_yaw_OL_tuned')
    set_param('FCS_outer_loop_SAS_yaw_OL_tuned/PI_theta','P','PI_theta_P','I','PI_theta_I')
    set_param('FCS_outer_loop_SAS_yaw_OL_tuned/PI_phi','P','PI_phi_P','I','PI_phi_I')
    set_param('FCS_outer_loop_SAS_yaw_OL_tuned/SAS','Gain','SAS_gain')
    save_system('FCS_outer_loop_SAS_yaw_OL_tuned')   
    
 elseif ctrl_sel == 6 
    
    open_system('FCS_outer_loop_SAS_yaw_CL_on_SAS_tuned')
    set_param('FCS_outer_loop_SAS_yaw_CL_on_SAS_tuned/PI_theta','P','PI_theta_P','I','PI_theta_I')
    set_param('FCS_outer_loop_SAS_yaw_CL_on_SAS_tuned/PI_phi','P','PI_phi_P','I','PI_phi_I')
    set_param('FCS_outer_loop_SAS_yaw_CL_on_SAS_tuned/SAS','Gain','SAS_gain')
    save_system('FCS_outer_loop_SAS_yaw_CL_on_SAS_tuned')      
    
 elseif ctrl_sel == 7 
    
    open_system('FCS_only_outer_loop_PID_yaw_OL_tuned')
    set_param('FCS_only_outer_loop_PID_yaw_OL_tuned/PID_theta','P','PID_theta_P','I','PID_theta_I','D','PID_theta_D','N','PID_theta_N')
    set_param('FCS_only_outer_loop_PID_yaw_OL_tuned/PID_phi','P','PID_phi_P','I','PID_phi_I','D','PID_phi_D','N','PID_phi_N')
    save_system('FCS_only_outer_loop_PID_yaw_OL_tuned')    
    
 elseif ctrl_sel == 8 
    
    open_system('FCS_outer_loop_PID_SAS_yaw_OL_tuned')
    set_param('FCS_outer_loop_PID_SAS_yaw_OL_tuned/PID_theta','P','PID_theta_P','I','PID_theta_I','D','PID_theta_D','N','PID_theta_N')
    set_param('FCS_outer_loop_PID_SAS_yaw_OL_tuned/PID_phi','P','PID_phi_P','I','PID_phi_I','D','PID_phi_D','N','PID_phi_N')
    set_param('FCS_outer_loop_PID_SAS_yaw_OL_tuned/SAS','Gain','SAS_gain')
    save_system('FCS_outer_loop_PID_SAS_yaw_OL_tuned')       
    
 elseif ctrl_sel == 9 
    
    open_system('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS_tuned')
    set_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS_tuned/PID_theta','P','PID_theta_P','I','PID_theta_I','D','PID_theta_D','N','PID_theta_N')
    set_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS_tuned/PID_phi','P','PID_phi_P','I','PID_phi_I','D','PID_phi_D','N','PID_phi_N')
    set_param('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS_tuned/SAS','Gain','SAS_gain')
    save_system('FCS_outer_loop_PID_SAS_yaw_CL_on_SAS_tuned')         
    
elseif ctrl_sel == 10 
    
    open_system('FCS_only_outer_loop_pitch_OL_tuned')
    set_param('FCS_only_outer_loop_pitch_OL_tuned/PI_r','P','PI_r_P','I','PI_r_I')
    set_param('FCS_only_outer_loop_pitch_OL_tuned/PI_phi','P','PI_phi_P','I','PI_phi_I')
    save_system('FCS_only_outer_loop_pitch_OL_tuned')      
    
elseif ctrl_sel == 11 
    
    open_system('FCS_only_outer_loop_PID_pitch_OL_tuned')
    set_param('FCS_only_outer_loop_PID_pitch_OL_tuned/PID_r','P','PID_r_P','I','PID_r_I','D','PID_r_D')
    set_param('FCS_only_outer_loop_PID_pitch_OL_tuned/PID_phi','P','PID_phi_P','I','PID_phi_I','D','PID_phi_D')
    save_system('FCS_only_outer_loop_PID_pitch_OL_tuned')    
    
elseif ctrl_sel == 12 
    
    open_system('FCS_only_outer_loop_pitch_OL_psi_CL_tuned')
    set_param('FCS_only_outer_loop_pitch_OL_psi_CL_tuned/PI_psi','P','PI_psi_P','I','PI_psi_I')
    set_param('FCS_only_outer_loop_pitch_OL_psi_CL_tuned/PI_phi','P','PI_phi_P','I','PI_phi_I')
    save_system('FCS_only_outer_loop_pitch_OL_psi_CL_tuned')    
    
elseif ctrl_sel == 13 
    
    open_system('FCS_only_outer_loop_PID_pitch_OL_psi_CL_tuned')
    set_param('FCS_only_outer_loop_PID_pitch_OL_psi_CL_tuned/PID_psi','P','PID_psi_P','I','PID_psi_I','D','PID_psi_D')
    set_param('FCS_only_outer_loop_PID_pitch_OL_psi_CL_tuned/PID_phi','P','PID_phi_P','I','PID_phi_I','D','PID_phi_D')
    save_system('FCS_only_outer_loop_PID_pitch_OL_psi_CL_tuned')       

end