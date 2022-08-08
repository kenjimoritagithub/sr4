function Out = gridtask_SRIR3s(a_SR,a_IR,b,g,dur_ini,dur_epoch,num_epoch,CandStates_set)

% same as gridtask_SRIR3, except that reward history is also saved (for Figure 10)

% neighboring states of each state, to which the agent can move in the next time step
NB{1} = [2 6]; NB{2} = [1 3 7]; NB{3} = [2 4 8]; NB{4} = [3 5 9]; NB{5} = [4 10];
NB{6} = [1 7 11]; NB{7} = [2 6 8 12]; NB{8} = [3 7 9 13]; NB{9} = [4 8 10 14]; NB{10} = [5 9 15];
NB{11} = [6 12 16]; NB{12} = [7 11 13 17]; NB{13} = [8 12 14 18]; NB{14} = [9 13 15 19]; NB{15} = [10 14 20];
NB{16} = [11 17 21]; NB{17} = [12 16 18 22]; NB{18} = [13 17 19 23]; NB{19} = [14 18 20 24]; NB{20} = [15 19 25];
NB{21} = [16 22]; NB{22} = [17 21 23]; NB{23} = [18 22 24]; NB{24} = [19 23 25]; NB{25} = [20 24];

% initialization of system-specific state values and SR features
SR = zeros(25,25); % SR matrix
w = zeros(25,1); % weights for SR-based system-specific state value function (SR*w gives SR-based system-specific state values)
IRSV = zeros(25,1); % IR-based system-specific state values
I25 = eye(25);

% reward-related settings
if CandStates_set == 1
    RewCandStates = [5 10 15 20 21 22 23 24 25]; % reward candidate states
elseif CandStates_set == 2
    RewCandStates = [4:5 8:10 12:25]; % reward candidate states
end
SRCS_set = []; % special reward candidate states for each rewarded epoch
for k1 = 1:ceil(num_epoch/length(RewCandStates))
    tmp_rand = randperm(length(RewCandStates));
    SRCS_set = [SRCS_set, RewCandStates(tmp_rand)];
end
totalR = 0; % initialization of total rewards
R = zeros(25,1); % initialization of reward in each state
G = NaN; % initialization of rewarded state (goal)

% reward history recording
Rrecord = NaN(dur_epoch*num_epoch,3);
% figure; hist(Out.Rrecord(2:end,3),[0:max(Out.Rrecord(2:end,3))]); figure; plot(Out.Rrecord(2:end,3),diff(Out.Rrecord(:,1)),'x');

% main loop
nextS = 1; % next state
for k = 1:dur_ini+num_epoch*dur_epoch
    
    % introduce reward after dur_ini
    if k == dur_ini + 1
        R_epoch = 1; % epoch for the reward set now
        G = SRCS_set(R_epoch); % set the special candidate state for the current epoch as the rewarded state
        R(G) = 1; % place reward at the rewarded state
    end
    
    % state transition
    currS = nextS; % current state
    
    % integrated state values, which are the means of the system-specific state values of the two systems
    intSV = (IRSV + SR*w)/2;
    
    % select action to move to one of the neighboring states
    if currS ~= G
        tmp_prob = exp(b*intSV(NB{currS})) / sum(exp(b*intSV(NB{currS}))); % soft-max
        tmp = rand;
        if tmp <= tmp_prob(1)
            nextS = NB{currS}(1);
        elseif (length(NB{currS}) >= 3) && (tmp <= tmp_prob(1) + tmp_prob(2))
            nextS = NB{currS}(2);
        elseif (length(NB{currS}) >= 4) && (tmp <= tmp_prob(1) + tmp_prob(2) + tmp_prob(3))
            nextS = NB{currS}(3);
        else
            nextS = NB{currS}(end);
        end
    end
    
    % TD-RPE
    if currS ~= G
        TDRPE = R(currS) + g*intSV(nextS) - intSV(currS);
    else
        TDRPE = R(currS) + 0 - intSV(currS);
    end
    
    % update of IRSV
    if TDRPE >= 0
        IRSV(currS) = IRSV(currS) + a_IR(1)*TDRPE;
    else
        IRSV(currS) = IRSV(currS) + a_IR(2)*TDRPE;
    end
    
    % update of w
    if TDRPE >= 0
        w = w + a_SR(1)*SR(currS,:)'*TDRPE;
    else
        w = w + a_SR(2)*SR(currS,:)'*TDRPE;
    end
    
    % update of SR features
    if currS ~= G
        TDEsr = I25(currS,:) + g*SR(nextS,:) - SR(currS,:);
    else
        TDEsr = I25(currS,:) - SR(currS,:);
    end
    SR(currS,:) = SR(currS,:) + a_SR(3)*TDEsr;
    
    % if the agent reached the rewarded state
    if currS == G
        totalR = totalR + 1;
        nextS = 1; % return to the start state
        tmp_index = find(isnan(Rrecord(:,1)),1);
        Rrecord(tmp_index,1) = k;
        Rrecord(tmp_index,2) = G;
        if tmp_index > 1
            Rrecord(tmp_index,3) = dist([G,Rrecord(tmp_index-1,2)]); % distance from the previous goal location
        end
        % next rewarded state
        R_epoch = ceil((k-dur_ini)/dur_epoch); % epoch for the reward set now
        R = zeros(25,1);
        G = SRCS_set(R_epoch); % set the special candidate state for the current epoch as the rewarded state
        R(G) = 1;
    end
    
end

% output total reward and reward history
Out.totalR = totalR;
Out.Rrecord = Rrecord(1:totalR,:,:);
