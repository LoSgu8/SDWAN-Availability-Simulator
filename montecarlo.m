function [mean_value, std_value] = montecarlo(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters, n_sims, show_plots)
    
    %% Load parameters
    load('general_parameters.mat');
    
    %% Run the Monte Carlo simulation
    collected_availabilities = zeros(n_sims, 1);
    
    for running_idx = 1:n_sims
        disp(['Running simulation ' num2str(running_idx) '/' num2str(n_sims)])
        collected_availabilities(running_idx) = sdwan_single_simulation(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters, show_plots);
        disp(collected_availabilities(running_idx))
    end
    
    %% Compute model boundaries
    [lower_ss_availability, higher_ss_availability] = model_solution(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters);

    %% Show Box Plot
    figure
    boxplot(collected_availabilities)
    title("System Availability Box Plot (" + num2str(n_sims) + " runs)")
    ylabel("System Availability")
    grid on

    hold on
    % Add vertical lines at model boundaries
    yline(lower_ss_availability, 'r', 'LineWidth', 1.5);
    yline(higher_ss_availability, 'r', 'LineWidth', 1.5);
    hold off

    % Calculate new y-axis limits based on data and model boundaries
    lower_limit = min([collected_availabilities; lower_ss_availability]);
    upper_limit = max([collected_availabilities; higher_ss_availability]);
    
    % Set y-axis limits
    ylim([lower_limit, upper_limit]);
    
    %% Show availabiltiy distribution
    figure
    hist = histogram(collected_availabilities);
    title("System Availability Distribution (" + num2str(n_sims) + " runs)")

    % Get histogram data
    max_count = max(hist.Values);
    
    % Set y-axis ticks to integer values from 0 to max_count
    yticks(0:max_count);
    
    % Set y-axis limits
    ylim([0, max_count+0.5]);

    grid on

    hold on
    % Add vertical lines at model boundaries
    xline(lower_ss_availability, 'r', 'LineWidth', 1.5);
    xline(higher_ss_availability, 'r', 'LineWidth', 1.5);

    hold off

    %% Calculate the mean and standard deviation of the extracted variable
    mean_value = mean(collected_availabilities);
    std_value = std(collected_availabilities);
end