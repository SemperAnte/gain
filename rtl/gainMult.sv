//--------------------------------------------------------------------------------
// File Name:     gainMult.sv
// Project:       gain
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//       25.10.2016 - created
//       30.11.2016 - verified with multiplier
//--------------------------------------------------------------------------------
// gain with saturation
//    y = a * coef, see formats
//--------------------------------------------------------------------------------
module gainMult  
  #( parameter int A_WDT    = 16,
                   COEF_WDT = 16 )  // max = 32, must be even
   ( input  logic                          clk,
     input  logic                          reset, // async reset 
                                           
     input  logic                          st,     
     input  logic signed [ A_WDT - 1 : 0 ] a,     // format sfi( A_WDT, A_WDT - 1 ), full word length, fraction length
     input  logic     [ COEF_WDT - 1 : 0 ] coef,  // format ufi( COEF_WDT, COEF_WDT / 2 )
                                                  
     output logic                          rdy,   
     output logic signed [ A_WDT - 1 : 0 ] y );   // format sfi( A_WDT, A_WDT - 1 ), same as input

   logic                    [ 1 : 0 ] rdyReg;
   logic signed      [ COEF_WDT : 0 ] coefCnv; // 1 bit wider, convert unsigned to signed
   localparam MULT_WDT = A_WDT + COEF_WDT + 1;
   logic signed  [ MULT_WDT - 1 : 0 ] mult;    // format sfi( A_WDT + COEF_WDT + 1, A_WDT - 1 + COEF_WDT / 2 )
   
   always @( posedge clk, posedge reset )
   if ( reset ) begin
      y      <= '0;
      rdyReg <= '0;
      mult   <= '0;
   end else begin
      rdyReg <= { rdyReg[ 0 ], st };
   
      mult <= a * coefCnv;
      
      if ( ~mult[ MULT_WDT - 1 ] & |mult[ MULT_WDT - 2 : MULT_WDT - COEF_WDT / 2 - 2 ] )      // positive overflow
         y <= { 1'b0, { A_WDT - 1 { 1'b1 } } };    // saturate
      else if ( mult[ MULT_WDT - 1 ] & ~&mult[ MULT_WDT - 2 : MULT_WDT - COEF_WDT / 2 - 2 ] ) // negative overflow
         y <= { 1'b1, { A_WDT - 1 { 1'b0 } } };    // saturate
      else
         y <= { mult[ MULT_WDT - 1 ], mult[ MULT_WDT - 3 - COEF_WDT / 2 : COEF_WDT / 2 ] };
   end   
   
   assign coefCnv = { 1'b0, coef }; // unsigned to signed
   assign rdy = rdyReg[ 1 ];
        
endmodule