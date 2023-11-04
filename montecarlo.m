clear all
close all

%% Set the number of Monte Carlo simulations to run
n_sims = 10000;

%% Run the Monte Carlo simulation
collected_availabilities = zeros(n_sims, 1);

for running_idx = 1:n_sims
    disp(['Running simulation ' num2str(running_idx) '/' num2str(n_sims)])
    run('main.m');
    collected_availabilities(running_idx) = sdwan_availability;
    disp(sdwan_availability)
end

%% Calculate the mean and standard deviation of the extracted variable
mean = mean(collected_availabilities);
standard_deviation = std(collected_availabilities);

%% Display the mean and standard deviation
disp(['Mean:', num2str(mean)]);
disp(['Standard deviation:', num2str(standard_deviation)]);