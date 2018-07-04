
% -- First Estimation of cost function --
CALL THE COST FUNCTION HERE
v = z - y; % z = Real signal, y = Estimated signal
J = sum(v.^2./z.^2);

% -- Newton-Raphson algorithm parameters --
Jcr = 0.1; % Convergence threshold on cost function [%]
Pcr = 1e-2; % Convergence threshold on inputs [%]
CCSAT = 0; % Convergence criteria satisfied [-]
iter = 0; % Initial number of iterations [-]
maxiter = 500; % Maximum number of iterations [-]
relax_factor = 0.8; % Relaxation factor on inputs updating
np = xxxx; % Number of Inputs
no = xxxx; % Number of Target outputs
ptb = as many as np; % Standard perturbations (%)

%% ***** START OPTIMIZATION LOOP *****

while iter < maxiter && ~CCSAT
  
  iter = iter + 1;
  fprintf(1,'Iteration # %d\n',iter)
  kP = 0;
  kJ = 0;
  % -- Output Sensitivities Estimation --
  dydp = CALL THE SENSITIVITY ESTIMATION FUNCTION HERE. ITS STRUCTURE COULD BE THE FOLLOWING:
  
% % % % %   % -- Output sensitivities determination using central finite difference --
% % % % %   for j = 1:length(p0)
% % % % %     % -- FORWARD PERTURBATION --
% % % % %     p1 = p0;
% % % % %     p1(j) = p0(j) + 0.5*dp(j);
% % % % %     % -- Calculate outputs --
% % % % %     y1 = CALL THE OUTPUT FUNCTION HERE
% % % % %     
% % % % %     % -- BACKWARD PERTURBATION --
% % % % %     p1(j) = p0(j) - 0.5*dp(j);
% % % % %     % -- Calculate outputs --
% % % % %     y0 = CALL THE OUTPUT FUNCTION HERE
% % % % %     
% % % % %     % -- Output Sensitivities to the j-th Input --
% % % % %     dydp(1,(j-1)*no+1:j*no) = (y1 - y0)/dp(j);
% % % % %   end

where p0 is the vector of parameters in input at the sensitivity calculation and dp are the perturbations
  
  % -- Cost Function gradient and Hessian matrix (Modified newton-Raphson) --
  grad = zeros(np,1);
  hess = zeros(np,np);
  v = Z - y;
  for k = 1:np
    idxcol = (k-1)*no;
    for j = 1:no
      Xj = Z(j)^2;
      grad(k) = grad(k) - 2/Xj*(v(j)*dydp(1,idxcol+j));
    end
  end
  for n = 1:np
    idxcol1 = (n-1)*no;
    for k = 1:np
      idxcol2 = (k-1)*no;
      for j = 1:no
        Xj = Z(j)^2;
        hess(n,k) = hess(n,k) + 2/Xj*(dydp(1,idxcol1+j)*dydp(1,idxcol2+j));
      end
    end
  end
  
  % -- Input Update --
  dp = -pinv(hess)*grad*relax_factor; % Use pseudo-inverse
  dp(isnan(dp)) = 0;  % Avoid eventual NaN elements
  
  % -- New Cost Estimation --
  CALL THE COST FUNCTION HERE
  
  % -- Check convergence criteria --
  if abs(Jnew - J)/J*100 < Jcr || (Jnew < 1e-6 && J < 1e-6)
    kJ = 1;
  end
  for i = 1:np
    if abs(dp(i)/Input_Data_old(i)) < Pcr
      kP = kP + 1;
    end
  end
  
  CCSAT = (kJ == 1) && (kP == np);
  
  J = Jnew;
  
end