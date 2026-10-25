%% Read logged signals
tt = out.P_demand.Time(:);

Pd = out.P_demand.Data(:);
Pf = out.P_fc.Data(:);
Pb = out.P_batt.Data(:);
soc = out.SOC.Data(:);
Pu = out.P_unmet.Data(:);
Ps = out.P_surplus.Data(:);

%% Verify signal alignment
assert(isequal(tt, out.P_fc.Time(:), ...
    out.P_batt.Time(:), out.SOC.Time(:), ...
    out.P_unmet.Time(:), out.P_surplus.Time(:)), ...
    'Logged signals have different time vectors.');

%% Power-balance check
% P_fc + P_batt + P_unmet = P_demand + P_surplus
balance_error = Pf + Pb + Pu - Pd - Ps;

%% Integrate discrete interval powers
% The final logged point has no following interval.
dt = diff(tt);
interval_energy = @(p) sum(p(1:end-1) .* dt) / 3600;

E_fc = interval_energy(Pf);
E_dis = interval_energy(max(Pb, 0));
E_ch = interval_energy(max(-Pb, 0));
E_unmet = interval_energy(Pu);
E_surplus = interval_energy(Ps);

distance_km = trapz(t, v) / 1000;

%% Numerical checks
assert(all(soc >= SOC_min - 1e-9 & ...
           soc <= SOC_max + 1e-9), ...
    'SOC exceeded its limits.');

assert(max(abs(balance_error)) < 1e-8, ...
    'Power accounting does not balance.');

assert(all(Pb <= P_batt_dis_max + 1e-8 & ...
           Pb >= -P_batt_ch_max - 1e-8), ...
    'Battery power exceeded its limits.');

assert(all(Pf >= -1e-8 & Pf <= P_fc_max + 1e-8), ...
    'Fuel-cell power exceeded its limits.');

assert(all(abs(diff(Pf)) <= fuel_cell_ramp * dt + 1e-8), ...
    'Fuel-cell ramp limit exceeded.');

% Independent battery-energy consistency check
dSOC = zeros(size(Pb));
discharging = Pb >= 0;

dSOC(discharging) = ...
    -Pb(discharging) / (eta_batt * E_batt);

dSOC(~discharging) = ...
    -Pb(~discharging) * eta_batt / E_batt;

soc_predicted = soc(1) + ...
    [0; cumsum(dSOC(1:end-1) .* dt / 3600)];

assert(max(abs(soc - soc_predicted)) < 1e-8, ...
    'Logged SOC is inconsistent with battery power.');

%% Figure
fig = figure('WindowStyle', 'normal', 'Position', [100 50 1200 900]);

% Always use a light figure theme
theme(fig, 'light');
fig.Color = 'white';

tiledlayout(4, 1, 'TileSpacing', 'compact');

nexttile
plot(t, v_kmh, 'Color', [0.15 0.15 0.15], ...
    'LineWidth', 1.5);
ylabel('Speed (km/h)');
title('Hybrid FCEV | 18-tonne Vehicle | Synthetic Cycle');
grid on

nexttile
% Stack only positive contributions.
% Show battery charging separately below zero.
area(tt, [Pf, max(Pb, 0)], 'LineStyle', 'none');
hold on
plot(tt, min(Pb, 0), 'Color', [0 0.45 0.74], ...
    'LineWidth', 1.3);
plot(tt, Pd, 'k', 'LineWidth', 1.1);
yline(0, ':', 'HandleVisibility', 'off');
hold off
ylabel('Power (kW)');
legend('Fuel cell', 'Battery discharge', ...
    'Battery charging', 'Demand', ...
    'Location', 'eastoutside');
grid on

nexttile
plot(tt, 100*soc, 'Color', [0.1 0.55 0.3], ...
    'LineWidth', 1.6);
hold on
yline(40, '--r', 'Minimum');
yline(80, '--r', 'Maximum');
yline(60, ':k', 'Reference');
hold off
ylim([35 85]);
ylabel('SOC (%)');
grid on

nexttile
plot(tt, Pu, 'r', 'LineWidth', 1.2);
hold on
plot(tt, Ps, 'm', 'LineWidth', 1.2);
hold off
ylabel('Residual (kW)');
xlabel('Time (s)');
legend('Unmet demand', 'Surplus', ...
    'Location', 'eastoutside');
grid on

%% Summary
fprintf('\n--- FCEV RESULTS ---\n');
fprintf('Distance:                  %.2f km\n', distance_km);
fprintf('Initial SOC:               %.2f %%\n', 100*soc(1));
fprintf('Final SOC:                 %.2f %%\n', 100*soc(end));
fprintf('Minimum SOC:               %.2f %%\n', 100*min(soc));
fprintf('Maximum SOC:               %.2f %%\n', 100*max(soc));
fprintf('Fuel-cell electrical energy: %.3f kWh\n', E_fc);
fprintf('Battery discharge, bus:    %.3f kWh\n', E_dis);
fprintf('Battery charge, bus:       %.3f kWh\n', E_ch);
fprintf('Unmet-demand energy:       %.6f kWh\n', E_unmet);
fprintf('Surplus energy:            %.6f kWh\n', E_surplus);
fprintf('Maximum balance error:     %.3e kW\n', ...
    max(abs(balance_error)));

exportgraphics(fig, fullfile('results', 'FCEV_results.png'), ...
    'Resolution', 300, ...
    'BackgroundColor', 'white');