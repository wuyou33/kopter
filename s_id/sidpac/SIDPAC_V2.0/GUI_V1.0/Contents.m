% GUI_V1
%
% Files
%   dcmp_chk            - Computes model outputs for data compatibility analysis.
%   dcmp_cor            - Corrects data for estimated instrumentation errors.  
%   dcmp_est            - Estimate instrumentation error parameters using output-error.  
%   dcmp_gui            - M-file for dcmp_gui.fig.
%   dcmp_plot           - Makes data compatibility plots.
%   dcmp_psel           - Implements settings in dcmp.m for data compatibility analysis.  
%   dcmp_save           - Saves results for data compatibility analysis.
%   dcmp_setup_gui      - M-file for dcmp_setup_gui.fig
%   dcmp_setup_update   - Updates the run settings for data compatibility analysis.  
%   lr_est              - Estimate model parameters using linear regression.  
%   lr_gui              - M-file for lr_gui.fig.
%   lr_oplot            - Draws a plot of output data.
%   lr_rplot            - Draws a plot of regressor data.
%   lr_save             - Saves results for linear regression modeling.
%   mc_gui              - M-file for mc_gui.fig.
%   mc_plot             - Draws a plot of GUI plot data.
%   mc_var_plot         - Plots a specified column of the fdata matrix.
%   oe_chk              - Computes model outputs for output-error parameter estimation.
%   oe_cor              - Corrects output-error standard errors for colored residuals.
%   oe_est              - Estimate model parameters using output-error.  
%   oe_gui              - M-file for oe_gui.fig.
%   oe_lat_fill         - Fills in initial parameter values for lateral output-error.  
%   oe_lat_setup_gui    - M-file for oe_lat_setup_gui.fig.
%   oe_lat_setup_update - Updates settings for lateral output-error.  
%   oe_lon_fill         - Fills in initial parameter values for longitudinal output-error.  
%   oe_lon_setup_gui    - M-file for oe_lon_setup_gui.fig.
%   oe_lon_setup_update - Updates settings for longitudinal output-error.  
%   oe_plot             - Makes data compatibility plots.
%   oe_psel             - Implements settings for output-error parameter estimation.  
%   oe_save             - Saves results for stepwise regression modeling.
%   oe_setup_mod        - Modifies data in edit boxes for output-error model set-up.
%   oe_tlatss           - Time-domain lateral state-space model file.  
%   oe_tlonss           - Time-domain longitudinal state-space model.  
%   oe_tnlatss          - Time-domain lateral state-space model using non-dimensional parameters.  
%   oe_tnlonss          - Time-domain longitudinal state-space model using non-dimensional parameters.  
%   sid                 - System IDentification Programs for AirCraft (SIDPAC)
%   sid_assign          - Assigns plotted data to the fdata array.
%   sid_convert         - Converts units of the plotted data.  
%   sid_gui             - M-file for sid_gui.fig.
%   sid_leglab          - Assembles legend labels for plots.  
%   sid_mrk_chnl        - Mark or clear a specified channel label. 
%   sid_plot            - Draws a plot of GUI plot data.
%   sid_var_list        - Updates the fdata column description list.  
%   sid_var_plot        - Plots a specified column of the fdata matrix.
%   sid_ws_var_plot     - Plots a specifed workspace variable. 
%   swr_est             - Estimate model parameters using stepwise regression.  
%   swr_gui             - M-file for swr_gui.fig.
%   swr_save            - Saves results for stepwise regression modeling.
