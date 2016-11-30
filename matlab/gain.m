% for gain testbench
% y = a * coef with saturation
clc; clear; close all;
addpath( 'func' );

fpathSim = '..\sim\';
fpathModelsim = 'D:\CADS\Modelsim10_1c\win32\modelsim.exe';
rng( 0, 'twister' ); % random seed

L        = 10000; % number of pairs
A_WDT    = 16;  % format - sfi( A_WDT, A_WDT - 1 )
COEF_WDT = 16;  % format - ufi( COEF_WDT, COEF_WDT / 2 ), COEF_WDT must be even

F = fimath( 'RoundingMethod', 'Floor', ...
            'OverflowAction', 'Saturate', ...
            'ProductMode', 'SpecifyPrecision', ...
            'ProductWordLength', A_WDT, ...
            'ProductFractionLength', A_WDT - 1 );
        
% a
a = randi( [ -2^( A_WDT - 1 ) 2^( A_WDT - 1 ) - 1 ], 1, L );
a = a / 2^( A_WDT - 1 );
a = fi( a, 1, A_WDT, A_WDT - 1, F );
% coef
coef = randi( [ 0 2^COEF_WDT - 1 ], 1, L );
coef = coef / 2^( COEF_WDT / 2 );
coef = fi( coef, 0, COEF_WDT, COEF_WDT / 2, F );
% mult
yMat = coef .* a;

% file with parms
fileID = fopen( [ fpathSim 'parms.vh' ], 'wt' );
fprintf( fileID, '// Automatically generated with Matlab, dont edit\n' );
fprintf( fileID, 'localparam int A_WDT    = %i,\n', A_WDT    );
fprintf( fileID, '               COEF_WDT = %i;\n', COEF_WDT );
fclose( fileID );
% file with a and coef
txtFileWrite( [ fpathSim 'a.txt' ], a, 'DEC' );
txtFileWrite( [ fpathSim 'coef.txt' ], coef, 'DEC' );

%% autorun Modelsim
if ( exist( [ fpathSim 'flag.txt' ], 'file' ) )
     delete( [ fpathSim 'flag.txt' ] );
end;
status = system( [ fpathModelsim ' -do ' fpathSim 'auto.do' ] );
pause on;
while ( ~exist( [ fpathSim 'flag.txt' ], 'file' ) ) % wait for flag file
    pause( 1 );
end;

%% read data from testbench
NT = numerictype( yMat );
yHdl = txtFileRead( [ fpathSim 'y.txt' ], NT, 'DEC' );

if ( length( yMat ) == length( yHdl ) )
    fprintf( 'length is equal = %i\n', length( yMat ) );
    x = 1 : length( yMat );    
elseif ( length( yMat ) > length( yHdl ) )
    fprintf( 'length isnt equal, matlab = %i, hdl = %i\n', ...
        length( yMat ), length( yHdl ) );
    x = 1 : length( yHdl );
else
    fprintf( 'length isnt equal, matlab = %i, hdl = %i\n', ...
    length( yMat ), length( yHdl ) );
    x = 1 : length( yMat );
end;

fprintf( 'num of errors : %i\n', sum( yMat( x ) ~= yHdl( x ) ) );