// testnench for gain
`timescale 1 ns / 100 ps

module tb_gain();

   localparam int T = 10;
   // parameters from generated file
   `include "parms.vh"     
   
   logic                          clk;
   logic                          reset;   
   logic                          avsWr     = 1'b0;
   logic               [ 31 : 0 ] avsWrData = '0;
   logic               [ 31 : 0 ] avsRdData;                           
   logic                          st = 1'b0;
   logic signed [ A_WDT - 1 : 0 ] a  = '0;
   logic                          rdy;
   logic signed [ A_WDT - 1 : 0 ] y;
   
   gain
     #( .A_WDT    ( A_WDT ),
        .COEF_WDT ( COEF_WDT ) )
   uut
      ( .clk       ( clk       ),
        .reset     ( reset     ),
        .avsWr     ( avsWr     ),
        .avsWrData ( avsWrData ),
        .avsRdData ( avsRdData ),
        .st        ( st        ),
        .a         ( a         ),
        .rdy       ( rdy       ),
        .y         ( y         ) );
        
   always begin   
      clk = 1'b1;
      #( T / 2 );
      clk = 1'b0;
      #( T / 2 );
   end
   
   initial begin   
      reset = 1'b1;
      #( 10 * T + T / 2 );
      reset = 1'b0;
   end
   
  initial
   begin
      static int aFile    = $fopen( "a.txt",    "r" );      
      static int coefFile = $fopen( "coef.txt", "r" );
      static int yFile    = $fopen( "y.txt",    "w" );
      static int flagFile;
      
      if ( !aFile )
         $display( "Cant open file a.txt" );
      if ( !coefFile )
         $display( "Cant open file coef.txt" );
      if ( !aFile || !coefFile )
         $stop;
      
      @ ( negedge reset );
      # ( 10 * T );
      @ ( negedge clk );
      while ( !$feof( aFile ) || !$feof( coefFile ) ) begin     
         // avalon slave - loading coef
         avsWr = 1'b1;
         $fscanf( coefFile, "%d\n", avsWrData );
         # ( T );
         avsWr = 1'b0;
         st    = 1'b1;
         // read a from file
         $fscanf( aFile, "%d\n", a    );       
         # ( T );
         st = 1'b0;         
         wait ( rdy );
         @ ( negedge clk );
         // write cos and sin to file
         $fwrite( yFile, "%d\n", y );
      end     
      # ( 10 * T );    

      $fclose( aFile    );
      $fclose( coefFile );
      $fclose( yFile    );
      
      // flag for automatic testbench
      flagFile = $fopen( "flag.txt", "w" );
      $fclose( flagFile );
      $stop;
   end
   
endmodule