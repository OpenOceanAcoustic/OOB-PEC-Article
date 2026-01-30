clc; close all; clear all;

% 复制文件到当前目录
filename = 'MunkB_Coh_1';

copyfile(sprintf('../envs/3_ReciprocityAnalysis_Ray_Arr/%s*', filename), './');
filenamePR = sprintf('%sPR.env', filename);
filenameIR = sprintf('%sIR.env', filename);
filenamePA = sprintf('%sPA.env', filename);
filenameIA = sprintf('%sIA.env', filename);
filenamePP = sprintf('%sPP.env', filename);
filenameIP = sprintf('%sIP.env', filename);
if ~exist(filenameIR, 'file') || ~exist(filenamePP, 'file') || ~exist(filenamePR, 'file') || ~exist(filenamePA, 'file') || ~exist(filenameIA, 'file') || ~exist(filenameIP, 'file')
    error('文件不存在');
end
global units;
units = 'km';
isSaveFig = true;

% 环境缓慢变化情况下使用精确计算本征声线方法证明互异性成立

%% 对于声线，满足互易定理
oob(filenamePR);
oob(filenameIR);
figure;
plotray(sprintf('%s.ray', filenamePR(1:end-4)));
box on;
title('OOB');
axis tight;
set(gca, 'fontsize', 16, 'FontName', 'times new roman');
if exist(sprintf('%s.bty', filenamePR(1:end-4)), 'file')
    hold on;
    plotbty(sprintf('%s.bty', filenamePR(1:end-4)));
    % ylim([0 5000])
end
if (isSaveFig)
    saveas(gcf, sprintf('../figs/%s_ray_cpp.fig', filenamePR(1:end-4)));
    saveas(gcf, sprintf('../figs/%s_ray_cpp.png', filenamePR(1:end-4)));
    exportgraphics(gca,sprintf('../figs/%s_ray_cpp.pdf', filenamePR(1:end-4)));
end
figure;
plotray(sprintf('%s.ray', filenameIR(1:end-4)));
box on;
title('OOB');
axis tight;
set(gca, 'fontsize', 16, 'FontName', 'times new roman');
if exist(sprintf('%s.bty', filenameIR(1:end-4)), 'file')
    hold on;
    plotbty(sprintf('%s.bty', filenameIR(1:end-4)));
    % ylim([0 5000])
end
if (isSaveFig)
    saveas(gcf, sprintf('../figs/%s_ray_cpp.fig', filenameIR(1:end-4)));
    saveas(gcf, sprintf('../figs/%s_ray_cpp.png', filenameIR(1:end-4)));
    exportgraphics(gca,sprintf('../figs/%s_ray_cpp.pdf', filenameIR(1:end-4)));
end


%% 对于到达结构，满足互易定理
oob(filenamePA);
oob(filenameIA);
figure;
plotarrTB(sprintf('%s.arr', filenamePA(1:end-4)), 1, 1, 1);
title('OOB');
if (isSaveFig)
    saveas(gcf, sprintf('../figs/%s_arr_cpp.fig', filenamePA(1:end-4)));
    saveas(gcf, sprintf('../figs/%s_arr_cpp.png', filenamePA(1:end-4)));
    exportgraphics(gca,sprintf('../figs/%s_arr_cpp.pdf', filenamePA(1:end-4)));
end
figure;
plotarrTB(sprintf('%s.arr', filenameIA(1:end-4)), 1, 1, 1);
title('OOB');
if (isSaveFig)
    saveas(gcf, sprintf('../figs/%s_arr_cpp.fig', filenameIA(1:end-4)));
    saveas(gcf, sprintf('../figs/%s_arr_cpp.png', filenameIA(1:end-4)));
    exportgraphics(gca,sprintf('../figs/%s_arr_cpp.pdf', filenameIA(1:end-4)));
end

%% 对于声压，满足互易定理
oob(filenamePP);
oob(filenameIP);
[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure1 ] = read_shd( sprintf('%s_P.shd', filenamePP(1:end-4)) );
[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure2 ] = read_shd( sprintf('%s_P.shd', filenameIP(1:end-4)) );
pres1 = squeeze(pressure1);
pres2 = squeeze(pressure2);

diff_pres = pres1 - pres2;
pae = diff_pres / pres1;
diff_angle = angle(pres1) - angle(pres2);
diff_angle(diff_angle >  pi) = diff_angle(diff_angle >  pi) - 2*pi;
diff_angle(diff_angle < -pi) = diff_angle(diff_angle < -pi) + 2*pi;
diff_angle_pae = diff_angle / angle(pres1);

% 写入txt
filenamePAE = sprintf('../results/%s_PAE_cpp.txt', filenamePP(1:end-4));
fid = fopen(filenamePAE, 'w');
fprintf(fid, '对比项 实部  虚部  幅值  相位(rad)\n');
fprintf(fid, '互易前声压  %.12f  %.12f  %.12f  %.12f\n', real(pres1), imag(pres1), abs(pres1), angle(pres1));
fprintf(fid, '互易后声压  %.12f  %.12f  %.12f  %.12f\n', real(pres2), imag(pres2), abs(pres2), angle(pres2));
fprintf(fid, '声压差值  %.12f  %.12f  %.12f  %.12f\n', real(diff_pres), imag(diff_pres), abs(diff_pres), diff_angle);
fprintf(fid, '百分比误差  %12.4f%%  %12.4f%%  %.12f%%  %.12f%%\n', real(pae)*100, imag(pae)*100, abs(pae)*100, diff_angle_pae*100);
fclose(fid);

%% bellhopftr结果
%% 对于声线，满足互易定理
rewriteruntype(filenamePR);
rewriteruntype(filenameIR);

bellhop(filenamePR(1:end-4));
bellhop(filenameIR(1:end-4));
figure;
plotray(sprintf('%s.ray', filenamePR(1:end-4)));
box on;
title('Bellhop');
axis tight;
set(gca, 'fontsize', 16, 'FontName', 'times new roman');
if exist(sprintf('%s.bty', filenamePR(1:end-4)), 'file')
    hold on;
    plotbty(sprintf('%s.bty', filenamePR(1:end-4)));
    % ylim([0 5000])
end
if (isSaveFig)
    saveas(gcf, sprintf('../figs/%s_ray_ftr.fig', filenamePR(1:end-4)));
    saveas(gcf, sprintf('../figs/%s_ray_ftr.png', filenamePR(1:end-4)));
    exportgraphics(gca,sprintf('../figs/%s_ray_ftr.pdf', filenamePR(1:end-4)));
end
figure;
plotray(sprintf('%s.ray', filenameIR(1:end-4)));
box on;
title('Bellhop');   
axis tight;
set(gca, 'fontsize', 16, 'FontName', 'times new roman');
if exist(sprintf('%s.bty', filenameIR(1:end-4)), 'file')
    hold on;
    plotbty(sprintf('%s.bty', filenameIR(1:end-4)));
    % ylim([0 5000])
end
if (isSaveFig)
    saveas(gcf, sprintf('../figs/%s_ray_ftr.fig', filenameIR(1:end-4)));
    saveas(gcf, sprintf('../figs/%s_ray_ftr.png', filenameIR(1:end-4)));
    exportgraphics(gca,sprintf('../figs/%s_ray_ftr.pdf', filenameIR(1:end-4)));
end


%% 对于到达结构，满足互易定理
rewriteruntype(filenamePA);
rewriteruntype(filenameIA);

bellhop(filenamePA(1:end-4));
bellhop(filenameIA(1:end-4));
figure;
plotarrTB(sprintf('%s.arr', filenamePA(1:end-4)), 1, 1, 1);
title('Bellhop');
if (isSaveFig)
    saveas(gcf, sprintf('../figs/%s_arr_ftr.fig', filenamePA(1:end-4)));
    saveas(gcf, sprintf('../figs/%s_arr_ftr.png', filenamePA(1:end-4)));
    exportgraphics(gca,sprintf('../figs/%s_arr_ftr.pdf', filenamePA(1:end-4)));
end
figure;
plotarrTB(sprintf('%s.arr', filenameIA(1:end-4)), 1, 1, 1);
title('Bellhop');
if (isSaveFig)
    saveas(gcf, sprintf('../figs/%s_arr_ftr.fig', filenameIA(1:end-4)));
    saveas(gcf, sprintf('../figs/%s_arr_ftr.png', filenameIA(1:end-4)));
    exportgraphics(gca,sprintf('../figs/%s_arr_ftr.pdf', filenameIA(1:end-4)));
end
pause(5);
close all;

%% 对于声压，满足互易定理
rewriteruntype(filenamePP);
rewriteruntype(filenameIP);

bellhop(filenamePP(1:end-4));
bellhop(filenameIP(1:end-4));
[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure1 ] = read_shd( sprintf('%s.shd', filenamePP(1:end-4)) );
[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure2 ] = read_shd( sprintf('%s.shd', filenameIP(1:end-4)) );
pres1 = squeeze(pressure1);
pres2 = squeeze(pressure2);

diff_pres = pres1 - pres2;
pae = diff_pres / pres1;
diff_angle = angle(pres1) - angle(pres2);
diff_angle(diff_angle >  pi) = diff_angle(diff_angle >  pi) - 2*pi;
diff_angle(diff_angle < -pi) = diff_angle(diff_angle < -pi) + 2*pi;
diff_angle_pae = diff_angle / angle(pres1);

% 写入txt
filenamePAE = sprintf('../results/%s_PAE_ftr.txt', filenamePP(1:end-4));
fid = fopen(filenamePAE, 'w');
fprintf(fid, '对比项 实部  虚部  幅值  相位(rad)\n');
fprintf(fid, '互易前声压  %.12f  %.12f  %.12f  %.12f\n', real(pres1), imag(pres1), abs(pres1), angle(pres1));
fprintf(fid, '互易后声压  %.12f  %.12f  %.12f  %.12f\n', real(pres2), imag(pres2), abs(pres2), angle(pres2));
fprintf(fid, '声压差值  %.12f  %.12f  %.12f  %.12f\n', real(diff_pres), imag(diff_pres), abs(diff_pres), diff_angle);
fprintf(fid, '百分比误差  %12.4f%%  %12.4f%%  %.12f%%  %.12f%%\n', real(pae)*100, imag(pae)*100, abs(pae)*100, diff_angle_pae*100);
fclose(fid);

delete(sprintf('./%s*', filename));

function rewriteruntype(filename)
%该函数用来改变.env文件的运行类型项
fid = fopen(filename,'rt+');
i = 0;
newline = cell(1,999);
while ~feof(fid)
    tline = fgetl(fid);
    if ischar(tline)
        if contains(tline, "'1")
            tline = strrep(tline, "1", "E");
        elseif contains(tline, "'2")
            tline = strrep(tline, "2", "A");
        elseif contains(tline, "'3")
            tline = strrep(tline, "3", "C");
        end
    end

    i = i + 1;
    newline{i} = tline;
end


fclose(fid);
fid2 = fopen(filename,'wt+');
for k = 1: i
    fprintf(fid2,'%s\n',deblank(newline{k}));
end
fclose(fid2);
end