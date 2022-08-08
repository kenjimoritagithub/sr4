function sim_SRIR3_SRSR3_IRIR3(CandStates_set,dur_epoch,model_type,k_para)

% simulations for Figure 9 and Figure 11
% <example code to run this function to generate and save all the data for Figure 9 and Figure 11>
% for CandStates_set = [1 2]
%     for dur_epoch = [15 25 50 100 300 900]
%         tmp_num_para = [1 2 2];
%         for model_type = 1:3
%             for k_para = 1:tmp_num_para(model_type)
%                 sim_SRIR3_SRSR3_IRIR3(CandStates_set,dur_epoch,model_type,k_para);
%             end
%         end
%     end
% end

% parameters
a_set = [0.2:0.15:0.8];
g = 0.7;
dur_ini = 500; % duration (time steps) for the initial no-reward epoch
num_epoch = 4500/dur_epoch;

if model_type == 1
    % SRIR
    a_SRfeatures = 0.05;
    b = 10;
    num_sim = 100;
    for k_SR1 = 1:length(a_set)
        for k_SR2 = 1:length(a_set)
            rand_twister = 614000000 + CandStates_set*100000 + dur_epoch*100 + model_type*10;
            rand('twister',rand_twister);
            for k_IR1 = 1:length(a_set)
                for k_IR2 = 1:length(a_set)
                    for k_sim = 1:num_sim
                        fprintf('SR %d-%d IR %d-%d sim %d\n',k_SR1,k_SR2,k_IR1,k_IR2,k_sim);
                        Out = gridtask_SRIR3([a_set(k_SR1) a_set(k_SR2) a_SRfeatures],...
                            [a_set(k_IR1) a_set(k_IR2)],b,g,dur_ini,dur_epoch,num_epoch,CandStates_set);
                        totalRset(1,k_SR1,k_SR2,k_IR1,k_IR2,k_sim) = Out.totalR;
                    end
                end
            end
            save(['totalRset_' num2str(CandStates_set) '_dur_epoch' num2str(dur_epoch) '_SRIR'],'totalRset');
        end
    end
    
elseif model_type == 2
    % SRSR
    a_SRfeatures_set = [0.15 0.2];
    b = 10;
    num_sim = 50;
    for k_SRf = k_para %1:length(a_SRfeatures_set)
        for k_SR11 = 1:length(a_set)
            for k_SR12 = 1:length(a_set)
                rand_twister = 614000000 + CandStates_set*100000 + dur_epoch*100 + model_type*10 + k_SRf;
                rand('twister',rand_twister);
                for k_SR21 = 1:length(a_set)
                    for k_SR22 = 1:length(a_set)
                        for k_sim = 1:num_sim
                            fprintf('f %d SR1 %d-%d SR2 %d-%d sim %d\n',k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim);
                            Out = gridtask_SRSR3([a_set(k_SR11) a_set(k_SR12) a_SRfeatures_set(k_SRf); ...
                                a_set(k_SR21) a_set(k_SR22) a_SRfeatures_set(k_SRf)],b,g,dur_ini,dur_epoch,num_epoch,CandStates_set);
                            totalRset(k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim) = Out.totalR;
                        end
                        for k_sim = num_sim+1:2*num_sim
                            fprintf('f %d SR1 %d-%d SR2 %d-%d sim %d\n',k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim);
                            if (k_SR11==k_SR21) && (k_SR12==k_SR22)
                                Out = gridtask_SRSR3([a_set(k_SR11) a_set(k_SR12) a_SRfeatures_set(k_SRf); ...
                                    a_set(k_SR21) a_set(k_SR22) a_SRfeatures_set(k_SRf)],b,g,dur_ini,dur_epoch,num_epoch,CandStates_set);
                                totalRset(k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim) = Out.totalR;
                            else
                                totalRset(k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim) = NaN;
                            end
                        end
                    end
                end
                save(['totalRset_' num2str(CandStates_set) '_dur_epoch' num2str(dur_epoch) '_SRSR_' num2str(k_SRf)],'totalRset');
            end
        end
    end
    for k_SRf = k_para %1:length(a_SRfeatures_set)
        for k_SR11 = 1:length(a_set)
            for k_SR12 = 1:length(a_set)
                for k_SR21 = 1:length(a_set)
                    for k_SR22 = 1:length(a_set)
                        for k_sim = num_sim+1:2*num_sim
                            if ~((k_SR11==k_SR21) && (k_SR12==k_SR22))
                                totalRset(k_SRf,k_SR11,k_SR12,k_SR21,k_SR22,k_sim) = totalRset(k_SRf,k_SR21,k_SR22,k_SR11,k_SR12,k_sim-num_sim);
                            end
                        end
                    end
                end
            end
        end
        save(['totalRset_' num2str(CandStates_set) '_dur_epoch' num2str(dur_epoch) '_SRSR_' num2str(k_SRf)],'totalRset');
    end
    
elseif model_type == 3
    % IRIR
    b_set = [2.5 5];
    num_sim = 50;
    for k_b = k_para %1:length(b_set)
        b = b_set(k_b);
        for k_IR11 = 1:length(a_set)
            for k_IR12 = 1:length(a_set)
                rand_twister = 614000000 + CandStates_set*100000 + dur_epoch*100 + model_type*10 + k_b;
                rand('twister',rand_twister);
                for k_IR21 = 1:length(a_set)
                    for k_IR22 = 1:length(a_set)
                        for k_sim = 1:num_sim
                            fprintf('IR-IR b %d IR1 %d-%d IR2 %d-%d sim %d\n',k_b,k_IR11,k_IR12,k_IR21,k_IR22,k_sim);
                            Out = gridtask_IRIR3([a_set(k_IR11) a_set(k_IR12); ...
                                a_set(k_IR21) a_set(k_IR22)],b,g,dur_ini,dur_epoch,num_epoch,CandStates_set);
                            totalRset(k_b,k_IR11,k_IR12,k_IR21,k_IR22,k_sim) = Out.totalR;
                        end
                        for k_sim = num_sim+1:2*num_sim
                            fprintf('IR-IR b %d IR1 %d-%d IR2 %d-%d sim %d\n',k_b,k_IR11,k_IR12,k_IR21,k_IR22,k_sim);
                            if (k_IR11==k_IR21) && (k_IR12==k_IR22)
                                Out = gridtask_IRIR3([a_set(k_IR11) a_set(k_IR12); ...
                                    a_set(k_IR21) a_set(k_IR22)],b,g,dur_ini,dur_epoch,num_epoch,CandStates_set);
                                totalRset(k_b,k_IR11,k_IR12,k_IR21,k_IR22,k_sim) = Out.totalR;
                            else
                                totalRset(k_b,k_IR11,k_IR12,k_IR21,k_IR22,k_sim) = NaN;
                            end
                        end
                    end
                end
                save(['totalRset_' num2str(CandStates_set) '_dur_epoch' num2str(dur_epoch) '_IRIR_' num2str(k_b)],'totalRset');
            end
        end
    end
    for k_b = k_para %1:length(b_set)
        for k_IR11 = 1:length(a_set)
            for k_IR12 = 1:length(a_set)
                for k_IR21 = 1:length(a_set)
                    for k_IR22 = 1:length(a_set)
                        for k_sim = num_sim+1:2*num_sim
                            if ~((k_IR11==k_IR21) && (k_IR12==k_IR22))
                                totalRset(k_b,k_IR11,k_IR12,k_IR21,k_IR22,k_sim) = totalRset(k_b,k_IR21,k_IR22,k_IR11,k_IR12,k_sim-num_sim);
                            end
                        end
                    end
                end
            end
        end
        save(['totalRset_' num2str(CandStates_set) '_dur_epoch' num2str(dur_epoch) '_IRIR_' num2str(k_b)],'totalRset');
    end
    
end
