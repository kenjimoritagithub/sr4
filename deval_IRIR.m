function Out = deval_IRIR(a_IR,b,g,dur_ini,dur_learning,deval_order,view_yn)

% Simulated outcome devaluation, model with two IR-based systems

% prepare the figure
if view_yn
    F = figure;
    A = axes;
    hold on
    axis([0.5 5.5 0.5 5.5]);
end

% order of forced training and devaluation
if deval_order == 0
    pregoal_order = [2 6];
elseif deval_order == 1
    pregoal_order = [6 2];
end

% neighboring states of each state, to which the agent can move in the next time step
NB{1} = [2 6]; NB{2} = [3];
NB{6} = [11];

% initialization of system-specific state values
IRSV{1} = zeros(25,1); % IR-based system-specific state values for system 1
IRSV{2} = zeros(25,1); % IR-based system-specific state values for system 2

% reward-related settings
R = zeros(25,1); % initialization of reward in each state
G = [3 11];

% main loop
nextS = 1; % next state
for k = 1:dur_ini+dur_learning
    
    % introduce reward after dur_ini
    if k == dur_ini + 1
        R(G) = 1; % place reward at the rewarded state
    end
    
    % forcedly place the agent
    if sum(k == dur_ini + [1:4:37])
        nextS = pregoal_order(1);
    elseif sum(k == dur_ini + [3:4:39])
        nextS = pregoal_order(2);
    end
    
    % state transition
    currS = nextS; % current state
    
    % integrated state values, which are the means of the system-specific state values of the two systems
    intSV = (IRSV{1} + IRSV{2})/2;
    
    % draw
    if view_yn
        hold off
        P = image(flipud(64*reshape(intSV,5,5)'));
        hold on
        P = plot(mod(currS-1,5)+1,6-ceil(currS/5),'wd'); set(P,'MarkerSize',20,'LineWidth',4);
        set(A,'PlotBoxAspectRatio',[1 1 1]);
        set(A,'XTick',[1:5],'XTickLabel',[1:5],'FontSize',24);
        set(A,'YTick',[1:5],'YTickLabel',[5:-1:1],'FontSize',24);
        ketamax = floor(log10(dur_ini+dur_learning)) + 1;
        num0add = ketamax - (floor(log10(k))+1);
        tmp_title = [];
        for k_0 = 1:num0add
            tmp_title = [tmp_title, '0'];
        end
        tmp_title = [tmp_title, num2str(k)];
        title(tmp_title,'FontSize',24);
        drawnow;
        pause(0.05);
    end
    
    % select action to move to one of the neighboring states
    if ~sum(currS==G)
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
    if ~sum(currS==G)
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
    if sum(currS==G)
        nextS = 1; % return to the start state
    end
    
end
intSV1 = intSV; % for output

% devaluation
R(11) = 0;
currS = 11;
TDRPE = R(currS) + 0 - intSV(currS);
% update of IRSV{1} and IRSV{2}
for k_sys = 1:2
    if TDRPE >= 0
        IRSV{k_sys}(currS) = IRSV{k_sys}(currS) + a_IR(k_sys,1)*TDRPE;
    else
        IRSV{k_sys}(currS) = IRSV{k_sys}(currS) + a_IR(k_sys,2)*TDRPE;
    end
end
intSV = (IRSV{1} + IRSV{2})/2;
intSV2 = intSV; % for output
% draw
if view_yn
    pause(2);
    hold off
    P = image(flipud(64*reshape(intSV,5,5)'));
    hold on
    P = plot(mod(currS-1,5)+1,6-ceil(currS/5),'wd'); set(P,'MarkerSize',20,'LineWidth',4);
    set(A,'PlotBoxAspectRatio',[1 1 1]);
    set(A,'XTick',[1:5],'XTickLabel',[1:5],'FontSize',24);
    set(A,'YTick',[1:5],'YTickLabel',[5:-1:1],'FontSize',24);
    ketamax = floor(log10(dur_ini+dur_learning)) + 1;
    num0add = ketamax - (floor(log10(k))+1);
    title('Devalued','FontSize',24);
    drawnow;
    pause(2);
end

% test
k = 0;
nextS = 1; % next state
while 1
    
    % state transition
    k = k + 1;
    currS = nextS; % current state
    
    % integrated state values, which are the means of the system-specific state values of the two systems
    intSV = (IRSV{1} + IRSV{2})/2;
    
    % draw
    if view_yn
        hold off
        P = image(flipud(64*reshape(intSV,5,5)'));
        hold on
        P = plot(mod(currS-1,5)+1,6-ceil(currS/5),'wd'); set(P,'MarkerSize',20,'LineWidth',4);
        set(A,'PlotBoxAspectRatio',[1 1 1]);
        set(A,'XTick',[1:5],'XTickLabel',[1:5],'FontSize',24);
        set(A,'YTick',[1:5],'YTickLabel',[5:-1:1],'FontSize',24);
        ketamax = floor(log10(dur_ini+dur_learning)) + 1;
        num0add = ketamax - (floor(log10(k))+1);
        tmp_title = [];
        for k_0 = 1:num0add
            tmp_title = [tmp_title, '0'];
        end
        tmp_title = [tmp_title, num2str(k)];
        title(tmp_title,'FontSize',24);
        drawnow;
        pause(0.05);
    end
    
    % select action to move to one of the neighboring states
    if ~sum(currS==G)
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
    if ~sum(currS==G)
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
    
    % if the agent reached the pre-goal state
    if sum(currS==[2 6])
        break;
    end
    
end

% output 
Out.intSV{1} = intSV1; % integrated value at the end of the learning epoch
Out.intSV{2} = intSV2; % integrated value just after devaluation
Out.devalchoice = (currS==6); % if devalued option was chosen
