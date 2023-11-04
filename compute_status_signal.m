function status_signal = compute_status_signal(initial_status, failure_distribution, ...
    failure_parameters, repair_distribution, repair_parameters, ...
    simulation_time, time_interval)

    % Initialize variables to record the signal    
    time_points = 0:time_interval:simulation_time;
    status_signal = false(1, numel(time_points)); % Initialize the signal to all 0s

    status_signal(1) = initial_status;
    
    t_idx=1;
    while t_idx < numel(time_points) + 1
        num_elements = 0;
        if (status_signal(t_idx) == 1) % Look for failures
            if strcmp(failure_distribution, 'exp')
                failure_time = exprnd(1/failure_parameters.lambda);
            else
                error('probability distribution not managed');
            end
            rounded_failure_time = round(failure_time / time_interval) * time_interval;
            num_elements = round(rounded_failure_time / time_interval);
            % disp([char(9) char(9) 'up from ' num2str(t_idx*time_interval) ' to ' num2str((t_idx*time_interval) + rounded_failure_time)]);
            % disp([char(9) char(9) 't_idx=' num2str(t_idx) ': Failure in ' num2str(failure_time) ' rounded to ' num2str(rounded_failure_time) ' corresponding to ' num2str(num_elements) ' array elements' ])
            
            if (t_idx + num_elements > size(time_points,2))
                % Extreme case where the failure time exceeds the
                % simulation time. The failure is not considered and
                % the component is up to the end of the simulation.
                status_signal(t_idx:end) = true(1, numel(status_signal) - t_idx + 1);
            else
                % Normal case, the component is considered working up
                % to the failure instant where it is set to 0
                status_signal(t_idx:t_idx + num_elements - 1) = true(1, num_elements);
                status_signal(t_idx + num_elements) = 0; 
            end

        else % Look for repair
            if strcmp(repair_distribution, 'exp')
                repair_time = exprnd(1/repair_parameters.lambda);
            else
                error('probability distribution not managed');
            end
            % Round the repair time to the nearest multiple of time_interval
            rounded_repair_time = round(repair_time / time_interval) * time_interval;
            

            % Determine the number of elements to update
            num_elements = round(rounded_repair_time / time_interval);

            %disp([char(9) char(9) 'down from ' num2str(t_idx*time_interval) ' to ' num2str((t_idx*time_interval) + rounded_repair_time)]);
            %disp([char(9) char(9) 't_idx=' num2str(t_idx) ': Repair in ' num2str(repair_time) ' rounded to ' num2str(rounded_repair_time) ' corresponding to ' num2str(num_elements) ' array elements' ])

            % Set to 0 the signal up to the rounded repair time
            if (t_idx + num_elements <= size(time_points,2))
                status_signal(t_idx:t_idx + num_elements - 1) = false(1, num_elements);
                status_signal(t_idx + num_elements) = 1;
            else
                status_signal(t_idx:end) = false(1, numel(status_signal) - t_idx + 1);
            end
        end

        t_idx = t_idx + num_elements;

    end

end