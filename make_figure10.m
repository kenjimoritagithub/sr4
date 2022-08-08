% make_figure8

% pseudo-random number
rand_twister = 120433001;
rand('twister',rand_twister);

% simulation
num_sim = 100;
Out{1} = distana(1,{[0.8 0.2 0.05],[0.8 0.2]},25,1,num_sim);
Out{2} = distana(1,{[0.2 0.8 0.05],[0.2 0.8]},25,1,num_sim);
Out{3} = distana(1,{[0.8 0.2 0.05],[0.2 0.8]},25,1,num_sim);
Out{4} = distana(1,{[0.2 0.8 0.05],[0.8 0.2]},25,1,num_sim);
Out{5} = distana(1,{[0.8 0.2 0.05],[0.2 0.8]},10,1,num_sim);
Out{6} = distana(1,{[0.8 0.2 0.05],[0.2 0.8]},10,2,num_sim);
Out{7} = distana(1,{[0.8 0.2 0.05],[0.2 0.8]},500,1,num_sim);
save(['data_distana_' num2str(rand_twister)],'Out');

% plot
tmp_letters = 'ABCDEFG';
for k = 1:7
    %
    F = figure;
    A = axes;
    hold on;
    if k == 7
        YTick = [0:100:500];
    else
        YTick = [0:5:30];
    end
    axis([-0.5 8.5 0 max(YTick)]);
    P = errorbar([0:8],Out{k}.mean_dist,Out{k}.sem_dist,'k');
    P = plot([0:8],Out{k}.mean_dist,'k--');
    set(A,'XTick',[0:8],'XTickLabel',[0:8],'FontSize',27);
    set(A,'YTick',YTick,'YTickLabel',YTick,'FontSize',27);
    print(F,'-depsc',['Figure10_' tmp_letters(k) '_top']);
    %
    F = figure;
    A = axes;
    hold on;
    axis([-0.5 8.5 0 175]);
    P = errorbar([0:8],Out{k}.mean_ave_time,Out{k}.sem_ave_time,'k');
    P = plot([0:8],Out{k}.mean_ave_time,'k--');
    set(A,'XTick',[0:8],'XTickLabel',[0:8],'FontSize',27);
    set(A,'YTick',[0:25:175],'YTickLabel',[0:25:175],'FontSize',27);
    print(F,'-depsc',['Figure10_' tmp_letters(k) '_bottom']);
end
