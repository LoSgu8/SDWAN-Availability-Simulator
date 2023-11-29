close all

%% Montecarlo parameters
n_sims = 1;
show_plots = 0;

%% Generate parameters
run('generate_input_parameters.m');

%% Start Montecarlo simulation
[mean_value, std_value] = montecarlo(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters, n_sims, show_plots);

%% Show Montecarlo results
disp("MONTECARLO RESULTS")

fprintf("\t Mean: %.15f\n", mean_value)
fprintf("\t STD: %.15f\n", std_value)

%% Show model results
[lower_ss_availability, higher_ss_availability] = model_solution(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters, 1);
disp("MODEL RESULTS")
fprintf("\t[%.15f,  %.15f]\n", lower_ss_availability, higher_ss_availability)

%% Perform sensitivity analysis on the model
model_sensitivity_analysis(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters);


%% Delete binary MATLAB files
delete("controller2cpe_parameters.mat");
delete("controller_parameter.mat")
delete("cpe_parameter.mat")
delete("general_parameters.mat")
delete("tunnel_parameters.mat")