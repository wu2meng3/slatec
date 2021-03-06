*DECK CSROOT
      SUBROUTINE CSROOT (XR, XI, YR, YI)
C***BEGIN PROLOGUE  CSROOT
C***SUBSIDIARY
C***PURPOSE  Compute the complex square root of a complex number.
C***LIBRARY   SLATEC
C***TYPE      SINGLE PRECISION (CSROOT-S)
C***AUTHOR  (UNKNOWN)
C***DESCRIPTION
C
C     (YR,YI) = complex sqrt(XR,XI)
C
C***SEE ALSO  EISDOC
C***ROUTINES CALLED  PYTHAG
C***REVISION HISTORY  (YYMMDD)
C   811101  DATE WRITTEN
C   891214  Prologue converted to Version 4.0 format.  (BAB)
C   900402  Added TYPE section.  (WRB)
C***END PROLOGUE  CSROOT
      REAL XR,XI,YR,YI,S,TR,TI,PYTHAG
C
C     BRANCH CHOSEN SO THAT YR .GE. 0.0 AND SIGN(YI) .EQ. SIGN(XI)
C***FIRST EXECUTABLE STATEMENT  CSROOT
      TR = XR
      TI = XI
      S = SQRT(0.5E0*(PYTHAG(TR,TI) + ABS(TR)))
      IF (TR .GE. 0.0E0) YR = S
      IF (TI .LT. 0.0E0) S = -S
      IF (TR .LE. 0.0E0) YI = S
      IF (TR .LT. 0.0E0) YR = 0.5E0*(TI/YI)
      IF (TR .GT. 0.0E0) YI = 0.5E0*(TI/YR)
      RETURN
      END
