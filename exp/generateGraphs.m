clear all;
close all;
set(gcf, 'Visible', 'off');
set(0,'DefaultFigureVisible','off');

alpha = 0;
h = 0;
s = 0;
l = 0;

for experiments = {'random-uniform-pixel-fixed-size','random-pixel-fixed-size','fixed-pixel-variable-size','hsl-force-last-if'}
experiment = experiments{1};

rawData = readtable('dataset.csv', 'Delimiter',',');

if ~strcmp(experiment, 'hsl-force-first-if') && ~ strcmp(experiment, 'hsl-force-last-if')
for filter = {'blur','merge','hsl'}

    filter = filter{1};

	data = rawData(strcmp(rawData.experiment, experiment) & ...
                strcmp(rawData.filter, filter),:);
	data = sortrows(data,'size','ascend');

    % load data
    if strcmp(filter, 'blur')
        label = '';
        c_0 = data(strcmp(data.language, 'c') & ...
              strcmp(data.make_param, 'o0'), :);
        c_3 = data(strcmp(data.language, 'c') & ...
              strcmp(data.make_param, 'o3'), :);
        c_fast = data(strcmp(data.language, 'c') & ...
                 strcmp(data.make_param, 'o3fast'), :);
        asm1 = data(strcmp(data.language, 'asm1') & ...
              strcmp(data.make_param, 'o0'), :);
        asm2 = data(strcmp(data.language, 'asm2') & ...
              strcmp(data.make_param, 'o0'), :);
    elseif strcmp(filter, 'merge')
        label = sprintf(' (a: %f)', alpha);
        constraint = data.alpha == 0;
        c_0 = data(strcmp(data.language, 'c') & constraint & ...
              strcmp(data.make_param, 'o0'), :);
        c_3 = data(strcmp(data.language, 'c') & constraint & ...
              strcmp(data.make_param, 'o3'), :);
        c_fast = data(strcmp(data.language, 'c') & constraint & ...
                 strcmp(data.make_param, 'o3fast'), :);
        asm1 = data(strcmp(data.language, 'asm1') & constraint & ...
              strcmp(data.make_param, 'o0'), :);
        asm2 = data(strcmp(data.language, 'asm2') & constraint & ...
              strcmp(data.make_param, 'o0'), :);
    elseif strcmp(filter, 'hsl')
        label = sprintf(' (h: %u, s:%u, l:%u)', h, s, l);
        constraint = data.h == h & data.s == s & data.l == l;
        c_0 = data(strcmp(data.language, 'c') & constraint & ...
              strcmp(data.make_param, 'o0'), :);
        c_3 = data(strcmp(data.language, 'c') & constraint & ...
              strcmp(data.make_param, 'o3'), :);
        c_fast = data(strcmp(data.language, 'c') & constraint & ...
                 strcmp(data.make_param, 'o3fast'), :);
        asm1 = data(strcmp(data.language, 'asm1') & constraint & ...
              strcmp(data.make_param, 'o0'), :);
        asm2 = data(strcmp(data.language, 'asm2') & constraint & ...
              strcmp(data.make_param, 'o0'), :);
    else
         error('Invalid filter!');
    end

    % generate graphs
    if strcmp(experiment, 'random-uniform-pixel-fixed-size') || ...
            strcmp(experiment, 'random-pixel-fixed-size')

        % standalone barchart
        handle = figure;
        size1 = 1;
        bar([1:100], c_fast.min,size1,'blue');

        hold on
        size2 = size1/1.5;
        bar([1:100],asm1.min,size2,'red');

        hold on
        size3 = size2/2;
        bar([1:100],asm2.min,size3,'FaceColor',[0,0.4,0.4]);

        legend('C -O3 ffast-math','ASM1','ASM2','Location','southoutside','Orientation','horizontal')
        xlabel('Image Id');
        ylabel('Clock Cycles');
        xlim([1 100]);
        title(sprintf('%s: Experiment %s', filter, experiment));
        saveas(handle, strcat('results/',filter,'-',experiment,'_alone.png'), 'png');
        
        % joint
        handle = figure;
        subplot(1,2,1);
        size1 = 1;
        bar([1:100], c_fast.min,size1,'blue');

        hold on
        size2 = size1/1.5;
        bar([1:100],asm1.min,size2,'red');

        hold on
        size3 = size2/2;
        bar([1:100],asm2.min,size3,'FaceColor',[0,0.4,0.4]);

        legend('C -O3 ffast-math','ASM1','ASM2','Location','southoutside','Orientation','horizontal')
        xlabel('Image Id');
        ylabel('Clock Cycles');
        xlim([1 100]);
        title(sprintf('%s: Experiment %s', filter, experiment));

        c_fast_win   = sum((c_fast.min < asm1.min) .* (c_fast.min < asm2.min));
        asm1_win = sum((asm1.min < c_fast.min) .* (asm1.min < asm2.min));
        asm2_win = sum((asm2.min < c_fast.min) .* (asm2.min < asm1.min));
        
        subplot(1,2,2);
        
        pie([c_fast_win, asm1_win, asm2_win])
        title('Fastest code for 100 images');
        
        labels = {};
        if c_fast_win > 0
            labels = [labels {'C -O3 ffast-math'}];
        end
        if asm1_win > 0
            labels = [labels {'ASM1'}];
        end
        if asm2_win > 0
            labels = [labels {'ASM2'}];
        end
        
        legend(labels,'Location','southoutside','Orientation','horizontal')
        hold off
        saveas(handle, strcat('results/',filter,'-',experiment,'.png'), 'png');

        base = sum(c_3.min);
        c0_t     = sum(c_0.min) / base;
        c_fast_t = sum(c_fast.min)/ base;
        asm1_t   = sum(asm1.min)  / base;
        asm2_t   = sum(asm2.min)  / base;
        
        % replace graph
        subplot(1,2,2);
        bar([1, c_fast_t, asm1_t, asm2_t]);
        labels = {'C -O3', 'C -O3 ffastmath', 'ASM1', 'ASM2'};
        set(gca, 'XTick', 1:4, 'XTickLabel', labels);
        title(strcat([filter, ': relative performance in respect to -03']));
        saveas(handle, strcat('results/',filter,'-',experiment,'_bar.png'), 'png');

        % independent graph
        handle = figure;
        bar([1, c_fast_t, asm1_t, asm2_t]);
        labels = {'C -O3', 'C -O3 ffastmath', 'ASM1', 'ASM2'};
        set(gca, 'XTick', 1:4, 'XTickLabel', labels);
        title(strcat([filter, ': relative performance in respect to -03']));
        saveas(handle, strcat('results/',filter,'-',experiment,'_barchart.png'), 'png');
        
    end
    
	if strcmp(experiment, 'fixed-pixel-variable-size')
        handle = figure;
        plot(c_3.size.^2, c_3.min, c_fast.size.^2, c_fast.min, asm1.size.^2, asm1.min, asm2.size.^2, asm2.min);
        legend('C -O3', 'C -fastmath', 'ASM1','ASM2','Location','southoutside','Orientation','horizontal')
        xlabel('Pixels');
        ylabel('Clock Cycles');
        title(strcat(['Implementations of ', filter, label]));
        saveas(handle, strcat('results/',filter,'.png'), 'png');

        handle = figure;
        plot(c_3.size.^2, c_3.min./c_3.size.^2, c_fast.size.^2, c_fast.min./c_fast.size.^2, asm1.size.^2, asm1.min./asm1.size.^2, asm2.size.^2, asm2.min./asm2.size.^2);
        legend('C -O3', 'C -fastmath', 'ASM1','ASM2','Location','southoutside','Orientation','horizontal')
        xlabel('Pixels');
        ylabel('Clock Cycles (linearized)');
        title(strcat(['Implementations of ', filter, label]));
        saveas(handle, strcat('results/lineal_',filter,label,'.png'), 'png');
	end
    
end
end

if strcmp(experiment, 'hsl-force-first-if') || strcmp(experiment, 'hsl-force-last-if')
        
	% load data
	data_first = rawData(strcmp(rawData.experiment, 'hsl-force-first-if') & ...
	strcmp(rawData.filter, 'hsl'),:);
	data_first = sortrows(data_first,'size','ascend');
        
	data_last = rawData(strcmp(rawData.experiment, 'hsl-force-first-if') & ...
	strcmp(rawData.filter, 'hsl'),:);
	data_last = sortrows(data_last,'size','ascend');
        
	% first if series
	c_0 = data_first(strcmp(data_first.language, 'c') & ...
              strcmp(data_first.make_param, 'o0'), :);
	c_3 = data_first(strcmp(data_first.language, 'c') & ...
              strcmp(data_first.make_param, 'o3'), :);
	c_fast = data_first(strcmp(data_first.language, 'c') & ...
                 strcmp(data_first.make_param, 'o3fast'), :);
	asm1 = data_first(strcmp(data_first.language, 'asm1') & ...
              strcmp(data_first.make_param, 'o0'), :);
	asm2 = data_first(strcmp(data_first.language, 'asm2') & ...
              strcmp(data_first.make_param, 'o0'), :);
        
	% last if
	% first if series
	c_0_l = data_last(strcmp(data_last.language, 'c') & ...
              strcmp(data_last.make_param, 'o0'), :);
 	c_3_l = data_last(strcmp(data_last.language, 'c') & ...
              strcmp(data_last.make_param, 'o3'), :);
	c_fast_l = data_last(strcmp(data_last.language, 'c') & ...
                 strcmp(data_last.make_param, 'o3fast'), :);
	asm1_l = data_last(strcmp(data_last.language, 'asm1') & ...
              strcmp(data_last.make_param, 'o0'), :);
	asm2_l = data_last(strcmp(data_last.language, 'asm2') & ...
              strcmp(data_last.make_param, 'o0'), :);
          
	handle = figure;
	plot(c_0.size.^2, c_0.min, c_3.size.^2, c_3.min, c_fast.size.^2, c_fast.min, asm1.size.^2, asm1.min, asm2.size.^2, asm2.min);
	legend('C -O0', 'C -O3', 'C -fastmath', 'ASM1','ASM2','Location','southoutside','Orientation','horizontal')
	xlabel('Pixels');
	ylabel('Clock Cycles');
	title('Implementations of hsl (first if)');
	saveas(handle, strcat('results/hsl_firstif.png'), 'png');

	handle = figure;
	plot(c_0.size.^2, c_0.min./c_0.size.^2, c_3.size.^2, c_3.min./c_3.size.^2, c_fast.size.^2, c_fast.min./c_fast.size.^2, asm1.size.^2, asm1.min./asm1.size.^2, asm2.size.^2, asm2.min./asm2.size.^2);
	legend('C -O0', 'C -O3', 'C -fastmath', 'ASM1','ASM2','Location','southoutside','Orientation','horizontal')
	xlabel('Pixels');
	ylabel('Clock Cycles (linearized)');
	title('Implementations of hsl (first if)');
	saveas(handle, strcat('results/lineal_hsl_firstif.png'), 'png');
        
	handle = figure;
	plot(c_0.size.^2, c_0.min, c_3.size.^2, c_3.min, c_fast.size.^2, c_fast.min, asm1.size.^2, asm1.min, asm2.size.^2, asm2.min, ...
             c_0_l.size.^2, c_0_l.min, c_3_l.size.^2, c_3_l.min, c_fast_l.size.^2, c_fast_l.min, asm1_l.size.^2, asm1_l.min, asm2_l.size.^2, asm2_l.min);
	legend('C -O0 fif', 'C -O3 fif', 'C -fastmath fif', 'ASM1 fif','ASM2 fif','C -O0 lif', 'C -O3 lif', 'C -fastmath lif', 'ASM1 lif','ASM2 lif', 'Location','southoutside','Orientation','horizontal');
	xlabel('Pixels');
	ylabel('Clock Cycles');
	title('First if vs. Last if');
	saveas(handle, strcat('results/hsl_comp.png'), 'png');
        
end

end % end exp loop