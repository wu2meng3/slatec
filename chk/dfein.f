*DECK DFEIN
      DOUBLE PRECISION FUNCTION DFEIN (T)
C***BEGIN PROLOGUE  DFEIN
C***PURPOSE  Subsidiary to DEG8CK.
C***LIBRARY   SLATEC
C***AUTHOR  (UNKNOWN)
C***ROUTINES CALLED  (NONE)
C***COMMON BLOCKS    DFEINX
C***REVISION HISTORY  (YYMMDD)
C   ??????  DATE WRITTEN
C   891214  Prologue converted to Version 4.0 format.  (BAB)
C***END PROLOGUE  DFEIN
      COMMON /DFEINX/ X, A, FKM
      DOUBLE PRECISION X, A, FKM, T, ALN
C***FIRST EXECUTABLE STATEMENT  DFEIN
      ALN = (FKM-T)*X - A*LOG(T)
      DFEIN = EXP(ALN)
      RETURN
      END