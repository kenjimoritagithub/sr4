% make_figureN9and11

CandStates_set_set = [1 2];
dur_epoch_set = [10 15 25 50 150 500];
plotminmax = [];
makecsv = 1;
savefig = 1;
for model_type = 1:3
    for k_CandStates_set = 1:length(CandStates_set_set)
        Pfminmax_set{model_type}{k_CandStates_set} = NaN(length(dur_epoch_set),2);
        CandStates_set = CandStates_set_set(k_CandStates_set);
        for k_dur_epoch = 1:length(dur_epoch_set)
            dur_epoch = dur_epoch_set(k_dur_epoch);
            [Pfminmax, Pfgood] = broadanaplot3(model_type, CandStates_set, dur_epoch, plotminmax, makecsv, savefig);
            Pfminmax_set{model_type}{k_CandStates_set}(k_dur_epoch,:) = Pfminmax;
            close all
        end
    end
end
save('Pfminmax_set_fig9and11.mat','Pfminmax_set');
