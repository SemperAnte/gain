//--------------------------------------------------------------------------------
// File Name:     gain.sv
// Project:       gain
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       25.10.2016 - created
//       30.11.2016 - verified with multiplier
//--------------------------------------------------------------------------------
// simple gain with saturation
//    y = a * coef, see formats
//    value of coef loads through avalon MM interface
//--------------------------------------------------------------------------------
module gain  
  #( parameter int A_WDT    = 16,
                   COEF_WDT = 16 )  // max = 32, must be even   
   ( input  logic                          clk,
     input  logic                          reset,  
     
     // avalon MM slave
     input  logic                          avsWr,
     input  logic               [ 31 : 0 ] avsWrData,
     output logic               [ 31 : 0 ] avsRdData,
                                           
     input  logic                          st,     
     input  logic signed [ A_WDT - 1 : 0 ] a,    // format sfi( A_WDT, A_WDT - 1 ), full word length, fraction length

     output logic                          rdy,
     output logic signed [ A_WDT - 1 : 0 ] y );  // format sfi( A_WDT, A_WDT - 1 ), same as input

   logic                    [ 1 : 0 ] rdyReg;
   logic signed      [ COEF_WDT : 0 ] coefCnv; // 1 bit wider, convert unsigned to signed
   localparam MULT_WDT = A_WDT + COEF_WDT + 1;
   logic signed  [ MULT_WDT - 1 : 0 ] mult;    // format sfi( A_WDT + COEF_WDT + 1, A_WDT - 1 + COEF_WDT / 2 )
   
   // check parameters
   initial begin
      if ( ( COEF_WDT > 32 ) || ( COEF_WDT % 2 ) != 0 ) begin // must be even         
         $error( "Not correct parameter, COEF_WDT" );
         $stop;
      end
   end
   
   logic [ COEF_WDT - 1 : 0 ] coef; // format ufi( COEF_WDT, COEF_WDT / 2 )
   
   // avalon MM slave interface
   gainAvs
     #( .COEF_WDT ( COEF_WDT ) )
   gainAvsInst
      ( .clk       ( clk       ),
        .reset     ( reset     ),
        .avsWr     ( avsWr     ),
        .avsWrData ( avsWrData ),
        .avsRdData ( avsRdData ),    
        .coef      ( coef      ) );
   
   // gain with saturation   
   gainMult
     #( .A_WDT    ( A_WDT    ),
        .COEF_WDT ( COEF_WDT ) )
   gainMultInst
      ( .clk   ( clk   ),
        .reset ( reset ),
        .st    ( st    ),
        .a     ( a     ),
        .coef  ( coef  ),      
        .rdy   ( rdy   ),
        .y     ( y     ) );
        
endmodule