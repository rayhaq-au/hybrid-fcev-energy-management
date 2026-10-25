
%% HYBRID FCEV - DRIVING CYCLE
% Synthetic test cycle for initial model development
% This is NOT an official WLTP cycle.

%% Simulation time
Ts = 0.1;
t = (0:Ts:600)';  % 10 minutes, in seconds

%% Define speed targets
t_points = [0 20 50 100 150 200 250 ...
            300 350 400 450 500 550 600]';

v_points_kmh = [0 30 50 50 20 0 0 ...
                40 60 60 25 0 30 0]';

%% Interpolate speed
v_kmh = interp1(t_points, v_points_kmh, t, 'linear');

% Convert km/h to m/s
v = v_kmh / 3.6;

%% Calculate acceleration
a = gradient(v, Ts);

%% Create Simulink input signal
driveCycle = timeseries(v, t);

%% Plot driving cycle
figure('WindowStyle', 'normal');
theme(gcf, 'light');
plot(t, v_kmh, 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Vehicle speed (km/h)');
title('FCEV Synthetic Driving Cycle');
grid on;

%% Display basic information
fprintf('Driving cycle created successfully.\n');
fprintf('Duration: %.1f minutes\n', t(end)/60);
fprintf('Maximum speed: %.1f km/h\n', max(v_kmh));
fprintf('Number of samples: %d\n', length(t));
