function [lower_ss_availability, higher_ss_availability] = model_solution(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters)
    fprintf("MODEL SOLUTION\n");  
    %% TUNNEL
    nb_tunnels = size(tunnel_parameters, 2);
    
    tunnel_availabilities = ones(nb_tunnels,1);
    fprintf("\tFound %d tunnels\n", nb_tunnels);
    for tunnel_idx=1:nb_tunnels
        fprintf("\t\tTunnel %d: ", tunnel_idx); 
        component_names = fieldnames(tunnel_parameters(tunnel_idx));
        
        for component_idx = 1:numel(component_names)
            component_name = component_names{component_idx};
            fprintf("\t\t%s",component_name)
            component_pars = tunnel_parameters(tunnel_idx).(component_name);
            if strcmp(component_pars.fail_distribution, 'exp') && strcmp(component_pars.rep_distribution, 'exp')
                component_availability = component_pars.rep_parameters.lambda / ( component_pars.fail_parameters.lambda + component_pars.rep_parameters.lambda);
                tunnel_availabilities(tunnel_idx) = tunnel_availabilities(tunnel_idx) * component_availability;
            else
                error("probability distribution not known");
            end
        end
        fprintf(" with availability of %f\n", tunnel_availabilities(tunnel_idx)); 
    end
    
    availability_tunnel_system = 1 - prod(1-tunnel_availabilities);
    fprintf("\tTunnels steady state availability: %f\n", availability_tunnel_system);
    
    
    %% CPEs
    availability_CPEs = ones(2,1);
    for j=1:2
        if (strcmp(cpe_parameters(j).hw.fail_distribution, 'exp') && strcmp(cpe_parameters(j).hw.rep_distribution, 'exp') && strcmp(cpe_parameters(j).sw.fail_distribution, 'exp') && strcmp(cpe_parameters(j).sw.rep_distribution, 'exp'))
            lambda_hw = cpe_parameters(j).hw.fail_parameters.lambda;
            mu_hw = cpe_parameters(j).hw.rep_parameters.lambda;
            lambda_sw = cpe_parameters(j).sw.fail_parameters.lambda;
            mu_sw = cpe_parameters(j).sw.rep_parameters.lambda;
            availability_CPEs(j) = (mu_hw*(mu_sw+lambda_hw))/((lambda_hw+mu_hw)*(lambda_hw+lambda_sw+mu_sw));
        else
            error("probability distribution not known");
        end
    end
    
    fprintf("\tCPE availabilities: %f and %f\n", availability_CPEs(1), availability_CPEs(2));
    
    %% CONTROLLER
    if (strcmp(controller_parameters.hw.fail_distribution, 'exp') && strcmp(controller_parameters.hw.rep_distribution, 'exp') && strcmp(controller_parameters.sw.fail_distribution, 'exp') && strcmp(controller_parameters.sw.rep_distribution, 'exp'))
        lambda_hw = controller_parameters.hw.fail_parameters.lambda;
        mu_hw = controller_parameters.hw.rep_parameters.lambda;
        lambda_sw = controller_parameters.sw.fail_parameters.lambda;
        mu_sw = controller_parameters.sw.rep_parameters.lambda;
        availability_controller = (mu_hw*(mu_sw+lambda_hw))/((lambda_hw+mu_hw)*(lambda_hw+lambda_sw+mu_sw));
    else
        error("probability distribution not known");
    end
    if isfield(controller_parameters, 'nb_replicas')
        availability_controller = 1 - (1-availability_controller)^controller_parameters.nb_replicas;
    end
    
    fprintf("\tController availability: %f\n", availability_controller);
    
    %% CONTROLLER TO CPE
    controller_to_cpe_availabilities = ones(2,1);
    for j=1:2
        if strcmp(controller2cpe_parameters(j).fail_distribution, 'exp') && strcmp(controller2cpe_parameters(j).rep_distribution, 'exp')
            controller_to_cpe_availabilities(j) = controller2cpe_parameters(j).rep_parameters.lambda / (controller2cpe_parameters(j).fail_parameters.lambda + controller2cpe_parameters(j).rep_parameters.lambda);
        else
            error("probability distribution not known");
        end
    end
    fprintf("\tcontroller2CPE availabilities: %f and %f\n", controller_to_cpe_availabilities(1), controller_to_cpe_availabilities(2));
    
    %% CONTROL PLANE
    control_plane_availability =  availability_controller * prod(controller_to_cpe_availabilities);
    fprintf("\tcontroller plane availabilities: %f\n", control_plane_availability);

    %% OVERALL availability
    higher_ss_availability = prod(availability_CPEs) * availability_tunnel_system; 
    
    lower_ss_availability = higher_ss_availability * control_plane_availability;
    
end