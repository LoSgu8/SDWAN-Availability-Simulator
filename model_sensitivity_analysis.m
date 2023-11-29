function model_sensitivity_analysis(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters)

    sensitivity_factors = [0.9, 1.1]; % sensitivity factors

    [low_bound_baseline, higher_bound_baseline] = model_solution(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters, 0);

    % somehow bugged
    parameter_names = { ...
        'cpe_parameters(1).sw.fail_parameters.lambda', ...
        'cpe_parameters(2).sw.fail_parameters.lambda', ...
        'cpe_parameters(1).sw.rep_parameters.lambda', ...
        'cpe_parameters(2).sw.rep_parameters.lambda', ...
        'cpe_parameters(1).hw.fail_parameters.lambda', ...
        'cpe_parameters(2).hw.fail_parameters.lambda', ...
        'cpe_parameters(1).hw.rep_parameters.lambda', ...
        'cpe_parameters(2).hw.rep_parameters.lambda', ...
        'controller_parameters.sw.fail_parameters.lambda', ...
        'controller_parameters.sw.rep_parameters.lambda', ...
        'controller_parameters.hw.fail_parameters.lambda', ...
        'controller_parameters.hw.rep_parameters.lambda', ...
        'controller2cpe_parameters(1).fail_parameters.lambda', ...
        'controller2cpe_parameters(2).fail_parameters.lambda', ...
        'controller2cpe_parameters(1).rep_parameters.lambda', ...
        'controller2cpe_parameters(2).rep_parameters.lambda' ...
        };

    % Add tunnels to parameter_type
    num_tunnels = size(tunnel_parameters, 2);
    for tunnel_idx = 1 : num_tunnels
        component_names = fieldnames(tunnel_parameters(tunnel_idx));
        for component_idx = 1:numel(component_names)
            component_name = component_names{component_idx};
            parameter_names{end+1} = [ 'tunnel_parameters(' num2str(tunnel_idx) ').' component_name '.fail_parameters.lambda' ];
            parameter_names{end+1} = [ 'tunnel_parameters(' num2str(tunnel_idx) ').' component_name '.rep_parameters.lambda' ];
        end
    end
    
    num_params = numel(parameter_names);
    
    lower_availability_values = zeros(num_params, numel(sensitivity_factors));
    higher_availability_values = zeros(num_params, numel(sensitivity_factors));
    
    % Loop over parameters
    for par_idx = 1:num_params
        % Get the original value and parameter type
        original_value = eval(parameter_names{par_idx});
        
        % Loop over sensitivity factors
        for sens_idx = 1:numel(sensitivity_factors)
            % Modify parameter value
            eval([ parameter_names{par_idx} ' = original_value * sensitivity_factors(sens_idx);']);
            
            % Call the model_solution function
            [lower_availability_values(par_idx, sens_idx), higher_availability_values(par_idx, sens_idx)] = model_solution(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters, 0);
            
            % Reset parameter value
            eval([ parameter_names{par_idx} ' = original_value;']);
        end
    end


    %% Plot the Sensitivity Analysis results
    labels = erase(parameter_names, "_parameters");

    figure("Name", "Model Sensitivity Analysis Lower Bound")
    barh(1:num_params, lower_availability_values,'BaseValue', low_bound_baseline)
    title("Model Sensitivity Analysis Lower Bound")
    yticks(1:num_params)
    yticklabels(labels)
    lgd_lower = legend(arrayfun(@num2str, sensitivity_factors, 'UniformOutput', false));
    title(lgd_lower,'Sensitivity Factors')
    grid on

    figure("Name", "Model Sensitivity Analysis Higher Bound")
    barh(1:num_params, higher_availability_values,  'BaseValue', higher_bound_baseline)
    title("Model Sensitivity Analysis Higher Bound")
    yticks(1:num_params)
    yticklabels(labels)
    lgd_higher = legend(arrayfun(@num2str, sensitivity_factors, 'UniformOutput', false));
    title(lgd_higher,'Sensitivity Factors')
    grid on
end