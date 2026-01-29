clc; clear all; close all;
% 在Munk场景，以KRAKEN为标准解，对比不同波束数和接收深度下，Bellhop等角度解和OOB精确计算解的传播损失误差

% 初始化参数


NBeamsvec = [500 1000] %5000 10000 50000];
filename = 'Pekeris';
% filename = 'Munk';
intersect_y = 3; % RMSE容限
intersect_xvec = zeros(size(NBeamsvec));

% 拷贝环境文件
filenameK = sprintf('%sK_BA2', filename);
filenameB = sprintf('%sBIP_BA2', filename);
filenameO = sprintf('%sBPC_BA2', filename);
copyfile(sprintf('../envs/%s.env', filenameK), './');
copyfile(sprintf('../envs/%s.flp', filenameK), './');
copyfile(sprintf('../envs/%s.env', filenameB), './');
copyfile(sprintf('../envs/%s.env', filenameO), './');


kraken(filenameK);
bellhop(filenameB);
% oob(filenameO);

figure;
plotshd([filenameK '.shd'])
figure;
plotshd([filenameB '.shd'])
% figure;
% plotshd([filenameO '_P.shd'])

[ PlotTitle, PlotType, freqVec, freq0, atten, Pos1, pressure1 ] = read_shd( [filenameK '.shd'] );

NRr = length(Pos1.r.r);
RdVec = Pos1.r.z;
RMSEvec1 = zeros(length(RdVec), length(NBeamsvec));
RMSEvec2 = zeros(length(RdVec), length(NBeamsvec));

pres_kraken = zeros(length(RdVec), NRr);
pres_bellhop = zeros(length(RdVec)* length(NBeamsvec), NRr);
pres_oob = zeros(length(RdVec)* length(NBeamsvec), NRr);

TL_kraken = zeros(length(RdVec), NRr);
TL_bellhop = zeros(length(RdVec)* length(NBeamsvec), NRr);
TL_oob = zeros(length(RdVec)* length(NBeamsvec), NRr);


for ib = 1:length(NBeamsvec)
    NBeams = NBeamsvec(ib);
    fun_RewriteBellhop([filenameB '.env'], NBeams);
    bellhop(filenameB);

    [ PlotTitle, PlotType, freqVec, freq0, atten, Pos1, pressure2 ] = read_shd( [filenameB '.shd'] );

    fun_RewriteBellhop([filenameO '.env'], NBeams);
    oob([filenameO '.env']);
    [ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure3 ] = read_shd( [filenameO '_P.shd'] );

    for i = 1: length(RdVec)
        Rd = RdVec(i);

        [~, index] = min(abs(Pos1.r.z - Rd));

        pres_kraken(i,:) = squeeze(pressure1(1,1,index,:));
        pres1_abs = removedata(pres_kraken(i,:));
        I1 = pres1_abs.^2;
        I1_smooth = smooth(I1,11);
        TL1_flat = -10*log10(abs(I1_smooth));
        TL_kraken(i,:) = TL1_flat;

        pres_bellhop((ib-1)*length(RdVec)+i,:) = squeeze(pressure2(1,1,index,:));
        pres2_abs = removedata(pres_bellhop((ib-1)*length(RdVec)+i,:));
        I2 = pres2_abs.^2;
        I2_smooth = smooth(I2,11);
        TL2_flat = -10*log10(abs(I2_smooth));
        TL_bellhop((ib-1)*length(RdVec)+i,:) = TL2_flat;


        pres_oob((ib-1)*length(RdVec)+i,:) = squeeze(pressure3(1,1,index,:));
        pres3_abs = removedata(pres_oob((ib-1)*length(RdVec)+i,:));
        I3 = pres3_abs.^2;
        I3_smooth = smooth(I3,11);
        TL3_flat = -10*log10(abs(I3_smooth));
        TL_oob((ib-1)*length(RdVec)+i,:) = TL3_flat;

        RMSEvec1(i,ib) = sqrt(mean((TL1_flat - TL2_flat).^2));
        RMSEvec2(i,ib) = sqrt(mean((TL3_flat - TL1_flat).^2));

    end
end

% for i = 1: length(RdVec)
%     figure;
%     hold on;
%     plot(Pos.r.r/1e3, TL_kraken(i,:), DisplayName='kraken')
%     for ib = 1:length(NBeamsvec)
%         plot(Pos.r.r/1e3, TL_bellhop((ib-1)*length(RdVec)+i,:), DisplayName=sprintf('Bellhop NBeams=%.1f k', NBeamsvec(ib)))
% 
%     end
%     for ib = 1:length(NBeamsvec)
%         plot(Pos.r.r/1e3, TL_oob((ib-1)*length(RdVec)+i,:), DisplayName=sprintf('OOB NBeams=%.1f k', NBeamsvec(ib)))
%     end
%     legend()
% end
% 



% 画图
figure;
hold on;

% ========== 定义颜色（5×3 矩阵）==========
% 冷色系（蓝/青/绿）
colors_cool = [0 0.4470 0.7410;      % 深蓝
    0.3010 0.7450 0.9330; % 天蓝
    0 0.75 0.75;          % 青色
    0.4660 0.6740 0.1880; % 浅绿
    0.4940 0.1840 0.5560];% 紫色

% 暖色系（红/橙/黄）
colors_warm = [0.8500 0.3250 0.0980; % 橙红
    0.9290 0.6940 0.1250; % 金黄
    0.6350 0.0780 0.1840; % 深红
    0.75 0.5 0;           % 橙色
    0.75 0.75 0];         % 黄绿

% 标记符号
markers = {'v', '^', 'p', 'd', 'o'};

% ========== 绘图循环 ==========
for ib = 1:length(NBeamsvec)
    NBeams = NBeamsvec(ib);

    % Bellhop（冷色）
    h(ib) = plot(RdVec, RMSEvec1(:,ib), ...
        'Color', colors_cool(ib,:), ...
        'Marker', markers{ib}, ...
        'LineStyle', '-', ...
        'LineWidth', 1.5, ...
        'DisplayName', sprintf('Bellhop (Nb=%dk)', NBeams/1e3));

    % OOB（暖色）
    h2(ib) = plot(RdVec, RMSEvec2(:,ib), ...
        'Color', colors_warm(ib,:), ...
        'Marker', markers{ib}, ...
        'LineStyle', '-', ...
        'LineWidth', 1.5, ...
        'DisplayName', sprintf('OOB (Nb=%dk)', NBeams/1e3));
end

axis ij;
xlabel('Receiver Depth (m)');
ylabel('TL RMSE (dB)');
set(gca, 'FontName', 'Times new roman');

% 3dB参考线
plot(RdVec, 3*ones(size(RdVec)), 'k--', 'LineWidth', 1.5);

% 交点标记
for ib = 1:length(NBeamsvec)
    intersect_xvec(ib) = myinterp1(RMSEvec1(:,ib), RdVec, intersect_y);
    plot(intersect_xvec(ib), intersect_y, 'ko', 'MarkerSize', 5, 'LineWidth', 1.0);
end

axis ij;
axis tight;

% ========== 图例（左列冷色/Bellhop，右列暖色/OOB）==========
h = h(:)';
h2 = h2(:)';
str1 = arrayfun(@(x) sprintf('Bellhop (Nb=%dk)', x/1e3), NBeamsvec, 'UniformOutput', false);
str2 = arrayfun(@(x) sprintf('OOB (Nb=%dk)', x/1e3), NBeamsvec, 'UniformOutput', false);

h_all = [h, h2];
str_all = [str1, str2];

legend(h_all, str_all, 'Location', 'northoutside', 'NumColumns', 2, ...
    'FontName', 'Times New Roman');

saveas(gcf, sprintf('../figs/Boundary%s.fig', filenameO));

% 删除env和计算结果文件
delete(sprintf('./%s*', filenameK));
delete(sprintf('./%s*', filenameB));
delete(sprintf('./%s*', filenameO));
delete('field.prt');
