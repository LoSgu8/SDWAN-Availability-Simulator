function [mean_value, std_value] = montecarlo(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters, n_sims, show_plots)
    
    %% Load parameters
    load('general_parameters.mat');
    
    %% Run the Monte Carlo simulation
    collected_mean_availabilities = zeros(n_sims, 1);
    time_averaged_availability = zeros(simulation_time/sampling_time_interval+1, 1);
    temp_availability = zeros(simulation_time/sampling_time_interval+1, 1);
    
    for running_idx = 1:n_sims
        disp(['Running simulation ' num2str(running_idx) '/' num2str(n_sims)])
        [collected_mean_availabilities(running_idx,1), temp_availability(:,1)] = sdwan_single_simulation(simulation_time, sampling_time_interval, tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters, initial_active_tunnel, show_plots);
        disp(collected_mean_availabilities(running_idx))
        time_averaged_availability = time_averaged_availability + temp_availability/n_sims;
    end
    
    if n_sims > 1

         %% Compute model boundaries
        [lower_ss_availability, higher_ss_availability] = model_solution(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters);

        %% Show mean avaialbility per time
        figure 
        time_points = 0:sampling_time_interval:simulation_time;
        plot(time_points, time_averaged_availability, 'b--o')

        grid on

        hold on
        % Add horizontal lines at representing SSA model computed boundaries
        yline(lower_ss_availability, 'b', 'LineWidth', 1.5);
        yline(higher_ss_availability, 'r', 'LineWidth', 1.5);

        legend('', 'Model SSA lower bound','Model SSA upper bound')
    
        hold off
    
        %% Show Box Plot
        figure
        boxplot(collected_mean_availabilities)
        title("System Availability Box Plot (" + num2str(n_sims) + " runs)")
        ylabel("System Availability")
        grid on
    
        hold on
        % Add horizontal lines representing SSA model boundaries
        yline(lower_ss_availability, 'b', 'LineWidth', 1.5);
        yline(higher_ss_availability, 'r', 'LineWidth', 1.5);
        hold off
    
        % Calculate new y-axis limits based on data and model boundaries
        lower_limit = min([collected_mean_availabilities; lower_ss_availability]);
        upper_limit = max([collected_mean_availabilities; higher_ss_availability]);
        
        % Set y-axis limits
        ylim([lower_limit, upper_limit]);

        legend('Model SSA lower bound','Model SSA upper bound')
        
        %% Show availabiltiy distribution
        figure
        hist = histogram(collected_mean_availabilities);
        title("System Availability Distribution (" + num2str(n_sims) + " runs)")
    
        % Get histogram data
        max_count = max(hist.Values);
        
        % Set y-axis ticks to integer values from 0 to max_count
        yticks(0:max_count);
        
        % Set y-axis limits
        ylim([0, max_count+0.5]);
    
        grid on
    
        hold on
        % Add vertical lines representing SSA model boundaries
        xline(lower_ss_availability, 'b', 'LineWidth', 1.5);
        xline(higher_ss_availability, 'r', 'LineWidth', 1.5);

        legend('', 'Model SSA lower bound','Model SSA upper bound')
    
        hold off
    end

    %% Calculate the mean and standard deviation of the extracted variable
    mean_value = mean(collected_mean_availabilities);
    std_value = std(collected_mean_availabilities);
    
end