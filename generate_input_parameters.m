sampling_time_interval = 0.1; % hours
simulation_time = 1000000; % hours

initial_active_tunnel = 1;


%% SUPPORTED PROBABILITY DISTRIBUTIONS
% o Exponential distribution
%   Required parameters:
%   - lambda

%% TUNNEL PARAMETERS
% Tunnels are expressed in order of priority

% Tunnel 1
%   Source Access Network 
tunnel.ANs.initial_status = true;
tunnel.ANs.fail_distribution = 'exp';
tunnel.ANs.fail_parameters.lambda = 1/10000;
tunnel.ANs.rep_distribution = 'exp';
tunnel.ANs.rep_parameters.lambda = 1/5;
%   Sink Access Network
tunnel.ANt.initial_status = 1;
tunnel.ANt.fail_distribution = 'exp';
tunnel.ANt.fail_parameters.lambda = 1/10000;
tunnel.ANt.rep_distribution = 'exp';
tunnel.ANt.rep_parameters.lambda = 1/5;
%   Underlay Network
tunnel.UN.initial_status = 1;
tunnel.UN.fail_distribution = 'exp';
tunnel.UN.fail_parameters.lambda = 1/50000;
tunnel.UN.rep_distribution = 'exp';
tunnel.UN.rep_parameters.lambda = 1/0.1;

tunnel_parameters(1) = tunnel;

% Tunnel 2
%   Source Access Network
tunnel.ANs.initial_status = 1/25000;
tunnel.ANs.fail_distribution = 'exp';
tunnel.ANs.fail_parameters.lambda = 1/25000;
tunnel.ANs.rep_distribution = 'exp';
tunnel.ANs.rep_parameters.lambda = 1/2;
%   Sink Access Network
tunnel.ANt.initial_status = 1;
tunnel.ANt.fail_distribution = 'exp';
tunnel.ANt.fail_parameters.lambda = 1/25000;
tunnel.ANt.rep_distribution = 'exp';
tunnel.ANt.rep_parameters.lambda = 1/2;
%   Underlay Network
tunnel.UN.initial_status = 1;
tunnel.UN.fail_distribution = 'exp';
tunnel.UN.fail_parameters.lambda = 1/50000;
tunnel.UN.rep_distribution = 'exp';
tunnel.UN.rep_parameters.lambda = 1/0.01;

tunnel_parameters(2) = tunnel;

%% CPEs PARAMETERS
% CPE 1
% Software module
cpe.sw.initial_status = 1;
cpe.sw.fail_distribution = 'exp';
cpe.sw.fail_parameters.lambda = 1/200;
cpe.sw.rep_distribution = 'exp';
cpe.sw.rep_parameters.lambda = 1/0.001;

% Hardware module
cpe.hw.initial_status = true;
cpe.hw.fail_distribution = 'exp';
cpe.hw.fail_parameters.lambda = 1/5000;
cpe.hw.rep_distribution = 'exp';
cpe.hw.rep_parameters.lambda = 1/12;

cpe_parameters(1) = cpe;

% CPE 2
% Software module
cpe.sw.initial_status = 1;
cpe.sw.fail_distribution = 'exp';
cpe.sw.fail_parameters.lambda = 1/200;
cpe.sw.rep_distribution = 'exp';
cpe.sw.rep_parameters.lambda = 1/0.001;

% Hardware module
cpe.hw.initial_status = 1;
cpe.hw.fail_distribution = 'exp';
cpe.hw.fail_parameters.lambda = 1/5000;
cpe.hw.rep_distribution = 'exp';
cpe.hw.rep_parameters.lambda = 1/12;

cpe_parameters(2) = cpe;


%% CONTROLLER PARAMETERS
% Software module
controller.sw.initial_status = 1;
controller.sw.fail_distribution = 'exp';
controller.sw.fail_parameters.lambda = 1/100;
controller.sw.rep_distribution = 'exp';
controller.sw.rep_parameters.lambda = 1/0.1;

% Hardware module
controller.hw.initial_status = 1;
controller.hw.fail_distribution = 'exp';
controller.hw.fail_parameters.lambda = 1/5000;
controller.hw.rep_distribution = 'exp';
controller.hw.rep_parameters.lambda = 1/12;

controller_parameters = controller;

%% CONTROLLER TO CPE LINK PARAMETERS

% C2CPE1
controller2cpe.initial_status = 1;
controller2cpe.fail_distribution = 'exp';
controller2cpe.fail_parameters.lambda = 1/10000;
controller2cpe.rep_distribution = 'exp';
controller2cpe.rep_parameters.lambda = 1/2;

controller2cpe_parameters(1) = controller2cpe;

% C2CPE2
controller2cpe.initial_status = 1;
controller2cpe.fail_distribution = 'exp';
controller2cpe.fail_parameters.lambda = 1/10000;
controller2cpe.rep_distribution = 'exp';
controller2cpe.rep_parameters.lambda = 1/2;

controller2cpe_parameters(2) = controller2cpe;

%% SAVE PARAMETERS IN .mat
save('controller2cpe_parameters', 'controller2cpe_parameters')
save('controller_parameter.mat', 'controller_parameters');
save('cpe_parameter.mat', 'cpe_parameters');
save('tunnel_parameters.mat', 'tunnel_parameters');
save('general_parameters.mat', 'initial_active_tunnel', 'simulation_time', 'sampling_time_interval');