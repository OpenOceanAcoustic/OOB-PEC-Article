clc; close all;
% 以KRAKEN作为标准解，对比Bellhop和OOB计算的传播损失误差

%% 拷贝环境文件
filename = 'Munk';
% filename = 'Pekeris';
copyfile(sprintf('../envs/2_CalculationAccuracyAnalysis/%s*', filename), './');

%% KRAKEN 简正波方法
filenameK = [filename 'K'];

kraken(filenameK);
figure;
plotshd([filenameK '.shd'])

[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure1 ] = read_shd( [filenameK '.shd'] );
pres1 = squeeze(pressure1);
I1 = abs(pres1(2,:)).^2;
I1_smooth = smooth(I1,11);
TL1 = -20*log10(abs(I1_smooth));
% TL1_flat = smooth(TL1);


%% Bellhop 等角度解
filenameB = [filename 'BP.env'];
oob(filenameB);
figure;
plotshd([filenameB(1:end-4) '_P.shd'])
clim([50 100])

[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure2 ] = read_shd( [filenameB(1:end-4) '_P.shd'] );
pres2 = squeeze(pressure2);
I2 = abs(pres2(2,:)).^2;
I2_smooth = smooth(I2,11);
TL2 = -20*log10(abs(I2_smooth));
% TL2_flat = smooth(TL2);

%% OOB 精确计算解

filenameO = [filename 'BPC.env'];
oob(filenameO);
[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure3 ] = read_shd( [filenameO(1:end-4) '_P.shd'] );
pres3 = squeeze(pressure3);
I3 = abs(pres3).^2;
I3_smooth = smooth(I3,11);
TL3 = -20*log10(abs(I3_smooth));
% TL3_flat = smooth(TL3);

% %% OOB 精确计算解2D
% 
% filenameO = [filename 'BPC.env'];
% rdvec = 0:10:5000;
% presoob2d = zeros(length(Pos.r.r), length(rdvec));
% % presoob2d = zeros(2, length(rdvec));
% 
% for i = 1: length(rdvec)
%     rd = rdvec(i);
%     if (rd==0)
%         presoob2d(:,i) = 0;
%         continue;
%     end
%     fun_rewriteRd(filenameO, rd);
%     oob(filenameO);
%     [ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure3 ] = read_shd( [filenameO(1:end-4) '_P.shd'] );
%     presoob2d(:,i) = squeeze(pressure3);
% end
% TL3 = -20*log10(abs(pres));
% TL3_flat = smooth(TL3);

%% 后处理和画图
RMSE2 = sqrt(mean((TL1 - TL2).^2));
RMSE3 = sqrt(mean((TL1 - TL3).^2));
% RMSE2 = sqrt(mean((TL1_flat(1:end) - TL2_flat(1:end)).^2));
% RMSE3 = sqrt(mean((TL1_flat(1:end) - TL3_flat(1:end)).^2));
rr = Pos.r.r / 1e3;
figure;
plot(rr, TL1, 'k-', 'LineWidth', 2, 'displayname', 'KRAKEN Standard Solution');
hold on;
plot(rr, TL2, 'r--', 'LineWidth', 2, 'displayname', 'Bellhop Equal-Angle Solution');
plot(rr, TL3, 'b:', 'LineWidth', 2, 'displayname', 'OOB Precise Calculation Solution');
legend('location', 'best');
set(gca, 'FontName', 'Times new roman', 'fontsize', 16);
axis ij;
xlabel('Range (km)');
ylabel('TL (dB)');
title({filename; sprintf('Freq: %.1f Hz, Sd: %.1f m, Rd: %.1f m', freq0, Pos.s.z, Pos.r.z)});


saveas(gcf, sprintf('../figs/1_Pc_test_%s.fig', filename));
% saveas(gcf, sprintf('../paperFigs/1_Pc_test_%s.png', filename));
exportgraphics(gca,sprintf('../figs/1_Pc_test_%s.pdf', filename));

output.TL_KRAKEN = TL1;
output.TL_BELLHOP = TL2;
output.TL_OOB = TL3;
output.RMSE_OOB = RMSE3;
output.RMSE_BELLHOP = RMSE2;

% 将output输出到results文件夹，保存为json格式
jsonStr = jsonencode(output);
fid = fopen(sprintf('../results/%s_TL_R.json', filename), 'w');
fprintf(fid, '%s', jsonStr);
fclose(fid);

%% 删除
delete(sprintf('./%s*', filename));
delete('field.prt')