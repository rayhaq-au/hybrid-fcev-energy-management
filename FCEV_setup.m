
%% HYBRID FCEV PROJECT - SETUP
% Fuel Cell + Lithium-Ion Battery
% Initial parameters for a heavy-duty vehicle

clear;
clc;
close all;

%% 1. Vehicle parameters
m = 18000;          % Vehicle mass (kg)
g = 9.81;            % Gravity (m/s^2)
Cd = 0.60;           % Aerodynamic drag coefficient
A = 8.0;             % Frontal area (m^2)
Crr = 0.007;         % Rolling resistance coefficient
rho = 1.225;         % Air density (kg/m^3)
rw = 0.50;           % Wheel radius (m)

%% 2. Electric drivetrain
eta_motor = 0.92;    % Motor/inverter efficiency
eta_regen = 0.70;    % Regenerative braking efficiency

%% 3. Fuel-cell system
P_fc_max = 120;      % Maximum fuel-cell power (kW)
P_fc_min = 10;       % Minimum operating power (kW)
P_fc_initial = 60;   % Initial fuel-cell power (kW)
fuel_cell_ramp = 10; % Ramp-rate limit (kW/s)

%% 4. Lithium-ion battery
E_batt = 30;          % Battery capacity (kWh)
SOC_initial = 0.60;   % Initial state of charge
SOC_min = 0.40;       % Minimum SOC
SOC_max = 0.80;       % Maximum SOC

P_batt_dis_max = 100; % Maximum discharge power (kW)
P_batt_ch_max = 60;   % Maximum charge power (kW)
eta_batt = 0.95;      % Battery efficiency

%% 5. Simulation settings
Ts = 0.1;             % Sample time (seconds)

%% 6. Confirmation
disp('FCEV setup loaded successfully.');
disp(['Vehicle mass: ', num2str(m), ' kg']);
disp(['Battery capacity: ', num2str(E_batt), ' kWh']);
disp(['Fuel-cell maximum power: ', num2str(P_fc_max), ' kW']);
disp(['Initial battery SOC: ', num2str(SOC_initial*100), '%']);
