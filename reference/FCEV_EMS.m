function [P_fc, P_batt, SOC_next, P_unmet, P_surplus] = ...
    FCEV_EMS(P_demand, SOC, P_fc_previous)
%#codegen
% All power values are DC-bus power in kW.
% Positive battery power = discharge.
% Negative battery power = charge.

%% Parameters
Ts = 0.1;
dt_h = Ts / 3600;

E_batt = 30;
eta_batt = 0.95;

SOC_min = 0.40;
SOC_max = 0.80;
SOC_ref = 0.60;

P_fc_max = 120;
P_fc_min = 10;
P_fc_ramp = 10;       % kW/s

P_batt_dis_max = 100;
P_batt_ch_max = 60;

tau_fc = 20;         % Fuel-cell smoothing time constant, s
K_soc = 200;         % SOC correction gain, kW per unit SOC

%% 1. Battery power available during this sample
P_dis_available = max(0, ...
    (SOC - SOC_min) * E_batt * eta_batt / dt_h);

P_ch_available = max(0, ...
    (SOC_max - SOC) * E_batt / (eta_batt * dt_h));

P_dis_limit = min(P_batt_dis_max, P_dis_available);
P_ch_limit = min(P_batt_ch_max, P_ch_available);

%% 2. Fuel-cell operating target
% SOC below reference increases requested fuel-cell power.
P_fc_target = max(P_demand, 0) + K_soc * (SOC_ref - SOC);

% Permit a simplified zero-power state.
if P_fc_target > 0
    P_fc_target = max(P_fc_target, P_fc_min);
end

P_fc_target = min(max(P_fc_target, 0), P_fc_max);

% Avoid requesting more FC power than load + charge acceptance.
% Ramp-down limits may still cause temporary surplus.
P_fc_target = min(P_fc_target, ...
    max(0, P_demand + P_ch_limit));

%% 3. Smooth response and apply ramp limit
alpha = Ts / (tau_fc + Ts);

P_fc_filtered = P_fc_previous + ...
    alpha * (P_fc_target - P_fc_previous);

max_change = P_fc_ramp * Ts;

P_fc = min(P_fc_filtered, P_fc_previous + max_change);
P_fc = max(P_fc, P_fc_previous - max_change);
P_fc = min(max(P_fc, 0), P_fc_max);

%% 4. Battery supplies or absorbs the residual
P_batt_requested = P_demand - P_fc;

P_batt = min(max(P_batt_requested, -P_ch_limit), ...
    P_dis_limit);

%% 5. Update stored battery energy
if P_batt >= 0
    SOC_next = SOC - ...
        P_batt * dt_h / (eta_batt * E_batt);
else
    SOC_next = SOC - ...
        P_batt * dt_h * eta_batt / E_batt;
end

% Numerical guard; available-power limits enforce the boundaries.
SOC_next = min(max(SOC_next, SOC_min), SOC_max);

%% 6. Account for residual power
P_balance = P_demand - P_fc - P_batt;

P_unmet = max(P_balance, 0);
P_surplus = max(-P_balance, 0);

end
