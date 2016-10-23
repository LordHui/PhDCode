%% experiment4.m - Produces data for Figure 7
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

function experiment4(K)

filename = ['experiment4_data' num2str(K)];

addpath('../');

% Set signal/algorithm parameters
N = 1024*4;
B = 1/256;

dpssSizeMin = N*B; % Initial value of dpssSize - should be less than N*B, but >=1
dpssSizeMax = 38;
dpssWidth = N*B/2;  % DPSS width
        
kkmax = 50; % Number of iterations per parameter setting to test
mmmax = 13;
M_max = N*B*K*mmmax;

randmat = randn(M_max,N);

sigOpts.N = N; sigOpts.B = B; sigOpts.K = K;
sigOpts.type = 'randtones';  % Random tones model
sigOpts.TPB = 50;  % 50 tones per band

cosampOpts.N = N;
cosampOpts.maxiter = 20;
cosampOpts.tol = 1e-3;
cosampOpts.modulator = generateModulator(N,B); % Precompute modulator matrix
cosampOpts.verbose = 0;
cosampOpts.detectAlg = 'blockOMP';
cosampOpts.debias = 1;

signalNorm = zeros(kkmax,1);
errorNorm = zeros(mmmax,kkmax);
iters = zeros(mmmax,kkmax);
timevec = zeros(mmmax,kkmax);

for kk=1:kkmax,
    
    [x supp] = generateSignal(sigOpts); % Generate signal
    signalNorm(kk) = norm(x); % Store signal norm
    
    for mm=1:mmmax,
        
        senseOpts.sampler = 'matrix';
        M = N*B*K*(mm+1)/2;
        senseOpts.subsamp = N/M;
        senseOpts.matrix = 1/sqrt(M)*randmat(1:M,:);
        
        y = sense(x,0,senseOpts); % Compute measurements
    
        cosampOpts.normBound = signalNorm(kk)+1e-13;
        
        %  DPSS KNOBS
        dpssSize = round(5.5*M/(N*B*K)+5);
        if(dpssSize > dpssSizeMax)
            dpssSize = dpssSizeMax;
        end
        if(dpssSize < dpssSizeMin)
            dpssSize = dpssSizeMin;
        end
        
        cosampOpts.PsiRecover = dpss(N,dpssWidth,dpssSize); % Precompute DPSS basis
                            
        tic
        [x_hat, supp_hat, iters] = dpssCosamp(y,senseOpts,K,B,cosampOpts);
        iters(mm,kk) = iters;
        errorNorm(mm,kk) = norm(x - x_hat);                           
        timevec(mm,kk) = toc;

        disp(['mm = ' num2str(mm) ' --- SNR: ' num2str(20*log10(signalNorm(kk)/errorNorm(mm,kk)))  ])
    end
    disp(['Elapsed time for iteration ' num2str(kk) ' : ' num2str(sum(timevec(:,kk))/60) ' min' ])
    save(filename,'signalNorm','errorNorm','iters','timevec');
end
