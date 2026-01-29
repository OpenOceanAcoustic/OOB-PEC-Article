clc; clear;
% 计算bellhop和oob的传播损失和计算时间随精度d\alpha的变化

% 定义初始参数
NBeamsvec = round(logspace(3, 6, 8)); % 定义NBeams的范围（NBeams对应pi/dalpha，也就是定义精度）
timeBellhop = zeros(length(NBeamsvec),1);
timeOOB = zeros(length(NBeamsvec),1);

TLBellhop = zeros(length(NBeamsvec),1);
TLOOB = zeros(length(NBeamsvec),1);

% filename = 'Pekeris';
filename = 'Munk';
filepathBellhop = [filename 'BIP1'];
filepathOOB = [filename 'BIP2'];

% 从../envs中拷贝env文件
copyfile(['../envs/' filepathBellhop '.env'], [filepathBellhop '.env']);
copyfile(['../envs/' filepathOOB '.env'], [filepathOOB '.env']);

% 计算模块
for ib = 1:length(NBeamsvec)
    NBeams = NBeamsvec(ib);
    dalpha = pi./NBeams;

    fun_RewriteBellhop([filepathBellhop '.env'], NBeams);

    tic;
    bellhop(filepathBellhop);
    time1 = toc;
    timeBellhop(ib) = time1;

    % 定义文件路径
    fun_RewriteOOB([filepathOOB '.env'], dalpha);

    tic;
    oob(filepathOOB);
    time2 = toc;
    timeOOB(ib) = time2;

    [ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure1 ] = read_shd( [filepathBellhop '.shd'] );

    pres1_abs = squeeze(abs(pressure1));
    TLBellhop(ib) = -20 * log10(pres1_abs);

    [ PlotTitle, PlotType, freqVec, freq0, atten, Pos, pressure2 ] = read_shd( [filepathOOB '_P.shd'] );

    pres2_abs = squeeze(abs(pressure2));
    TLOOB(ib) = -20 * log10(pres2_abs);
end


% 绘制传播损失收敛曲线
figure;
hold on;
semilogx(180./NBeamsvec,TLBellhop,'b-*', LineWidth=1.5, DisplayName='Bellhop');
semilogx(180./NBeamsvec,TLOOB,'r-o', LineWidth=1.5, DisplayName='OOB');
set(gca, 'XScale', 'log', 'XDir', 'reverse', 'YDir', 'reverse');
legend();
set(gca, 'FontName', 'Times new roman');
xlabel('$d\alpha$ ($^\circ$)','Interpreter','latex','FontSize',12);
ylabel('TL (dB)', ...
    'FontName', 'Times New Roman', ...
    'FontSize', 12, ...
    'Interpreter', 'latex');
saveas(gcf, sprintf('../figs/%s_TL_Curve.fig', filename));

% 绘制运行时间曲线
figure;
hold on;
loglog(180./NBeamsvec,timeBellhop,'b-*', LineWidth=1.5, DisplayName='Bellhop');
loglog(180./NBeamsvec,timeOOB,'r-o', LineWidth=1.5, DisplayName='OOB');
set(gca, 'XScale', 'log', 'YScale', 'log', 'XDir', 'reverse');
legend();
set(gca, 'FontName', 'Times new roman');
xlabel('$d\alpha$ ($^\circ$)','Interpreter','latex','FontSize',12);
ylabel('time (s)', ...
    'FontName', 'Times New Roman', ...
    'FontSize', 12, ...
    'Interpreter', 'latex');
saveas(gcf, sprintf('../figs/%s_Runtime_Curve.fig', filename));

% 删除env和计算结果文件
delete(sprintf('./%s*', filepathBellhop));
delete(sprintf('./%s*', filepathOOB));
