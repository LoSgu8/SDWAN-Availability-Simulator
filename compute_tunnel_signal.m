function tunnel_signal = compute_tunnel_signal(tunnel_idx, sampling_time_interval, simulation_time, tunnel_parameters, to_plot)
    
    time_points = 0:sampling_time_interval:simulation_time;

    component_names = fieldnames(tunnel_parameters(tunnel_idx));
    
    if to_plot
        % Plot a signal in each row, the tunnel signal occupies two rows
        num_cols = 1;
        num_rows = numel(component_names) + 2;
    
        figure;
    end
    
    % Initialize the tunnel status_signal (product of all its components)
    tunnel_signal = true(1, numel(time_points));

    % Loop through the components and plot their status signal
    for component_idx = 1:numel(component_names)
        component_name = component_names{component_idx};
        component_pars = tunnel_parameters(tunnel_idx).(component_name);
        
        if to_plot
            disp([char(9) component_name])
        end

        status_signal = compute_status_signal ( ...
            component_pars.initial_status, ...
            component_pars.fail_distribution, ...
            component_pars.fail_parameters, ...
            component_pars.rep_distribution, ...
            component_pars.rep_parameters, simulation_time, ...
            sampling_time_interval);
        
        % Update the tunnel signal (AND operation)
        tunnel_signal = tunnel_signal & status_signal;
        
        if to_plot
            % Plot the component signal
            subplot(num_rows, num_cols, component_idx)
            plot(time_points, status_signal, 'r', 'LineWidth', 2);
            title(append(component_name, ' status signal'));
            
            xlabel('Time (seconds)');
            ylabel('Component Status (1 for up, 0 for down)');
            grid on
        end
    end

    if to_plot
        % Plot the tunnel signal
        subplot(num_rows, num_cols, num_rows-1:num_rows)
        plot(time_points, tunnel_signal, 'r', 'LineWidth', 2);
        title(['TUNNEL #' num2str(tunnel_idx) ' status signal']);
        xlabel('Time (seconds)');
        ylabel('Component Status (1 for up, 0 for down)');
        grid on
    end

end