function [ans, exitflag]=fit_modelMP(c,r)    
% % fit_modelMP %
%PURPOSE:   Fit the choice behavior to a reinforcement learning model using maximum
%           likelihood estimate
%AUTHORS:   Hongli Wang 01/16/2018
%
%INPUT ARGUMENTS
%   c:          choice vector
%   r:          outcome vector
%
%OUTPUT ARGUMENTS
%   qpar:       extracted parameters (alpha, delta0, delta1)

%%
maxit=1e6;
maxeval=1e6;
op=optimset('fminsearch');
op.MaxIter=maxit;
op.MaxFunEvals=maxeval;

% r=r(c~=0);  %remove miss trials
% c=c(c~=0);

%[qpar like exitflag output]=fminsearch(@model_MP, initpar, [], [c r]);
%try global search
% problem=createOptimProblem('fmincon','objective', @(x)model_MP(x, [c r]), 'x0', initpar, 'options', optimoptions(@fmincon, 'Algorithm', 'sqp', 'Display', 'off'));
% problem.lb=[0, -Inf, -Inf]; problem.ub=[1, Inf, Inf];
% gs = GlobalSearch;
% [qpar, f]=run(gs, problem);

%try another way
opt=optimset('GradObj', 'off',...
              'Hessian', 'off',...
              'LargeScale', 'off',...
              'MaxIter', 100000,...
              'MaxFunEvals', 1000000, ...
              'TolFun', 1.000e-006,...
              'TolX', 1.000e-006,...
              'FunValCheck','off',...
              'DerivativeCheck','off',...
              'Diagnostics','off',...
              'Algorithm','trust-region-reflective');
%starting values
initpar=[0.5, 0.5, 0.5];%alpha, delta1, delta0, beta
[xval,fval,flag,out,grad,hess] = fminunc( @(x)model_MP(x, [c r]), initpar, opt);
se = sqrt(diag(inv(hess)));
%in this way we can get an error bar, that's much better
ans = [xval' se];
% if exitflag==0
%     qpar=nan(size(qpar));   %did not converge to a solution, so return NaN
% end


end
