%% experiment1.m - Produces data for Figure 5
%
% Most recent change - 9/15/2011
%
% Copyright 2011, Mark Davenport, Michael Wakin
%
% This file is part of DPSS Approximation and Recovery Toolbox version 1.0.
%
%    DART is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    DART is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with DART.  If not, see <http://www.gnu.org/licenses/>.

function experiment1(filenumber)

filename = ['experiment1_data' num2str(filenumber)];

addpath('../');

% Set signal/algorithm parameters
N = 1024*4;
B = 1/256;
K = 5;

dpssSizeInit = N*B-8; % Initial value of dpssSize - should be less than N*B, but >=1
jjmax = 20; % Number of dpssSize values to try
kkmax = 50; % Number of iterations per parameter setting to test

senseOpts.sampler = 'matrix';
senseOpts.subsamp = 8;
M = N/8;
senseOpts.matrix = 1/sqrt(M)*randn(M,N);

sigOpts.N = N; sigOpts.B = B; sigOpts.K = K;
sigOpts.type = 'randtones';  % Random tones model
sigOpts.TPB = 50;  % 50 tones per band

cosampOpts.N = N;
cosampOpts.maxiter = 20;
cosampOpts.tol = 1e-3;
cosampOpts.modulator = generateModulator(N,B); % Precompute modulator matrix
cosampOpts.verbose = 0;
cosampOpts.debias = 1;

signalNorm = zeros(1,kkmax);
errorNorm1 = zeros(jjmax,kkmax);
errorNorm2 = zeros(jjmax,kkmax);
iters1 = zeros(jjmax,kkmax);
iters2 = zeros(jjmax,kkmax);
timevec = zeros(jjmax,kkmax);

for kk=1:kkmax,
    
    [x supp] = generateSignal(sigOpts); % Generate signal
    signalNorm(kk) = norm(x); % Store signal norm
    y = sense(x,0,senseOpts); % Compute measurements
    
    cosampOpts.normBound = signalNorm(kk)+1e-13;
    
    for jj=1:jjmax,
        %  DPSS KNOBS
        dpssSize = dpssSizeInit + 2*jj-4;  % Number of DPSS's
        dpssWidth = N*B/2;  % DPSS width
        cosampOpts.PsiRecover = dpss(N,dpssWidth,dpssSize); % Precompute DPSS basis
                     
        tic

        cosampOpts.detectAlg = 'blockOMP';
        [x_hat, ~, iters] = dpssCosamp(y,senseOpts,K,B,cosampOpts);
        errorNorm1(jj,kk) = norm(x - x_hat);
        iters1(jj,kk) = iters;
        
        cosampOpts.detectAlg = 'threshold';
        [x_hat, ~, iters] = dpssCosamp(y,senseOpts,K,B,cosampOpts);
        errorNorm2(jj,kk) = norm(x - x_hat);
        iters2(jj,kk) = iters;
        
        timevec(jj,kk) = toc;
        disp(['Iteration ' num2str(jj)])
    end
    disp(['Elapsed time for iteration ' num2str(kk) ' : ' num2str(sum(timevec(:,kk))/60) ' min'])
    save(filename,'signalNorm','errorNorm1','errorNorm2','iters1','iters2','timevec');
end