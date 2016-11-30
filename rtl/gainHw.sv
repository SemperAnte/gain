//--------------------------------------------------------------------------------
// File Name:     gainHw.sv
// Project:       gain
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       25.10.2016 - created
//       30.11.2016 - verified with multiplier
//--------------------------------------------------------------------------------
// simple gain with saturation
//    y = a * coef, see formats
//    value of coef loads through avalon MM interface
//
// top-level wrapper for qsys automatic signal recognition
//--------------------------------------------------------------------------------
module gainHw  
  #( parameter int A_WDT    = 16,   // width for a
                   COEF_WDT = 16 )  // width for coef, max = 32, must be even   
   ( input  logic                          csi_clk,
     input  logic                          rsi_reset,     
     // avalon MM slave
     input  logic                          avs_write,
     input  logic               [ 31 : 0 ] avs_writedata,
     output logic               [ 31 : 0 ] avs_readdata,
     // avalon ST sink
     input  logic                          asi_valid,     
     input  logic signed [ A_WDT - 1 : 0 ] asi_data,    // format sfi( A_WDT, A_WDT - 1 ), full word length, fraction length
     // avalon ST source
     output logic                          aso_valid,
     output logic signed [ A_WDT - 1 : 0 ] aso_data );  // format sfi( A_WDT, A_WDT - 1 ), same as input

   gain
     #( .A_WDT    ( A_WDT    ),
        .COEF_WDT ( COEF_WDT ) )
   gainInst
      ( .clk       ( csi_clk       ),
        .reset     ( rsi_reset     ),
        .avsWr     ( avs_write     ),
        .avsWrData ( avs_writedata ),
        .avsRdData ( avs_readdata  ),
        .st        ( asi_valid     ),
        .a         ( asi_data      ),
        .rdy       ( aso_valid     ),
        .y         ( aso_data      ) );
        
endmodule