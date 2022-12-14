function Out = gridtask_IRIR3(a_IR,b,g,dur_ini,dur_epoch,num_epoch,CandStates_set)

% Variation of gridtask_IRIR for Figure 11
%
% < Input variables >
%   CandStates_set:
%       1: clustered goal setting ([5 10 15 20 21 22 23 24 25])
%       2: random goal setting ([4:5 8:10 12:25] i.e., any place not within 2 time steps from the start)
%   num_epoch: can be larger than 9
%   (R_prob: removed)

% neighboring states of each state, to which the agent can move in the next time step
NB{1} = [2 6]; NB{2} = [1 3 7]; NB{3} = [2 4 8]; NB{4} = [3 5 9]; NB{5} = [4 10];
NB{6} = [1 7 11]; NB{7} = [2 6 8 12]; NB{8} = [3 7 9 13]; NB{9} = [4 8 10 14]; NB{10} = [5 9 15];
NB{11} = [6 12 16]; NB{12} = [7 11 13 17]; NB{13} = [8 12 14 18]; NB{14} = [9 13 15 19]; NB{15} = [10 14 20];
NB{16} = [11 17 21]; NB{17} = [12 16 18 22]; NB{18} = [13 17 19 23]; NB{19} = [14 18 20 24]; NB{20} = [15 19 25];
NB{21} = [16 22]; NB{22} = [17 21 23]; NB{23} = [18 22 24]; NB{24} = [19 23 25]; NB{25} = [20 24];

% initialization of system-specific state values
IRSV{1} = zeros(25,1); % IR-based system-specific state values for system 1
IRSV{2} = zeros(25,1); % IR-based system-specific state values for system 2

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
    intSV = (IRSV{1} + IRSV{2})/2;
    
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
    
    % update of IRSV{1} and IRSV{2}
    for k_sys = 1:2
        if TDRPE >= 0
            IRSV{k_sys}(currS) = IRSV{k_sys}(currS) + a_IR(k_sys,1)*TDRPE;
        else
            IRSV{k_sys}(currS) = IRSV{k_sys}(currS) + a_IR(k_sys,2)*TDRPE;
        end
    end
    
    % if the agent reached the rewarded state
    if currS == G
        totalR = totalR + 1;
        nextS = 1; % return to the start state
        % next rewarded state
        R_epoch = ceil((k-dur_ini)/dur_epoch); % epoch for the reward set now
        R = zeros(25,1);
        G = SRCS_set(R_epoch); % set the special candidate state for the current epoch as the rewarded state
        R(G) = 1;
    end
    
end

% output total reward
Out.totalR = totalR;
