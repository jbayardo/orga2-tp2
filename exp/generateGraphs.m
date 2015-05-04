clear all;
close all;

filter = 'hsl';
experiment = 'fixed';
alpha = 0;
h = 0;
s = 0;
l = 0;

for filter = {'blur','merge','hsl'}

    filter = filter{1};
    
    rawData = readtable('todos_hsl_mascaras_O0.csv', 'Delimiter',',');

    data = rawData(strcmp(rawData.experiment, experiment) & ...
                        strcmp(rawData.filter, filter),:);
    data = sortrows(data,'width','ascend');

    if strcmp(filter, 'blur')
        
        label = '';
        c    = data(strcmp(data.language, 'c'),    [8,14]);
        asm1 = data(strcmp(data.language, 'asm1'), [8,14]);
        asm2 = data(strcmp(data.language, 'asm2'), [8,14]);
    elseif strcmp(filter, 'merge')
        label = sprintf(' (a: %f)', alpha);
        constraint = data.alpha == 0;
        c    = data(strcmp(data.language, 'c')    & constraint, [8,14]);
        asm1 = data(strcmp(data.language, 'asm1') & constraint, [8,14]);
        asm2 = data(strcmp(data.language, 'asm2') & constraint, [8,14]); 
    elseif strcmp(filter, 'hsl')
        label = sprintf(' (h: %u, s:%u, l:%u)', h, s, l);
        constraint = data.h == h & data.s == s & data.l == l;
        c    = data(strcmp(data.language, 'c')    & constraint, [8,14]);
        asm1 = data(strcmp(data.language, 'asm1') & constraint, [8,14]);
        asm2 = data(strcmp(data.language, 'asm2') & constraint, [8,14]); 
    else
         error('Invalid filter!');
    end

    handle = figure;
    plot(c.width.^2, c.mean, asm1.width.^2, asm1.mean, asm2.width.^2, asm2.mean);
    legend('C','ASM1','ASM2');
    xlabel('Pixels');
    ylabel('Clock Cycles');
    title(strcat(['Implementations of ', filter, label]));
    saveas(handle, strcat('results/',filter,'.png'), 'png');

    handle = figure;
    plot(c.width.^2, c.mean./c.width.^2, asm1.width.^2, asm1.mean./asm1.width.^2, asm2.width.^2, asm2.mean./asm2.width.^2);
    legend('C','ASM1','ASM2');
    xlabel('Pixels');
    ylabel('Clock Cycles (linearized)');
    title(strcat(['Implementations of ', filter, label]));
    saveas(handle, strcat('results/lineal_',filter,label,'.png'), 'png');

end