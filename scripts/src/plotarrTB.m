function plotarrTB( filename, irr, ird, isd )
% plot the arrivals calculated by BELLHOP
%
% usage:
% plotarr( filename, irr, ird, isd )
% where:
% irr = index of receiver range
% ird = index of receiver depth
% isd = index of source   depth
%%%% the volume attenuation in the imaginary part of Arr.deloy has been
%%%% neglected. Should be multiplied in....
[ Arr, Pos ] = read_arrivals_asc( filename );
Arr = Arr( irr, ird, isd );
Narr = Arr.Narr;
indexTNC0BNC0 = Arr.NumTopBnc==0 &Arr.NumBotBnc==0; % 直达
indexTNC1BNC0 = Arr.NumTopBnc~=0 &Arr.NumBotBnc==0; % 海面反射
indexTNC0BNC1 = Arr.NumTopBnc==0 &Arr.NumBotBnc~=0; % 海底反射
indexTNC1BNC1 = Arr.NumTopBnc~=0 &Arr.NumBotBnc~=0; % 海面、海底反射
stem( real( Arr.delay( indexTNC1BNC1 ) ), abs( Arr.A( indexTNC1BNC1 ) ), 'k', LineWidth=1.5, DisplayName='Surface and bottom bounce' )
hold("on")
stem( real( Arr.delay( indexTNC0BNC1 ) ), abs( Arr.A( indexTNC0BNC1 ) ), 'b', LineWidth=1.5, DisplayName='Bottom bounce' )
stem( real( Arr.delay( indexTNC1BNC0 ) ), abs( Arr.A( indexTNC1BNC0 ) ), 'g', LineWidth=1.5, DisplayName='Surface bounce' )
stem( real( Arr.delay( indexTNC0BNC0 ) ), abs( Arr.A( indexTNC0BNC0 ) ), 'r', LineWidth=1.5, DisplayName='Direct' )
% legend(Location="best")
hold("off")
xlabel('Time (s)' )
ylabel('Amplitude' )
title( [ 'Src_z=', num2str( Pos.s.z( isd ) ),...
   ' m  Rcvr_z=', num2str( Pos.r.z( ird ) ),...
   ' m  Rcvr_r=', num2str( Pos.r.r( irr )/1e3 ), ' km' ] )

set(gca, 'fontsize', 16, 'FontName', 'times new roman')
legend('fontname', 'times new roman', 'fontsize', 14, Location="northeast")
end