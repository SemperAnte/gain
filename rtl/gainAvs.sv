//--------------------------------------------------------------------------------
// File Name:     gainAvs.sv
// Project:       gain
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    26.10.2016 - created
//--------------------------------------------------------------------------------
// avalon MM slave interface
//    write and read - coef
//--------------------------------------------------------------------------------
module gainAvs   
  #( parameter int COEF_WDT = 16 )  // max = 32, must be even         
   ( input  logic                      clk,
     input  logic                      reset,    // async reset
     
     // avalon MM slave
     input  logic                      avsWr,
     input  logic           [ 31 : 0 ] avsWrData,
     output logic           [ 31 : 0 ] avsRdData,
     
     output logic [ COEF_WDT - 1 : 0 ] coef );   // format ufi( COEF_WDT, COEF_WDT / 2 )
   
   always_ff @( posedge clk, posedge reset )
   if ( reset ) begin
      avsRdData <= '0;
      coef      <= ( COEF_WDT )'( 2 ** ( COEF_WDT / 2 ) ); // for unity gain x1
   end else begin
      // write
      if ( avsWr ) begin
         if ( COEF_WDT == 32 ) begin
            coef <= avsWrData;
         end else begin // COEF_WDT < 32, check for saturation        
            if ( |avsWrData[ 31 : COEF_WDT ] ) // saturation
               coef <= '1;
            else
               coef <= avsWrData[ COEF_WDT - 1 : 0 ];
         end
      end
      // read
      avsRdData <= { { 32 - COEF_WDT { 1'b0 } }, coef };
   end
   
endmodule