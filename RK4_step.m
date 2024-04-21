function V_RC_next = RK4_step(V_RC, I_func, R, C, t_current,CurrentModifier)
    % rk4_step performs a single RK4 update for the RC pair voltage differential equation
    %
    % Inputs:
    % V_RC      - Current voltage across the RC pair
    % I_func    - Function handle for the current I(t)
    % R         - Resistance of the RC pair
    % C         - Capacitance of the RC pair
    % dt        - Timestep size
    % t_current - Current time
    %
    % Output:
    % V_RC_next - Updated voltage across the RC pair after one timestep
    global timestep
    dt = timestep;

    % Define the differential equation as a function handle
    dVdt = @(t, V) ((I_func(t) +CurrentModifier)- V / R) / C;
    
    % V_RC
    % I_func
    % R
    % C
    % t_current
    % CurrentModifier

    % Calculate the four slopes
    k1 = dt * dVdt(t_current, V_RC);
    k2 = dt * dVdt(t_current + dt/2, V_RC + k1/2);
    k3 = dt * dVdt(t_current + dt/2, V_RC + k2/2);
    k4 = dt * dVdt(t_current + dt, V_RC + k3);
    
    % Combine the slopes to compute the next voltage value
    V_RC_next = V_RC + (k1 + 2*k2 + 2*k3 + k4) / 6;
end
