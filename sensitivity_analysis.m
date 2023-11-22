clear all
close all

sensitivity_values = [0.5 1.5]; % sensitivity factors

parameter_names = ["cpe.sw.fail_lambda" "cpe.sw.rep_lambda"];

n_sims_per_input = 10;
show_plots = false;

%% Generate parameters
run("generate_input_parameters.m");

%% Get Base Availability
base_availability = montecarlo(tunnel_parameters, controller_parameters, ...
    controller2cpe_parameters, cpe_parameters, n_sims_per_input, ...
    show_plots);

fprintf('Base Availability resulted %.15f\n', base_availability)

%% Perform Sensitivity Analysis
availability_values = zeros(numel(parameter_names), numel(sensitivity_values));

% CPE
for factor_idx = 1:numel(sensitivity_values)
    for cpe_idx = 1:2
        fprintf("\t CPE#%d \n", cpe_idx)
        % SW module
        fprintf("\t\t SW FAIL \n")
        fprintf("\t\t\t old value = %f\n", cpe_parameters(cpe_idx).sw.fail_parameters.lambda)
        
        cpe_parameters(cpe_idx).sw.fail_parameters.lambda = cpe_parameters(cpe_idx).sw.fail_parameters.lambda*sensitivity_values(factor_idx);
        fprintf("\t\t\t new value = %f\n", cpe_parameters(cpe_idx).sw.fail_parameters.lambda)
        computed_availability = montecarlo(tunnel_parameters, controller_parameters, ...
            controller2cpe_parameters, cpe_parameters, n_sims_per_input, ...
            show_plots);
        fprintf("\t\t\t av = %f\n", computed_availability)
        availability_values(cpe_idx,factor_idx) = computed_availability;
        run("generate_input_parameters.m");
        fprintf("\t\t\t old value again = %f\n", cpe_parameters(cpe_idx).sw.fail_parameters.lambda)
        

    end
%     % sw fail
%     disp('cpe1 sw fail lmabda')
%     old_value = cpe_parameters(1).sw.fail_parameters.lambda;
%     cpe_parameters(1).sw.fail_parameters.lambda = old_value*sensitivity_values(factor_idx);
%     computed_availability = montecarlo(tunnel_parameters, controller_parameters, ...
%     controller2cpe_parameters, cpe_parameters, n_sims_per_input, ...
%     show_plots);
%     cpe_parameters(1).sw.fail_parameters.lambda = old_value;
%     availability_values(1,factor_idx) = computed_availability;
%     % sw rep
%     disp('cpe1 sw rep lmabda')
%     old_value = cpe_parameters(1).sw.rep_parameters.lambda;
%     cpe_parameters(1).sw.rep_parameters.lambda = old_value*sensitivity_values(factor_idx);
%     computed_availability = montecarlo(tunnel_parameters, controller_parameters, ...
%     controller2cpe_parameters, cpe_parameters, n_sims_per_input, ...
%     show_plots);
%     cpe_parameters(1).sw.rep_parameters.lambda = old_value;
%     availability_values(2,factor_idx) = computed_availability;
end

%% Plot the Sensitivity Analysis results
barh(availability_values','BaseValue', base_availability)
yticklabels(parameter_names)
legend(num2str(sensitivity_values'))
grid on

%% CLEAN FILES
delete controller2cpe_parameters.mat controller_parameter.mat ...
    cpe_parameter.mat general_parameters.mat tunnel_parameters.mat