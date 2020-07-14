%{
Neurofeedback Visualization MKII
Desc: Plots entrainment neurofeedback
Author: Francisco Javier Carrera Arias
Date: 2/2/2020

Inputs: 
- plv_avg: The entrainment average between the two frequency bands of
interest as given by eggPLV_RT()
- baseline: The entrainment moving average baseline
%}

function Neurofeedback_Vis_II(plv_avg,baseline)
    % Frequency bands average bar plot
    visual = bar(plv_avg);
    visual.FaceColor = "flat";
    % Add baseline horizontal line to the plot
    yline(gca,baseline,'label',sprintf("%s: %s","Baseline",...
        string(round(baseline,2))),'LabelHorizontalAlignment','center');
    ydata = get(visual,'Ydata');
    set(visual,'Cdata',ydata,'EdgeColor','none')
    % Set up the color map
    colormap autumn;
    set(gcf,'color','w');
    set(gca,'Ylim',[0 1],'Xlim',[0 2], "YColor",[1 1 1],...
        'XColor',[1 1 1],'Color',[1 1 1],'CLim', [0 1]);
    % Create colorbar
    colorbar("YTick",[]);
    % Create title
    title(sprintf("Entrainment: %.2f",plv_avg))
    % Signals
    text(1.04,0.01,"-","Units","normalized","Fontsize",24)
    text(1.035,0.99,"+","Units","normalized","Fontsize",20)
end