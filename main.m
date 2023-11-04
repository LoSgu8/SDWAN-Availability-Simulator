close all


%% PARAMETERS LOAD AND INITIALIZATIONS
% if single_run variable is set to 0 all the disp and plots are suppressed
% Set it to 0 for monte carlo simulation
single_run = 1;

if single_run
    disp('PARAMETER SECTION')
end

% Run the parameter generator 'generate_input_parameters.m'
run('generate_input_parameters.m');

% Load parameters generated by 'generate_input_parameters.m'
load('general_parameters.mat');
load('tunnel_parameters.mat');
load('controller2cpe_parameters.mat');
load('controller_parameter.mat');
load('cpe_parameter.mat');

nb_tunnels = size(tunnel_parameters, 2);

time_points = 0:sampling_time_interval:simulation_time;

%% TUNNELs
if single_run
    disp('TUNNEL SECTION')
end

tunnel_signals = false(nb_tunnels, numel(time_points));

for tunnel_idx=1:nb_tunnels
    if single_run
        disp([char(9) 'TUNNEL #' num2str(tunnel_idx)])
    end

    tunnel_signals(tunnel_idx,:) = compute_tunnel_signal(tunnel_idx, time_points, single_run);
end

%% C2CPEs
if single_run
    disp('C2CPE SECTION')
end

c2cpe_signals = false(2, numel(time_points));

if single_run
    figure
    sgtitle('C2CPE')
end

for j=1:2
    c2cpe_signals(j,:) = compute_status_signal( ...
        controller2cpe_parameters(j).initial_status, ...
        controller2cpe_parameters(j).fail_distribution, ...
        controller2cpe_parameters(j).fail_parameters, ...
        controller2cpe_parameters(j).rep_distribution, ...
        controller2cpe_parameters(j).rep_parameters, ...
        simulation_time, sampling_time_interval);
    if single_run
        subplot(2,1,j)
        plot(time_points, c2cpe_signals(j,:), 'r', 'LineWidth', 2)
        title(['C2CPE' j])
    end
end

%% CPEs
if single_run
    disp('CPE SECTION')
end

cpe_hw_signals = false(2, numel(time_points));
cpe_sw_signals = false(2, numel(time_points));
cpe_status_signals = false(2, numel(time_points));
for j=1:2
    % The hardware is completely independent from the software
    cpe_hw_signals(j,:) = compute_status_signal( ...
        cpe_parameters(j).hw.initial_status, ...
        cpe_parameters(j).hw.fail_distribution, ...
        cpe_parameters(j).hw.fail_parameters, ...
        cpe_parameters(j).hw.rep_distribution, ...
        cpe_parameters(j).hw.rep_parameters, ...
        simulation_time, sampling_time_interval);
    % but the software fail and repairs only in HW working conditions.
    % Once the hw is repaired the sw is considered in working state.

    % The behavior is studied only where the hw is functional (contiguous
    % block of ones)

    % Find the indices of the first and last elements of each contiguous block of ones
    diff_arr = diff([0 cpe_hw_signals(j,:) 0]);
    start_idx = find(diff_arr == 1);
    end_idx = find(diff_arr == -1) - 1;
    
    % Initialize the first element
    cpe_sw_signals(j,1) = cpe_parameters(j).sw.initial_status;
    
    % Display the intervals of contiguous ones
    for i = 1:length(start_idx)

        if start_idx(i) == 0
            initial_status = cpe_parameters(j).sw.initial_status;
        else
            initial_status = 1;
        end
        interval_length = ( end_idx(i) - start_idx(i) ) * sampling_time_interval;
        
        % disp(['Interval length ' num2str(interval_length) ]);

        cpe_sw_signals(j, start_idx(i):end_idx(i) ) = ...
            compute_status_signal( ...
                initial_status, ...
                cpe_parameters(j).sw.fail_distribution, ...
                cpe_parameters(j).sw.fail_parameters, ...
                cpe_parameters(j).sw.rep_distribution, ...
                cpe_parameters(j).sw.rep_parameters, ...
                interval_length, sampling_time_interval);
    end
    
    % Compute the CPE status as product of hw and sw modules
    cpe_status_signals(j,:) = cpe_hw_signals(j,:) & cpe_sw_signals(j,:);

    if single_run
        % Plot HW, SW and CPE behavior
        figure
        sgtitle(['CPE #' num2str(j)])
        % HW
        subplot(3, 1, 1)
        plot(time_points, cpe_hw_signals(j,:), 'r', 'LineWidth', 2);
        title(['CPE #' num2str(j) ' HW module status signal']);
        xlabel('Time (seconds)');
        ylabel('Component Status (1 for up, 0 for down)');
        % SW
        subplot(3, 1, 2)
        plot(time_points, cpe_sw_signals(j,:), 'r', 'LineWidth', 2);
        title(['CPE #' num2str(j) ' SW module status signal']);
        xlabel('Time (seconds)');
        ylabel('Component Status (1 for up, 0 for down)');
        % CPE
        subplot(3, 1, 3)
        plot(time_points, cpe_status_signals(j,:), 'r', 'LineWidth', 2);
        title(['CPE #' num2str(j) ' status signal']);
        xlabel('Time (seconds)');
        ylabel('Component Status (1 for up, 0 for down)');
    end

end

%% CONTROLLER
if single_run
    disp('CONTROLLER SECTION')
end

controller_hw_signals = false(1, numel(time_points));
controller_sw_signals = false(1, numel(time_points));
controller_status_signal = false(1, numel(time_points));

% The hardware is completely independent from the software
controller_hw_signals(1,:) = compute_status_signal( ...
    controller_parameters.hw.initial_status, ...
    controller_parameters.hw.fail_distribution, ...
    controller_parameters.hw.fail_parameters, ...
    controller_parameters.hw.rep_distribution, ...
    controller_parameters.hw.rep_parameters, ...
    simulation_time, sampling_time_interval);
% but the software fail and repairs only in HW working conditions.
% Once the hw is repaired the sw is considered in working state.

% The behavior is studied only where the hw is functional (contiguous
% block of ones)

% Find the indices of the first and last elements of each contiguous block of ones
diff_arr = diff([0 controller_hw_signals(1,:) 0]);
start_idx = find(diff_arr == 1);
end_idx = find(diff_arr == -1) - 1;

% Initialize the first element
controller_sw_signals(1,1) = controller_parameters.sw.initial_status;

% Display the intervals of contiguous ones
for i = 1:length(start_idx)

    if start_idx(i) == 0
        initial_status = controller_parameters.sw.initial_status;
    else
        initial_status = 1;
    end
    interval_length = ( end_idx(i) - start_idx(i) ) * sampling_time_interval;
    
    % disp(['Interval length ' num2str(interval_length) ]);

    controller_sw_signals(1, start_idx(i):end_idx(i) ) = ...
        compute_status_signal( ...
            initial_status, ...
            controller_parameters.sw.fail_distribution, ...
            controller_parameters.sw.fail_parameters, ...
            controller_parameters.sw.rep_distribution, ...
            controller_parameters.sw.rep_parameters, ...
            interval_length, sampling_time_interval);
end

% Compute the CPE status as product of hw and sw modules
controller_status_signal(1,:) = controller_hw_signals(1,:) & controller_sw_signals(1,:);

if single_run
    % Plot HW, SW and CPE behavior
    figure
    sgtitle('CONTROLLER')
    % HW
    subplot(3, 1, 1)
    plot(time_points, controller_hw_signals(1,:), 'r', 'LineWidth', 2);
    title('CONTROLLER HW module status signal');
    xlabel('Time (seconds)');
    ylabel('Component Status (1 for up, 0 for down)');
    % SW
    subplot(3, 1, 2)
    plot(time_points, controller_sw_signals(1,:), 'r', 'LineWidth', 2);
    title('CONTROLLER SW module status signal');
    xlabel('Time (seconds)');
    ylabel('Component Status (1 for up, 0 for down)');
    % CPE
    subplot(3, 1, 3)
    plot(time_points, controller_status_signal(1,:), 'r', 'LineWidth', 2);
    title('CONTROLLER status signal');
    xlabel('Time (seconds)');
    ylabel('Component Status (1 for up, 0 for down)');
end


%% SDWAN
if single_run
    disp('SDWAN SECTION')
end

sdwan_status = compute_sdwan_signal( ...
    cpe_status_signals, tunnel_signals, initial_active_tunnel, ...
    controller_status_signal, c2cpe_signals, time_points, single_run);

sdwan_availability = compute_availability_from_signal(sdwan_status);

if single_run
    disp(['The computed SDWAN availability is ' num2str(sdwan_availability)])
end


%% CLEAN FILES
if single_run
    disp('END SECTION')
end

delete controller2cpe_parameters.mat controller_parameter.mat ...
    cpe_parameter.mat general_parameters.mat tunnel_parameters.mat
