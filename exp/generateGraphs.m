clear all;
close all;

filter = 'blur';

% 'hsl-full-if-99-0-0'
% 'hsl-empty-if-0-0-0

experiment = 'fixed-pixel-variable-size';
alpha = 0;
h = 0;
s = 0;
l = 0;

rawData = readtable('dataset.csv', 'Delimiter',',');

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

        handle = figure;
        subplot(1,2,1);
        size1 = 1;
        bar([1:100], c_0.min,size1,'blue');

        hold on
        size2 = size1/1.5;
        bar([1:100],asm1.min,size2,'red');

        hold on
        size3 = size2/2;
        bar([1:100],asm2.min,size3,'FaceColor',[0,0.4,0.4]);

        legend('C O0','ASM1','ASM2');
        xlabel('Image Id');
        ylabel('Clock Cycles');
        xlim([1 100]);
        title(sprintf('%s: Experiment %s', filter, experiment));
        %saveas(handle, strcat('results/',filter,'-',experiment,'.png'), 'png');
        
        c0_win   = sum((c_0.min < asm1.min) .* (c_0.min < asm2.min));
        asm1_win = sum((asm1.min < c_0.min) .* (asm1.min < asm2.min));
        asm2_win = sum((asm2.min < c_0.min) .* (asm2.min < asm1.min));
        
        %handle = figure;
        subplot(1,2,2);
        pie([c0_win, asm1_win, asm2_win])
        title('Fastest code for 100 images');
        
        labels = {};
        if c0_win > 0
            labels = [labels {'C -O0'}];
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
        %saveas(handle, strcat('results/',filter,'-',experiment,'_piechart.png'), 'png');

    end
    
    if strcmp(experiment, 'hsl-empty-if-0-0-0') || strcmp(experiment, 'hsl-full-if-99-0-0')
        
        
    end
    
	if strcmp(experiment, 'fixed-pixel-variable-size')
        handle = figure;
        plot(c_0.size.^2, c_0.min, c_3.size.^2, c_3.min, c_fast.size.^2, c_fast.min, asm1.size.^2, asm1.min, asm2.size.^2, asm2.min);
        legend('C -O0', 'C -O3', 'C -fastmath', 'ASM1','ASM2');
        xlabel('Pixels');
        ylabel('Clock Cycles');
        title(strcat(['Implementations of ', filter, label]));
        saveas(handle, strcat('results/',filter,'.png'), 'png');

        handle = figure;
        plot(c_0.size.^2, c_0.min./c_0.size.^2, c_3.size.^2, c_3.min./c_3.size.^2, c_fast.size.^2, c_fast.min./c_fast.size.^2, asm1.size.^2, asm1.min./asm1.size.^2, asm2.size.^2, asm2.min./asm2.size.^2);
        legend('C -O0', 'C -O3', 'C -fastmath', 'ASM1','ASM2');
        xlabel('Pixels');
        ylabel('Clock Cycles (linearized)');
        title(strcat(['Implementations of ', filter, label]));
        saveas(handle, strcat('results/lineal_',filter,label,'.png'), 'png');
	end
    
end