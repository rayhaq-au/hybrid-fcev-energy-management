
%% FCEV - VEHICLE LONGITUDINAL DYNAMICS
% Run FCEV_setup.m and FCEV_drivecycle.m first.

%% 1. Calculate road-load forces
F_inertia = m .* a;

F_aero = 0.5 .* rho .* Cd .* A .* v.^2;

F_roll = Crr .* m .* g .* ones(size(v));

% Total force at the wheels
F_total = F_inertia + F_aero + F_roll;

%% 2. Calculate wheel power
% Force (N) * speed (m/s) = power (W)
P_wheel_kW = F_total .* v / 1000;

%% 3. Convert wheel power to electrical demand
P_demand_kW = zeros(size(P_wheel_kW));

% Positive power: traction
traction = P_wheel_kW >= 0;

P_demand_kW(traction) = ...
    P_wheel_kW(traction) / eta_motor;

% Negative power: potential regenerative braking
P_demand_kW(~traction) = ...
    P_wheel_kW(~traction) * eta_regen;

%% 4. Create time-series input for later use
demand_ts = timeseries(P_demand_kW, t);

%% 5. Plot road-load forces
figure('WindowStyle', 'normal');
theme(gcf, 'light');
plot(t, F_inertia, 'LineWidth', 1.1);
hold on;
plot(t, F_aero, 'LineWidth', 1.1);
plot(t, F_roll, 'LineWidth', 1.1);
plot(t, F_total, 'LineWidth', 1.3);
hold off;

xlabel('Time (s)');
ylabel('Force (N)');
title('Vehicle Longitudinal Forces');
legend('Inertia', 'Aerodynamic drag', ...
       'Rolling resistance', 'Total force');
grid on;

%% 6. Plot electrical power demand
figure('WindowStyle', 'normal');
theme(gcf, 'light');
plot(t, P_demand_kW, 'LineWidth', 1.3);
hold on;
yline(0, '--');
hold off;

xlabel('Time (s)');
ylabel('Electrical power (kW)');
title('Estimated FCEV Electrical Power Demand');
grid on;

%% 7. Display summary
fprintf('Vehicle dynamics calculated successfully.\n');
fprintf('Peak positive demand: %.2f kW\n', max(P_demand_kW));
fprintf('Peak negative demand: %.2f kW\n', min(P_demand_kW));
