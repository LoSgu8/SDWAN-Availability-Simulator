function availability = compute_availability_from_signal(status_signal)

    % The availability is computed as the percentage of ones in the
    % status_signal
    availability = sum(status_signal)/numel(status_signal);

end