function sdwan_status = compute_sdwan_signal( ...
    cpe_status_signals, tunnel_signals, initial_active_tunnel,...
    controller_status_signal, c2cpe_signals, time_points, to_plot)

    load('general_parameters.mat');

    active_tunnel = ones(1,numel(time_points));
    active_tunnel(1,1) = initial_active_tunnel;
    
    sdwan_status = false(1, numel(time_points));

    nb_tunnels = size(tunnel_signals,1);
    
    t_idx = 1;

    while t_idx <= numel(time_points)
        % if at least one of the CPEs are down, the SDWAN system is not working
        if any(cpe_status_signals(:,t_idx) == 0)
            sdwan_status(1, t_idx) = 0;
        else
            % if the active tunnel is down, the SDWAN system is not working
            % but the CP, if available, take action to switch the tunnel
            % starting from the next time slot
            if tunnel_signals(active_tunnel(1,t_idx),t_idx) == 0
                is_C2CPE_available = all(c2cpe_signals(:,t_idx)==1);
                is_CP_available = is_C2CPE_available & controller_status_signal(t_idx);
                
    
                if is_CP_available
                    % find the first available tunnel starting from index 1
                    available_tunnel = 0;
                    tunnel_idx = 1;
                    while (not(available_tunnel) && tunnel_idx < nb_tunnels + 1)
                        if tunnel_signals(tunnel_idx, t_idx) == 1
                            available_tunnel = 1;
                        else
                            tunnel_idx = tunnel_idx + 1;
                        end
                    end
    
                    if available_tunnel % if available switch starting from next sample time
                        active_tunnel(1,t_idx+1:end) = tunnel_idx;
                        if to_plot
                            disp([ char(9) 'at t=' num2str(t_idx*sampling_time_interval) ' tunnel switched from ' num2str(active_tunnel(1,t_idx)) ' to ' num2str(active_tunnel(1,t_idx+1))])
                        end
                    else
                        if to_plot
                            disp([ char(9) 'at t=' num2str(t_idx*sampling_time_interval) ' no available tunnel has been found'])
                        end
                    end
                else
                    if to_plot
                        disp([ char(9) 'at t=' num2str(t_idx*sampling_time_interval) ' the tunnel cannot be switched due to control plane failure'])
                    end
                end
    
            else % if the tunnel is up, the SDWAN system is working properly
                sdwan_status(1, t_idx) = 1;
            end
        end
    
        t_idx = t_idx + 1;
    
    end


    %% PLOT PART
    if to_plot
        figure
        subplot(7,1,1)
        plot(time_points, tunnel_signals)
        title('Tunnels')
        xlabel('time [h]')
        ylim([-0.1, 1.1]);
        yticks([0, 1]);
        
        legend(cellstr(strcat('T', string(1:nb_tunnels))))
        
        subplot(7,1,2)
        plot(time_points, cpe_status_signals)
        legend('CPE1', 'CPE2')
        title('CPEs')
        xlabel('time [h]')
        ylim([-0.1, 1.1]);
        yticks([0, 1]);

        subplot(7,1,[3,4]);
        plot(time_points, sdwan_status, 'r', 'LineWidth', 2);
        title('SDWAN')
        xlabel('time [h]')
        ylim([-0.1, 1.1]);
        yticks([0, 1]);
        
        subplot(7,1,5)
        plot(time_points, active_tunnel)
        title('Active tunnel history')
        ylabel('# of the active tunnel')
        xlabel('time [h]')
        ylim([0, nb_tunnels+0.1]);
        yticks(0:nb_tunnels);
        
        
        subplot(7,1,6)
        plot(time_points, controller_status_signal)
        title('Controller')
        xlabel('time [h]')
        ylim([-0.1, 1.1]);
        yticks([0, 1]);
        
        subplot(7,1,7)
        plot(time_points, c2cpe_signals)
        legend('C2CPE1', 'C2CPE2')
        title('C2CPEs')
        xlabel('time [h]')
        ylim([-0.1, 1.1]);
        yticks([0, 1]);
    end

end