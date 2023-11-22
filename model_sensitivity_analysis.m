
clear all
close all 

sensitivity_values = [0.5 1.5]; % sensitivity factors

run("generate_input_parameters.m");

%% BASE AVAILABILITIES
[base_lower_availability, base_higher_availability] = model_solution(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters);

%% SENSITIVITY ANALYSIS 
variables  = ['controller_parameters', 'controller2cpe_parameters', 'cpe_parameters', 'tunnel_parameters'];

for var_idx = 1:len(variables)
    variables(var_idx)
end