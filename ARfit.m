% This function fits the innovations variance and lag coefficients of an 
% AR(p) process to the observed power spectral density estimate of a time
% series.
%
% IN:
% p: order of AR process to consider
% f: frequency axis of time series
% pxx: power spectral density estimate
% fn: Nyquist frequency of time series
% S0 (optional): estimate of innovations variance
% rho0 (optional): estimate of lag coefficient(s)
%
% OUT:
% rho: optimal lag coefficient(s)
% S: optimal innovations variance

function [rho,S] = ARfit(p,f,pxx,fn,varargin)
    parser = inputParser;
    addRequired(parser,'p',@isscalar)
    addRequired(parser,'f',@isnumeric)
    addRequired(parser,'pxx',@isnumeric)
    addRequired(parser,'fn',@isscalar)
    addParameter(parser,'S0',rand,@isscalar)
    addParameter(parser,'rho0',[],@isnumeric)
    
    % parse inputs
    parse(parser,p,f,pxx,fn,varargin{:});
    p   = parser.Results.p;
    f   = parser.Results.f;
    pxx = parser.Results.pxx;
    fn  = parser.Results.fn;
    S0  = parser.Results.S0;
    rho0 = parser.Results.rho0;
    
    % make sure that given frequencies are of same length as psd of data
    assert(length(f) == length(pxx),'f and pxx must be same length')
    
    % generate initial guess for fminsearch
    if isempty(rho0)
        rho0 = 0.6*rand(p,1);
    else
        assert(length(rho0) == p,'rho0 must be of length equal to p')
    end

    % get functional form of AR(p) power spectral density
    psd = ARpsd(p);
    % generate objective function
    obj = @(x0) sum( abs( log(psd(x0(1),x0(2:end),f,fn))- log(pxx) ) );
    % look for optimal S, rho starting at S0, rho0
%     opt = optimset('MaxFunEvals',600*p,'MaxIter',600*p);
    nonlcon = @lagroots; 
    X = fmincon(obj,[S0;rho0],[],[],[],[],...
        [],[],nonlcon);
    S = X(1);
    rho = X(2:end);
    
    
    %% nonlinear constraint function for fmincon
    function [c,ceq] = lagroots(x)
        c = 1 - abs(roots([-x(2:end);1]));
        ceq = [];
    end

end