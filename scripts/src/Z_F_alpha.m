clc; close all; clear;
% 绘制R-Z图，展示不同入射角下的声线传播路径
%% 自由场条件
% 初始化参数
z_r = 100;
r_r = 100;
z_s = 0;
alpha = 30:5:60;
Fa = z_s + r_r * tand(alpha) - z_r;
r = 0:110;
z = z_s + tand(alpha).' * r;
figure;
h(1) = plot(0, z_s, 'r*', markersize=9, DisplayName='Source');
hold on;
h(2) = plot(r_r, z_r, 'bp', markersize=10, DisplayName='Receiver');
for i = 1: length(alpha)
    h(2+i) = plot(r, z(i,:), DisplayName=sprintf('alpha=%d°', alpha(i)));
end
plot([100 100], [0 200], 'r--')
xlabel('Range (m)')
ylabel('Depth (m)')

set(gca, 'fontsize', 16)
legend(h, 'Location', 'northwest', 'FontSize', 12);
% saveas(gcf, '../figs/R-Z-Alpha.fig')
% saveas(gcf, '../figs/R-Z-Alpha.png')

figure;
plot(alpha, Fa)
hold on;
plot([30 60], [0 0], 'r--')
xlabel('\alpha (°)')
ylabel('F(\alpha) (m)')
set(gca, 'fontsize', 16)
% saveas(gcf, '../figs/F-Alpha.fig')
% saveas(gcf, '../figs/F-Alpha.png')


%% 海面罗埃镜
alpha = 30:5:80;
D = 200;
r = 0:110;
z = z_s + tand(alpha).' * r;
z(z>D) = 2*D - z(z>D);

[~,index] = min(abs(r- r_r));
Fa = z_s + z(:,index) - z_r;



figure;
h(1) = plot(0, z_s, 'r*', markersize=9, DisplayName='Source');
hold on;
h(2) = plot(r_r, z_r, 'bp', markersize=10, DisplayName='Receiver');
for i = 1: length(alpha)
    h(2+i) = plot(r, z(i,:), DisplayName=sprintf('alpha=%d°', alpha(i)));
end
plot([100 100], [0 200], 'r--')
xlabel('Range (m)')
ylabel('Depth (m)')

set(gca, 'fontsize', 16)
legend(h, 'Location', 'northwest', 'FontSize', 12);
% saveas(gcf, '../R-Z-Alpha-Bc200m_2.fig')
% saveas(gcf, '../R-Z-Alpha-Bc200m_2.png')

figure;
plot(alpha, Fa)
hold on;
plot([30 80], [0 0], 'r--')
xlabel('\alpha (°)')
ylabel('F(\alpha) (m)')
set(gca, 'fontsize', 16)
% saveas(gcf, './F-Alpha-Bc200m_2.fig')
% saveas(gcf, './F-Alpha-Bc200m_2.png')

%% 海面海底条件
alpha = [30:5:80 84];
r = 0:110;
z = z_s + tand(alpha).' * r;
z(z>200) = 400 - z(z>200);
z(z<-200) = -400 - z(z<-200);
z(z>200) = 400 - z(z>200);

Fa = z_s + z(:,index) - z_r;


figure;
h(1) = plot(0, z_s, 'r*', markersize=9, DisplayName='Source');
hold on;
h(2) = plot(r_r, z_r, 'bp', markersize=10, DisplayName='Receiver');
for i = 1: length(alpha)
    h(2+i) = plot(r, z(i,:), DisplayName=sprintf('alpha=%d°', alpha(i)));
end
plot([100 100], [-200 200], 'r--')
xlabel('Range (m)')
ylabel('Depth (m)')

set(gca, 'fontsize', 16)
legend(h, 'Location', 'northwest', 'FontSize', 12);
% saveas(gcf, '../figs/R-Z-Alpha-Bc200m-Bc-200m.fig')
% saveas(gcf, '../figs/R-Z-Alpha-Bc200m-Bc-200m.png')

figure;
plot(alpha, Fa)
hold on;
plot([30 84], [0 0], 'r--')
xlabel('\alpha (°)')
ylabel('F(\alpha) (m)')
set(gca, 'fontsize', 16)
% saveas(gcf, '../figs/F-Alpha-Bc200m-Bc-200m.fig')
% saveas(gcf, '../figs/F-Alpha-Bc200m-Bc-200m.png')

%% Munk场景
filename = 'MunkB_ray_test_Falpha2';
copyfile(sprintf('../envs/%s.env', filename), './');
eval(sprintf('! bellhop2D_Falpha.exe %s', filename));

% Faplha
data1 = load("output.txt");
index = data1(:,2) ~= -1;
data2 = data1(index,:);
rd = 100;
data2(:,2) = data2(:,2) - rd;
figure;
plot(data2(:,1), data2(:,2), 'B-', 'LineWidth', 1.5)
hold on;
plot(data2(:,1), 0 * ones(1,length(data2(:,1))), 'R--', 'LineWidth', 1.5)
legend('F(\alpha)', 'y=0', Location='north')
xlabel('\alpha (°)')
ylabel('F(\alpha) (m)')
set(gca, 'fontsize', 16)
axis tight

% abs(Faplha)
% data1 = load("output.txt");
% index = data1(:,2) ~= -1;
% data2 = data1(index,:);
% rd = 100;
% data2(:,2) = data2(:,2) - rd;
figure;
plot(data2(:,1), abs(data2(:,2)), 'B-', 'LineWidth', 1.5)
hold on;
% plot(data2(:,1), rd * ones(1,length(data2(:,1))))
% legend('F(\alpha)', 'y=0')
xlabel('\alpha (°)')
ylabel('|F(\alpha)| (m)')
set(gca, 'fontsize', 16)
axis tight

delete(sprintf('%s*', filename))
delete('output.txt')
