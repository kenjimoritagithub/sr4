% make_figureS1

% simulation
rand('twister',1164701);
b_set = [5 10];
g = 0.7;
dur_ini = 500;
dur_learning = 500;
view_yn = 0;
num_sub = 50;
num_sim = 100;
a_prop_set = [1/6 1/5 1/4 1/3 1/2 2/3 3/4 4/5 5/6];
a_sum = 1;
for k_b = 1:length(b_set)
    b = b_set(k_b);
    devalchoice_set{1}{k_b} = NaN(length(a_prop_set),num_sim,num_sub);
    devalchoice_set{2}{k_b} = NaN(length(a_prop_set),num_sim,num_sub);
    for k_sub = 1:num_sub
        for k_a_prop = 1:length(a_prop_set)
            a1 = a_sum * a_prop_set(k_a_prop);
            a2 = a_sum * (1 - a_prop_set(k_a_prop));
            for k_sim = 1:num_sim
                fprintf('%d-%d-%d-%d\n',k_b,k_sub,k_a_prop,k_sim);
                Out{1} = deval_SRIR([a1 a2 0.05],[a2 a1],b,g,dur_ini,dur_learning,mod(k_sim,2),view_yn);
                devalchoice_set{1}{k_b}(k_a_prop,k_sim,k_sub) = Out{1}.devalchoice;
                Out{2} = deval_IRIR([a1 a2;a2 a1],b,g,dur_ini,dur_learning,mod(k_sim,2),view_yn);
                devalchoice_set{2}{k_b}(k_a_prop,k_sim,k_sub) = Out{2}.devalchoice;
                if (k_b==1) && (k_sub==1) && (k_a_prop==8) && (k_sim==1)
                    intSVexamples{1} = Out{1}.intSV;
                    intSVexamples{2} = Out{2}.intSV;
                end
            end
        end
    end
end

% Figure S1C
tmp_letters = 'TB';
for k_model = 1:2
    for k_phase = 1:2
        F = figure;
        A = axes;
        hold on
        axis([0.5 3.5 0.5 3.5]);
        P = image(64*reshape(intSVexamples{k_model}{k_phase}([1:3 6:8 11:13]),3,3)');
        set(A,'PlotBoxAspectRatio',[1 1 1]);
        set(A,'Box','on');
        set(A,'XTick',[1:3],'XTickLabel',[1:3],'FontSize',40);
        set(A,'YTick',[1:3],'YTickLabel',[1:3],'FontSize',40);
        print(F,'-depsc',['FigureS1C-' tmp_letters(k_model) '_phase' num2str(k_phase)]);
    end
end
% colorbar
F = figure;
A = axes;
hold on;
P = colorbar;
set(P,'YTick',[1 33 65],'YTickLabel',[0 0.5 1],'FontSize',22);
print(F,'-depsc','FigureS1C_colorbar');

% Figure S1D
tmp_letters = 'LR';
for k_b = 1:length(b_set)
    F = figure;
    A = axes;
    hold on;
    axis([0 length(a_prop_set)+1 0 0.6]);
    P = plot([0 length(a_prop_set)+1],0.5*[1 1],'k:');
    P = errorbar([length(a_prop_set):-1:1],mean(mean(devalchoice_set{1}{k_b},2),3),std(mean(devalchoice_set{1}{k_b},2),0,3),'r');
    P = plot([length(a_prop_set):-1:1],mean(mean(devalchoice_set{1}{k_b},2),3),'r--');
    P = errorbar([length(a_prop_set):-1:1],mean(mean(devalchoice_set{2}{k_b},2),3),std(mean(devalchoice_set{2}{k_b},2),0,3),'b');
    P = plot([length(a_prop_set):-1:1],mean(mean(devalchoice_set{2}{k_b},2),3),'b--');
    set(A,'XTick',[1:length(a_prop_set)],'XTickLabel',[],'FontSize',20);
    set(A,'YTick',[0:0.1:0.6],'YTickLabel',[0:10:60],'FontSize',20);
    print(F,'-depsc',['FigureS1D-' tmp_letters(k_b)]);
end
