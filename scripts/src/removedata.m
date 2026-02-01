function presout = removedata(presin)
presin = squeeze(presin);
presd = double( abs( presin ) );   % pcolor needs 'double' because field.m produces a single precision
presd( isnan( presd ) ) = 1e-6;   % remove NaNs
presd( isinf( presd ) ) = 1e-6;   % remove infinities

presd( presd < 1e-12 ) = 1e-12;          % remove zeros
presout = presd;
end