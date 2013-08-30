#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "multicall.h"
#include "ppport.h"

/* Returns index of found element, or undef if none found. */

SV* binsearch( SV* block, SV* needle, SV* aref_haystack ) {
  dSP;
  dMULTICALL;
  GV *gv;
  HV *stash;
  I32 gimme = G_SCALAR;
  CV *cv = sv_2cv(block, &stash, &gv, 0);
  I32 min = 0;
  I32 max = 0;
  GV *agv = gv_fetchpv("a", GV_ADD, SVt_PV);
  GV *bgv = gv_fetchpv("b", GV_ADD, SVt_PV);
  SAVESPTR(GvSV(agv));
  SAVESPTR(GvSV(bgv));

  /* We must have a valid subref, and aref for the haystack. */
  if( cv == Nullcv )
    croak("Not a subroutine reference.");
  if( ! SvROK( aref_haystack ) || SvTYPE(SvRV(aref_haystack)) != SVt_PVAV )
    croak( "Argument must be an array ref.\n" );

  max = av_len( (AV*)SvRV(aref_haystack) ); /* Perl 5.16 applied av_top_index synonym */

  if( max < 0 ) return &PL_sv_undef; /* Empty list; needle can't be found. */

  PUSH_MULTICALL(cv);

  while( max > min ) {

    I32 mid = ( min + max ) / 2;
    
    /* Fetch value at aref_haystack->[mid] */
    GvSV(agv) = needle;
    GvSV(bgv) = *av_fetch( (AV*)SvRV(aref_haystack), mid, 0 );  /* Hay */

    MULTICALL;
    if( SvIV( *PL_stack_sp ) == 1 ) {  /* if ($a<=>$b) > 0 */
      min = mid + 1;
    }
    else {
      max = mid;
    }
  }

  /* Detect if we have a winner, and who won. */
  if( max == min ) {
    GvSV(agv) = needle;
    GvSV(bgv) = *av_fetch((AV*)SvRV(aref_haystack),min,0);
    MULTICALL;
    if( SvIV(*PL_stack_sp ) == 0 ) {
      POP_MULTICALL;
      return newSViv(min);
    }
  }

  /* Otherwise we have a loser. */
  POP_MULTICALL;
  return &PL_sv_undef; /* Not found. */
}



/* Returns index of found element, or index of insert point if none found. */

SV* binsearch_pos( SV* block, SV* needle, SV* aref_haystack ) {
  dSP;
  dMULTICALL;
  GV *gv;
  HV *stash;
  I32 gimme = G_SCALAR;
  CV *cv = sv_2cv(block, &stash, &gv, 0);
  I32 low = 0;
  I32 high = 0;
  GV *agv = gv_fetchpv("a", GV_ADD, SVt_PV);
  GV *bgv = gv_fetchpv("b", GV_ADD, SVt_PV);
  SAVESPTR(GvSV(agv));
  SAVESPTR(GvSV(bgv));

  /* We must have a valid subref, and aref for the haystack. */
  if( cv == Nullcv )
    croak("Not a subroutine reference.");
  if( ! SvROK( aref_haystack ) || SvTYPE(SvRV(aref_haystack)) != SVt_PVAV )
    croak( "Argument must be an array ref.\n" );

  high = av_len( (AV*)SvRV(aref_haystack) ) + 1; /* scalar @{$aref} (Perl 5.16 introduced av_top_index synonym.) */

  if( high <= 0 ) return newSViv(low); /* Empty list; insert at zero. */

  PUSH_MULTICALL(cv);

  while( low < high ) {

    I32 cur = ( low + high ) / 2;
    
    /* Fetch value at aref_haystack->[mid] */
    GvSV(agv) = needle;
    GvSV(bgv) = *av_fetch( (AV*)SvRV(aref_haystack), cur, 0 );  /* Hay */

    MULTICALL;
    if( SvIV( *PL_stack_sp ) > 0 ) {  /* if ($a<=>$b) > 0 */
      low = cur + 1;
    }
    else {
      high = cur;
    }
  }
  POP_MULTICALL;
  return newSViv(low);
}



MODULE = List::BinarySearch::XS		PACKAGE = List::BinarySearch::XS		
PROTOTYPES: ENABLE

SV *
binsearch (block, needle, aref_haystack)
	SV *	block
	SV *	needle
	SV *	aref_haystack
  PROTOTYPE: &$\@

SV *
binsearch_pos (block, needle, aref_haystack)
	SV *	block
	SV *	needle
	SV *	aref_haystack
  PROTOTYPE: &$\@
