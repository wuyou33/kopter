% SIDPAC
%
% Files
%   ab3            - Numerical integration using 3rd order Adams-Bashforth.
%   ab_cor         - Corrects angle of attack and sideslip angle measurements to the vehicle c.g. 
%   accel_cor      - Corrects translational accelerometer measurements to the vehicle c.g.  
%   adamb3         - Version of ab3.m used for parameter estimation.
%   adamb3a        - Version of ab3.m used for parameter estimation, with acceleration outputs.
%   airchk         - Computes reconstructed air data for data compatibility analysis.
%   aireom         - Implements kinematic equations for translational motion.  
%   atm            - Provides properties of the 1976 standard atmosphere.  
%   axesrot        - Finds vector components in a rotated coordinate system.
%   bodecmp        - Compares Bode plots for general transfer function models. 
%   bodeplt        - Draws Bode plots.
%   buzz           - Adds white noise to time series.
%   chirpz         - Chirp z-transform, computed using the definition. 
%   chkplot        - Plots segments of wind tunnel data.  
%   cmpplt         - Makes comparison plots for model and measured data.  
%   cmpsigs        - Signal comparision excluding biases and scaling.
%   cnvrg          - Checks convergence criteria.  
%   colnse         - Generates colored noise.  
%   colores        - Calculates parameter covariance for colored residuals from output-error.
%   comfun         - Computes the value of ordinary polynomial functions.  
%   compcost       - Computes the output-error cost function.  
%   compcrb        - Computes Cramér-Rao bounds and the information matrix.  
%   compcss        - Assembles constants for dimensional state-space models.  
%   compfc         - Computes non-dimensional force coefficients.
%   compfmc        - Computes non-dimensional force and moment coefficients.  
%   compmc         - Computes non-dimensional moment coefficients.
%   compmcrp       - Computes non-dimensional moment coefficients about a specified reference point.
%   compzs         - Constructs smoothed time series from Fourier sine series coefficients and the Wiener filter.  
%   compzsd        - Computes smoothed numerical time derivatives using Fourier analysis and the Wiener filter. 
%   confin         - Computes 95 percent confidence intervals for linear regression model outputs.
%   corrcoefs      - Calculates the correlation coefficient matrix.
%   correl         - Computes the estimated parameter correlation matrix.  
%   corx           - Computes the normalized regressor correlation matrix.  
%   csmep          - Computes smoothed endpoints for a noisy time series using a local cubic least squares fit.  
%   cubic_dtrend   - Computes a cubic detrend function for a noisy time series.  
%   cutftd         - Plots flight test data and implements manual data cutting for flight test maneuvers.  
%   cvec           - Makes any input vector into a column vector.  
%   czts           - Chirp z-transform.  
%   damps          - Computes and displays modal damping and natural frequencies.
%   daub4          - Implements a fourth-order Daubechies wavelet transform filter.  
%   daub6          - Implements a sixth-order Daubechies wavelet transform filter.  
%   dband          - Applies a dead band to a time series.  
%   dcmp           - Computes reconstructed outputs for data compatibility analysis.
%   dcmp_eqs       - Implements aircraft kinematic equations for data compatibility analysis.  
%   dcmp_psel      - Implements settings in dcmp.m for data compatibility analysis.  
%   derfilt        - Derivative filter.  
%   deriv          - Smoothed numerical differentiation.  
%   dft            - Computes the discrete Fourier transform using the definition (i.e., no FFT).
%   dimx           - Dimensionalizes normalized independent variables.  
%   dlsims         - Numerically solves discrete-time linear difference equations.  
%   dox            - Generates experiment designs for response surface modeling.  
%   edit_data      - Edits wind tunnel data points.  
%   estlag         - Estimates pure time delay between two time series.
%   estrr          - Computes an estimate of the noise covariance matrix.  
%   estsvv         - Computes an estimate of the measurement noise spectral density matrix.  
%   fac            - Computes factorials.  
%   fcn_header     - Standard header template for SIDPAC functions.
%   fdata2fds      - Converts from standard fdata matrix format to standard fds data structure format.  
%   fdfilt         - Implements filtering in the frequency domain.  
%   fdoe           - Output-error parameter estimation in the frequency domain.
%   fds_init       - Initializes a standard data structure.  
%   ficor          - Computes high-accuracy corrections for the finite Fourier integral.  
%   find_val       - Finds the number of distinct values of an independent variable in wind tunnel data.  
%   fint           - High-accuracy finite Fourier integral for arbitrary frequencies.
%   fixdrop        - Interpolates to repair data dropouts, using a graphical interface.  
%   flatss         - Frequency-domain lateral state-space model file.  
%   flattf         - Frequency-domain lateral transfer function model file.  
%   flonss         - Frequency-domain longitudinal state-space model file.  
%   flontf         - Frequency-domain longitudinal transfer function model file.  
%   fnlatss        - Frequency-domain lateral state-space model file using non-dimensional parameters.  
%   fnlonss        - Frequency-domain longitudinal state-space model file using non-dimensional parameters.  
%   freqcut        - Finds the cut-off frequency for a Wiener filter.  
%   fresp          - Computes the frequency response from measured input-output data.  
%   fsinser        - Computes Fourier sine series coefficients.  
%   ftf            - Frequency-domain transfer function model file.  
%   gauss_wgt      - Computes values of a Gaussian probability density function.  
%   gold           - Finds the minimum of a function using a golden section search.  
%   grad           - Finds the gradient of a vector function using finite differences.  
%   gsorth         - Generates orthogonal regressors using Gram Schmidt orthogonalization.  
%   hsmoo          - Implements low-pass filtering using fixed-weight smoothing.  
%   int1           - One-dimensional linear interpolation.  
%   int2           - Two-dimensional linear interpolation.  
%   int3           - Three-dimensional linear interpolation.  
%   integ          - Finds the time integral of a time series using the Euler method.  
%   intsinc        - Interpolates band-limited time series data, using the sampling theorem.  
%   lat_plot       - Makes plots of lateral variables.
%   lesq           - Least squares linear regression.  
%   lnze           - Generates local linear dynamic system models using finite differences.  
%   loadasc        - Loads ASCII data into the MATLAB® workspace in linear regression format.  
%   loadflat       - Loads ASCII data into the MATLAB® workspace.  
%   loest          - Computes parameter estimates in a low-order equivalent system model structure. 
%   lon_plot       - Makes plots of longitudinal variables.
%   lsims          - Numerically integrates state-space model differential equations.  
%   lsmoo          - Smoothes noisy measured data using a local smoother.  
%   m_colores      - Vectorized version of colores.m.
%   massprop       - Assembles aircraft mass and moment of inertia data.  
%   mfilt          - Implements the manually-selected cut-off filter for smoo.m.  
%   milstd         - Computes and plots longitudinal flying qualities level prediction, according to MIL-STD 1797A.  
%   misvd          - Computes robust matrix inverse using singular value decomposition.  
%   mkfswp         - Creates linear or log frequency sweep inputs.
%   mkmcos         - Creates multiple component sinusoidal inputs using cosine functions.  
%   mkmsswp        - Creates orthogonal multi-sine inputs with minimized relative peak factor.
%   mkrdm          - Creates random white or colored noise inputs.
%   mkrdmss        - Creates inputs using a sum of sine functions with random amplitudes and frequencies.  
%   mksqw          - Creates multi-step square wave inputs.  
%   mksswp         - Creates Schroeder sweep inputs with flat power spectra.  
%   mnr            - Computes the cost gradient and information matrix for parameter optimization.  
%   model_disp     - Displays parameter estimation results.  
%   model_err      - Displays noise level bounds.  
%   model_eval     - Makes plots and computes diagnostics for evaluating linear regression models.  
%   model_plots    - Makes plots for evaluating linear regression models.  
%   model_results  - Exports linear regression modeling results to a file.
%   mof            - Identifies multivariate polynomial models from measured data using orthogonal functions.  
%   mordchk        - Makes model term order checks in offit.m and mof.m.  
%   nderiv         - Generalized version of deriv.m, with selectable neighboring points and model order.  
%   nldyn          - Solves the nonlinear aircraft equations of motion for output-error parameter estimation.  
%   nldyn_eqs      - Implements nonlinear aircraft equations of motion for output-error parameter estimation.  
%   nldyn_psel     - Implements settings in nldyn.m for output-error parameter estimation.  
%   normx          - Normalizes independent variables.  
%   ocf            - Converts a transfer function model to a state-space model in observer canonical form.  
%   oe             - Output-error parameter estimation in the time domain.  
%   offit          - Identifies multivariate polynomial models from measured data using orthogonal functions.  
%   ordchk         - Makes independent variable order checks in offit.m and mof.m.  
%   peakfactor     - Computes the peak factor of a time series.  
%   pf_cost        - Computes the cost for peak factor minimization of multi-sine inputs.  
%   pfstat         - Computes the partial F statistic for hypothesis testing in model structure determination.  
%   phasor         - Computes magnitude and phase angle of complex numbers.  
%   pickp          - Implements manual selection of points on a line plot.  
%   plot3d         - Makes three-dimensional plots using data arranged for linear regression.  
%   plotmesh       - Makes three-dimensional mesh plots for polynomial models.  
%   plotpest       - Plots parameter estimates and 95 percent confidence intervals.  
%   plotsurf       - Makes three-dimensional surface plots for polynomial models.  
%   polygen        - Generates specified multivariate polynomials.  
%   press          - Computes predicted sum of squares metric.  
%   prob_plot      - Makes a diagnostic cumulative probability plot.  
%   ptrans         - Translates parameters for longitudinal LOES models.
%   pwrband        - Finds the frequency band containing a given fraction of the power in a time series.  
%   r_colores      - Parameter covariance for colored residuals from linear regression.
%   ratelim        - Implements rate limits.  
%   regcor         - Computes and displays pair-wise regressor correlations.  
%   reggen         - Generates all possible multivariate polynomial regressors, within specified order limits.  
%   regsel         - Removes a selected regressor from a regressor matrix.  
%   repchk         - Makes checks in offit.m and mof.m to avoid repeated orthogonal functions.  
%   rft            - Computes the recursive discrete Fourier transform of a time series.  
%   rk2            - Second-order Runge-Kutta numerical integration.  
%   rk4            - Fourth-order Runge-Kutta numerical integration.  
%   rlesq          - Recursive least squares linear regression.  
%   rms            - Computes the root-mean-square value of the elements of a vector.  
%   rotchk         - Computes reconstructed Euler angles for data compatibiliy analysis.
%   roteom         - Implements kinematic equations for rotational motion.  
%   roundd         - Rounds to ndec decimal places.  
%   rrest          - Computes a noise covariance matrix estimate based on smoothed time series.
%   rtpid          - Real-time parameter estimation using least squares in the frequency domain.
%   runk2          - Version of rk2.m used for parameter estimation.  
%   runk2a         - Version of rk2.m used for parameter estimation, with acceleration outputs.
%   runk4          - Version of rk4.m used for parameter estimation.  
%   runk4a         - Version of rk4.m used for parameter estimation, with acceleration outputs. 
%   sclx           - Scales regressors to the interval [-1,1].  
%   script_header  - Standard header template for SIDPAC scripts.
%   senchk         - Checks output sensitivities for correlation.  
%   senest         - Computes sensitivity estimates using finite differences.  
%   sens_cor       - Applies instrumentation error corrections to measured data.  
%   sid_plot_lines - Defines standard SIDPAC plot line characteristics.
%   sid_plot_setup - Standard SIDPAC plot set-up.  
%   sidbook_plot   - Makes standard plots for the SIDPAC textbook.  
%   simplex        - Simplex method for parameter optimization without cost gradients.  
%   sincs          - Computes the value of sin(x)/x.  
%   slesq          - Sequential least squares linear regression.  
%   smep           - Computes smoothed endpoints for a measured time series.  
%   smoo           - Optimal global Fourier smoothing. 
%   solve          - Solves a set of nonlinear algebraic equations using modified Newton-Raphson.  
%   spect          - Computes power spectral density estimates for measured time series.  
%   splgen         - Generates spline functions.  
%   sqw_psd        - Analytically computes the power spectra of square waves.  
%   sqw_tap        - Finds square wave time-amplitude points.  
%   startup        - Set-up for SIDPAC.  
%   stk_data       - Arranges wind tunnel data for least squares linear regression.  
%   swr            - Stepwise regression.
%   szep           - Fixes smoothed endpoints of time series to zero.  
%   tau_cost       - Computes the equation-error cost for estimating equivalent time delay.  
%   tfest          - Transfer function parameter estimation using equation-error in the frequency domain.
%   tfregr         - Assembles data for transfer function modeling using equation-error in the frequency domain.  
%   tfsim          - Computes responses from transfer function models.  
%   tlatss         - Time-domain lateral state-space model file.  
%   tlatsssl       - Simulink equivalent of tlatss.m
%   tlattf         - Time-domain lateral transfer function model file.  
%   tlonss         - Time-domain longitudinal state-space model file.  
%   tlonsssl       - Simulink equivalent of tlonss.m
%   tlontf         - Time-domain longitudinal transfer function model file.  
%   tnlatss        - Time-domain lateral state-space model file using non-dimensional parameters.  
%   tnlonss        - Time-domain longitudinal state-space model file using non-dimensional parameters.  
%   tshift         - Estimate relative time shift between two time series, using time-domain cross correlation.  
%   ulag           - Applies a selected time shift to a time series.  
%   unit           - Finds the unit vector for a given vector.  
%   unstk_data     - Arranges wind tunnel data for 3D plotting.  
%   wnfilt         - Implements the Wiener filter for smoo.m.  
%   wt             - Implements selected discrete wavelet transform filters and inverses.  
%   x_values       - Finds the distinct values in each column of a data matrix.  
%   xcorrs         - Cross-correlation estimate for time series.
%   xsmep          - Local endpoint smoothing, excluding the endpoint data.  
%   zep            - Fixes endpoints of a time series to zero.  
