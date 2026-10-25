%% RUN HYBRID FCEV PROJECT
% Run from the MATLAB Command Window (base workspace).
% Setup clears workspace variables and closes existing figures.
cd(fileparts(mfilename('fullpath')));
FCEV_setup
FCEV_drivecycle
FCEV_vehicle_dynamics
if ~exist('results', 'dir')
    mkdir('results');
end
load_system(fullfile(pwd, 'FCEV_Hybrid_Powertrain_EMS.slx'));
out = sim('FCEV_Hybrid_Powertrain_EMS');
FCEV_results
save(fullfile('results', 'FCEV_results.mat'), 'out');
fprintf('Results saved in: %s\n', fullfile(pwd, 'results'));
