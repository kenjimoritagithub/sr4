function Out = distana(model_type,a,dur_epoch,CandStates_set,num_sim)

% parameters
b = 10;
g = 0.7;
dur_ini = 500; % duration (time steps) for the initial no-reward epoch
num_epoch = 4500/dur_epoch;

% main
dist_set = NaN(num_sim,9);
ave_time_set = NaN(num_sim,9);
for k_sim = 1:num_sim
    fprintf('%d\n',k_sim);
    for k = 1:9
        time_set{k_sim}{k} = [];
    end
    if model_type == 1
        SimOut{k_sim} = gridtask_SRIR3s(a{1},a{2},b,g,dur_ini,dur_epoch,num_epoch,CandStates_set);
    elseif model_type == 2
        SimOut{k_sim} = gridtask_SRSR3s(a,b,g,dur_ini,dur_epoch,num_epoch,CandStates_set);
    elseif model_type == 3
        SimOut{k_sim} = gridtask_IRIR3s(a,b,g,dur_ini,dur_epoch,num_epoch,CandStates_set);
    end
    dist_set(k_sim,:) = hist(SimOut{k_sim}.Rrecord(2:end,3),[0:8]);
    for k = 1:size(SimOut{k_sim}.Rrecord,1)-1
        time_set{k_sim}{SimOut{k_sim}.Rrecord(k+1,3)+1} = ...
            [time_set{k_sim}{SimOut{k_sim}.Rrecord(k+1,3)+1}, ...
            SimOut{k_sim}.Rrecord(k+1,1)-SimOut{k_sim}.Rrecord(k,1)-1]; % "-1": in order to count from the start state
    end
    for k = 1:9
        ave_time_set(k_sim,k) = mean(time_set{k_sim}{k});
    end
end
mean_dist = NaN(1,9);
std_dist = NaN(1,9);
sem_dist = NaN(1,9);
mean_ave_time = NaN(1,9);
std_ave_time = NaN(1,9);
sem_ave_time = NaN(1,9);
for k = 1:9
    mean_dist(k) = mean(dist_set(~isnan(dist_set(:,k)),k));
    std_dist(k) = std(dist_set(~isnan(dist_set(:,k)),k),1);
    sem_dist(k) = std_dist(k)/sqrt(sum(~isnan(dist_set(:,k))));
    mean_ave_time(k) = mean(ave_time_set(~isnan(ave_time_set(:,k)),k));
    std_ave_time(k) = std(ave_time_set(~isnan(ave_time_set(:,k)),k),1);
    sem_ave_time(k) = std_ave_time(k)/sqrt(sum(~isnan(ave_time_set(:,k))));
end

% output
Out.dist_set = dist_set;
Out.ave_time_set = ave_time_set;
Out.mean_dist = mean_dist;
Out.std_dist = std_dist;
Out.sem_dist = sem_dist;
Out.mean_ave_time = mean_ave_time;
Out.std_ave_time = std_ave_time;
Out.sem_ave_time = sem_ave_time;
