function oob( filename )

% run the oob (OpenOceanBellhop) program
%
% usage: oob( filename )
% where filename is the environmental file

runoob = which( 'OpenOceanBellhop.exe' );

if ( isempty( runoob ) )
   error( 'OpenOceanBellhop.exe not found in your Matlab path' )
else
   eval( [ '! "' runoob '" ' filename ' -t 8'] );
end