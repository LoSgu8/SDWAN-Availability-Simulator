function [lower_ss_availability, higher_ss_availability] = model_solution(tunnel_parameters, controller_parameters, controller2cpe_parameters, cpe_parameters, verbosity)
    if verbosity
        fprintf("MODEL SOLUTION\n"); 
    end
    %% TUNNEL
    nb_tunnels = size(tunnel_parameters, 2);
    
    tunnel_availabilities = ones(nb_tunnels,1);
    if verbosity
        fprintf("\tFound %d tunnels\n", nb_tunnels);
    end
    for tunnel_idx=1:nb_tunnels
        if verbosity
            fprintf("\t\tTunnel %d: ", tunnel_idx);
        end
        component_names = fieldnames(tunnel_parameters(tunnel_idx));
        
        for component_idx = 1:numel(component_names)
            component_name = component_names{component_idx};
            if verbosity
                fprintf("\t\t%s",component_name)
            end
            component_pars = tunnel_parameters(tunnel_idx).(component_name);
            if strcmp(component_pars.fail_distribution, 'exp') && strcmp(component_pars.rep_distribution, 'exp')
                component_availability = component_pars.rep_parameters.lambda / ( component_pars.fail_parameters.lambda + component_pars.rep_parameters.lambda);
                tunnel_availabilities(tunnel_idx) = tunnel_availabilities(tunnel_idx) * component_availability;
            else
                error("probability distribution not known");
            end
        end
        if verbosity
            fprintf(" with availability of %f\n", tunnel_availabilities(tunnel_idx));
        end
    end
    
    availability_tunnel_system = 1 - prod(1-tunnel_availabilities);
    if verbosity
        fprintf("\tTunnels steady state availability: %f\n", availability_tunnel_system);
    end
    
    
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
    
    if verbosity
        fprintf("\tCPE availabilities: %f and %f\n", availability_CPEs(1), availability_CPEs(2));
    end
    
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
    
    if verbosity
        fprintf("\tController availability: %f\n", availability_controller);
    end
    
    %% CONTROLLER TO CPE
    controller_to_cpe_availabilities = ones(2,1);
    for j=1:2
        if strcmp(controller2cpe_parameters(j).fail_distribution, 'exp') && strcmp(controller2cpe_parameters(j).rep_distribution, 'exp')
            controller_to_cpe_availabilities(j) = controller2cpe_parameters(j).rep_parameters.lambda / (controller2cpe_parameters(j).fail_parameters.lambda + controller2cpe_parameters(j).rep_parameters.lambda);
        else
            error("probability distribution not known");
        end
    end

    if verbosity
        fprintf("\tcontroller2CPE availabilities: %f and %f\n", controller_to_cpe_availabilities(1), controller_to_cpe_availabilities(2));
    end
    
    %% CONTROL PLANE
    control_plane_availability =  availability_controller * prod(controller_to_cpe_availabilities);
    if verbosity
        fprintf("\tcontroller plane availabilities: %f\n", control_plane_availability);
    end

    %% OVERALL availability
    higher_ss_availability = prod(availability_CPEs) * availability_tunnel_system; 
    
    lower_ss_availability = higher_ss_availability * control_plane_availability;
    
end