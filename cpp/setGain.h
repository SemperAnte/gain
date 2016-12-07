//--------------------------------------------------------------------------------
// File Name:     setGain.h
// Project:       gain
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    02.12.2016 - created
//--------------------------------------------------------------------------------
// set gain coefficient
//--------------------------------------------------------------------------------
#include <io.h>
#include <alt_types.h>

alt_u8 setGain( alt_u32 baseAdr,    // base module address
                  float gainCoef )  // gain coef, float
{
   if ( gainCoef > 255 )
      gainCoef = 255;

   // convert to ufi( 16, 8 )
   alt_u32 wrData = ( alt_u32 ) ( gainCoef * 256 + 0.5 );

   printf( "Set gain coefficient for base adr 0x%X - %u ... ", ( unsigned int ) baseAdr, ( unsigned int ) wrData );

   IOWR_32DIRECT( baseAdr, 0, ( alt_u32 ) wrData );
   alt_u32 rdData = IORD_32DIRECT( baseAdr, 0 );
   if ( rdData != wrData ) {
      printf( "err\n" );
      return 1;
   }
   else {
      printf( "done\n" );
      return 0;
   }   

}
