function fun_compareRcpTL(filename, isSaveFig, isClearFile)
copyfile(sprintf('../5rcprcty/%s*', filename), './');
filenamePP = sprintf('%sPP.env', filename);
filenameIP = sprintf('%sIP.env', filename);
if ~exist(filenamePP, 'file') || ~exist(filenameIP, 'file')
    error('文件不存在');
end


%% 对于声压，满足互易定理
oobPC(filenamePP);

RR_vec = 0.1:0.1:10;
S_wd_vec = - 20 * RR_vec + 300;
interp_type = 'L';
pres2 = zeros(size(RR_vec));
for i = 1: length(RR_vec)
    RR = RR_vec(i);
    S_wd = S_wd_vec(i);
    rngdpt(:,1) = [0 RR];
    rngdpt(:,2) = [S_wd 300];
    writebdry(sprintf('%s.bty', filenameIP(1:end-4)), interp_type, rngdpt);
    rewriteRR(filenameIP, RR);
    oobPC(sprintf('%s.env', filenameIP(1:end-4)));
    [ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure2 ] = read_shd( sprintf('%s_P.shd', filenameIP(1:end-4)) );
    pres2(i) = squeeze(pressure2);
end
[ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure1 ] = read_shd( sprintf('%s_P.shd', filenamePP(1:end-4)) );
pres1 = squeeze(pressure1);
pres1 = removedata(pres1);
pres2 = removedata(pres2);

TL1 = - 20 * log10(abs(pres1));
TL2 = - 20 * log10(abs(pres2));
figure;
plot(Pos.r.r, TL1, 'b--', Pos.r.r, TL2, 'r:');
title('OpenOceanBellhop');
xlabel('Range (km)');
ylabel('TL (dB)');
legend('互易前声压', '互易后声压');
axis ij;
axis tight;
saveas(gcf, sprintf('../figs/%s_TL.fig', filenamePP(1:end-4)));
saveas(gcf, sprintf('../figs/%s_TL.png', filenamePP(1:end-4)));
exportgraphics(gca,sprintf('../figs/%s_TL.pdf', filenamePP(1:end-4)));
rmseTL = sqrt(mean((TL1 - TL2).^2));
fprintf('TL RMSE: %.4f dB\n', rmseTL);

%%
delete(sprintf('./%s*', filename));
end

function presout = removedata(presin)
presin = squeeze(presin);
presd = double( abs( presin(:) ) );   % pcolor needs 'double' because field.m produces a single precision
presd( isnan( presd ) ) = 1e-6;   % remove NaNs
presd( isinf( presd ) ) = 1e-6;   % remove infinities

presd( presd < 1e-12 ) = 1e-12;          % remove zeros
presout = presd;
end

function rewriteRR(filename, RR)
%该函数用来改变.env文件的接收距离项
fid = fopen(filename,'rt+');
i = 0;
newline = cell(1,999);
while ~feof(fid)
    tline = fgetl(fid);
    i = i + 1;
    newline{i} = tline;
    if i == 15
        newline{i} = sprintf('  %10.4f  /			! R(1:NR ) (km)', RR);
    end
end
fclose(fid);
fid2 = fopen(filename,'wt+');
for k = 1: i
    fprintf(fid2,'%s\n',deblank(newline{k}));
end
fclose(fid2);
end