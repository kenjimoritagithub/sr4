function [Pfminmax, Pfgood] = broadanaplot3(model_type, CandStates_set, dur_epoch, plotminmax, makecsv, savefig)

% model_type : 1-SR&IR, 2-SRonly, 3-IRonly
% CandStates_set : 1-clustered goal setting, 2-random goal setting
% dur_epoch : duration of rewarded epochs
% plotminmax : specify the min and max range for the color plot; if this is [] (empty), min and max of the data are used
% makecsv : whether to make a csv file including Pfgood (1) or not (0)
% savefig : whther to save the figure(s) (1) or not (0)
%
% e.g.
%	[Pfminmax, Pfgood] = broadanaplot3(1, 1, 25, [], 0, 0)
%	[Pfminmax, Pfgood] = broadanaplot3(2, 1, 25, [0 132], 0, 0)

% parameters
a_set = [0.2:0.15:0.8];

% load and check the data
model_names{1} = 'SRIR';
model_names{2} = 'SRSR';
model_names{3} = 'IRIR';
if model_type == 1
    para_set = [0.05];
    load(['totalRset_' num2str(CandStates_set) '_dur_epoch' num2str(dur_epoch) '_' model_names{model_type}]);
else
    if model_type == 2
        para_set = [0.15 0.2];
    elseif model_type == 3
        para_set = [2.5 5];
    end
    load(['totalRset_' num2str(CandStates_set) '_dur_epoch' num2str(dur_epoch) '_' model_names{model_type} '_1']);
    tmp1 = totalRset;
    clear totalRset
    load(['totalRset_' num2str(CandStates_set) '_dur_epoch' num2str(dur_epoch) '_' model_names{model_type} '_2']);
    totalRset(1,:,:,:,:,:) = tmp1(1,:,:,:,:,:);
end
data = totalRset;
if sum(isnan(data(:)))
    error('NaN is included. Some data are lacking.');
elseif sum(data(:)==0)
    fprintf('0 is included. Check if it is valid.');
end

% analysis
mean_data = mean(data,6);
Pfminmax = [min(mean_data(:)), max(mean_data(:))]; % min and max of mean performance
[tmp_values,tmp_indice] = sort(mean_data(:),'descend');
for k1 = 1:30
    tmp_i = NaN(1,5);
    [tmp_i(1),tmp_i(2),tmp_i(3),tmp_i(4),tmp_i(5)] = ind2sub(size(mean_data),tmp_indice(k1));
    if k1 == 1
        Pfgood = [para_set(tmp_i(1)),a_set(tmp_i(2)),a_set(tmp_i(3)),a_set(tmp_i(4)),a_set(tmp_i(5)),tmp_values(k1)];
    else
        tmp_ifadd = 1;
        if (model_type == 2) || (model_type == 3)
            for k2 = 1:size(Pfgood,1)
                if (sum(a_set(tmp_i(2:3))==Pfgood(k2,4:5))==2) && (sum(a_set(tmp_i(4:5))==Pfgood(k2,2:3))==2)
                    tmp_ifadd = 0;
                end
            end
        end
        if tmp_ifadd
            Pfgood = [Pfgood; para_set(tmp_i(1)),a_set(tmp_i(2)),a_set(tmp_i(3)),a_set(tmp_i(4)),a_set(tmp_i(5)),tmp_values(k1)];
        end
    end
    if size(Pfgood,1) == 15
        break;
    end
end
if makecsv
    csvwrite(['Table_' model_names{model_type} '_goal' num2str(CandStates_set) '_epoch' num2str(dur_epoch) '_' num2str(k1) '.csv'], Pfgood);
end

% plot
if isempty(plotminmax)
    plotminmax = Pfminmax;
end
C = colormap;
tmp_k1end = [1 2 2];
for k1 = 1:tmp_k1end(model_type)
    F = figure;
    A = axes;
    hold on;
    axis([-1.5 1.5 -1.5 1.5]);
    set(A,'PlotBoxAspectRatio',[1 1 1]);
    P = plot([-1.5 1.5],[-1.5 1.5],'k--');
    P = plot([-1.5 1.5],[0 0],'k:');
    P = plot([0 0],[-1.5 1.5],'k:');
    for k2 = 1:5
        for k3 = 1:5
            for k4 = 1:5
                for k5 = 1:5
                    if (model_type==1) || ((model_type==2) && ((a_set(k2)/a_set(k3))>=(a_set(k4)/a_set(k5)))) ||...
                            ((model_type==3) && ((a_set(k2)/a_set(k3))<=(a_set(k4)/a_set(k5))))
                        tmp_value = (mean_data(k1,k2,k3,k4,k5)-plotminmax(1))/(plotminmax(2)-plotminmax(1));
                        tmp_color = C(max(1,ceil(tmp_value*64)),:);
                        if (k2~=k3) && (k4~=k5)
                            P = plot(log(a_set(k4)/a_set(k5)),log(a_set(k2)/a_set(k3)));
                            set(P,'Marker','x','MarkerSize',25,'LineWidth',5,'Color',tmp_color);
                        elseif (k2==k3) && (k4~=k5)
                            P = plot(log(a_set(k4)/a_set(k5)),log(a_set(k2)/a_set(k3)));
                            set(P,'Marker','o','MarkerSize',a_set(k2)*20,'LineWidth',1.5,'Color',tmp_color);
                        elseif (k2~=k3) && (k4==k5)
                            P = plot(log(a_set(k4)/a_set(k5)),log(a_set(k2)/a_set(k3)));
                            set(P,'Marker','o','MarkerSize',a_set(k4)*20,'LineWidth',1.5,'Color',tmp_color);
                        end
                    end
                end
            end
        end
    end
    set(A,'XTick',log([1/4 1/2 1 2 4]),'XTickLabel',[]);
    set(A,'YTick',log([1/4 1/2 1 2 4]),'YTickLabel',[]);
    if savefig
        print(F,'-depsc',['Figure9or11_' model_names{model_type} '_goal' num2str(CandStates_set) '_epoch' num2str(dur_epoch) '_' num2str(k1)]);
    end
end
