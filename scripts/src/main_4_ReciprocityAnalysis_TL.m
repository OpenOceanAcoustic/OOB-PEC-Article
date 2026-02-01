clc; clear; close all;
%% Reciprocity Analysis 互易性测试，将声源深度和接收深度互换，计算距离上的传播损失，对比bellhop和oob的结果
filename = 'Pekeris';
% filename = 'Munk';

% 拷贝环境文件
filenameBP = sprintf('%sBP', filename);
filenameBI = sprintf('%sBI', filename);
filenamePCP = sprintf('%sBPCP', filename);
filenamePCI = sprintf('%sBPCI', filename);
copyfile(['../envs/4_ReciprocityAnalysis_TL/' filenameBP '.env'], [filenameBP '.env']);
copyfile(['../envs/4_ReciprocityAnalysis_TL/' filenameBI '.env'], [filenameBI '.env']);
copyfile(['../envs/4_ReciprocityAnalysis_TL/' filenamePCP '.env'], [filenamePCP '.env']);
copyfile(['../envs/4_ReciprocityAnalysis_TL/' filenamePCI '.env'], [filenamePCI '.env']);

% kraken MunkK_D;
% bellhop MunkB_ray_D;
% bellhop MunkB_ray2_D;
% kraken MunkK;
bellhop(filenameBP);
bellhop(filenameBI);
oob(filenamePCP);
oob(filenamePCI);

% figure;
% [ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressureK ] = read_shd( ['MunkK.shd'] );
% 
% presk_abs = removedata(pressureK);
% TLk_flat = -20 * log10(presk_abs);
% TLk_flat = smooth(TLk_flat(2,:));

[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure1 ] = read_shd([filenamePCP '_P.shd'] ); %#ok<ASGLU>

pres1_abs = removedata(pressure1);
I1 = pres1_abs .^2;
I1_smooth = smooth(I1, 11);
TL1_flat = -10 * log10(I1_smooth);
% RMSE1 = sqrt(mean((TLk_flat - TL1_flat).^2));

[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure11 ] = read_shd([filenamePCI '_P.shd'] ); %#ok<ASGLU>

pres11_abs = removedata(pressure11);
I11 = pres11_abs .^2;
I11_smooth = smooth(I11, 11);
TL11_flat = -10 * log10(I11_smooth);
RMSE1 = sqrt(mean((TL1_flat - TL11_flat).^2));


[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure2 ] = read_shd([filenameBP '.shd'] );

pres2_abs = removedata(pressure2);
I2 = pres2_abs .^2;
I2_smooth = smooth(I2, 11);
TL2_flat = -10 * log10(I2_smooth);
TL2_flat = smooth(TL2_flat); 
% RMSE2 = sqrt(mean((TLk_flat - TL2_flat).^2));

[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure22 ] = read_shd([filenameBI '.shd'] );

pres22_abs = removedata(pressure22);
I22 = pres22_abs .^2;
I22_smooth = smooth(I22, 11);
TL22_flat = -10 * log10(I22_smooth);
TL22_flat = smooth(TL22_flat);
RMSE2 = sqrt(mean((TL2_flat - TL22_flat).^2));

% bellhop PekerisBPCC;
% bellhop PekerisBICC;
% [ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure3 ] = read_shd('PekerisBPCC.shd' );
% 
% pres3_abs = removedata(pressure3);
% I3 = pres3_abs .^2;
% I3_smooth = smooth(I3, 11);
% TL3_flat = -10 * log10(I3_smooth);
% TL3_flat = smooth(TL3_flat);
% RMSE13 = sqrt(mean((TL1_flat(10:end) - TL3_flat(10:end)).^2));
% 
% [ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure33 ] = read_shd('PekerisBICC.shd' );
% 
% pres33_abs = removedata(pressure33);
% I33 = pres33_abs .^2;
% I33_smooth = smooth(I33, 11);
% TL33_flat = -10 * log10(I33_smooth);
% TL33_flat = smooth(TL33_flat);
% RMSE3 = sqrt(mean((TL3_flat(10:end) - TL33_flat(10:end)).^2));


figure;
hold on;
% plot(Pos.r.r/1e3, TLk_flat, 'k--', LineWidth=1.5, DisplayName='KRAKEN Standard Solution');
plot(Pos.r.r/1e3, TL1_flat, 'b--', LineWidth=1.5, DisplayName='OOB+');
plot(Pos.r.r/1e3, TL11_flat, 'b:', LineWidth=1.5, DisplayName='OOB-');
plot(Pos.r.r/1e3, TL2_flat, 'r--', LineWidth=1.5, DisplayName='Bellhop+');
plot(Pos.r.r/1e3, TL22_flat, 'r:', LineWidth=1.5, DisplayName='Bellhop-');
% plot(Pos.r.r/1e3, TL3_flat, 'g--', LineWidth=1.5, DisplayName='Bellhop C+');
% plot(Pos.r.r/1e3, TL33_flat, 'g:', LineWidth=1.5, DisplayName='Bellhop C-');

legend();
set(gca, 'FontName', 'Times new roman');
axis ij;
xlabel('Range (km)');
ylabel('TL (dB)');
title(filename, ['RMSE(OOB): ', num2str(RMSE1, '%.2f') ,' dB' ,...
    '      ', 'RMSE(Bellhop): ', num2str(RMSE2, '%.2f')]);
% title(filename, ['RMSE(OOB): ', num2str(RMSE1, '%.2f') ,' dB' ,...
%     '      ', 'RMSE(Bellhop): ', num2str(RMSE2, '%.2f') ,' dB' ,...
%     '      ', 'RMSE(Bellhop C): ', num2str(RMSE3, '%.2f'), ' dB']);
% ylim([55 115])

saveas(gcf, sprintf('../figs/Reciprocity_TL_%s.fig', filename));

%% 删除env和计算结果文件
delete(sprintf('./%s*', filenameBP));
delete(sprintf('./%s*', filenameBI));
delete(sprintf('./%s*', filenamePCP));
delete(sprintf('./%s*', filenamePCI));
