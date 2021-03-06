*DECK SDATRP
      SUBROUTINE SDATRP (X, XOUT, YOUT, YPOUT, NEQ, KOLD, PHI, PSI)
C***BEGIN PROLOGUE  SDATRP
C***SUBSIDIARY
C***PURPOSE  Interpolation routine for SDASSL.
C***LIBRARY   SLATEC (DASSL)
C***TYPE      SINGLE PRECISION (SDATRP-S, DDATRP-D)
C***AUTHOR  Petzold, Linda R., (LLNL)
C***DESCRIPTION
C-----------------------------------------------------------------------
C     THE METHODS IN SUBROUTINE SDASTP USE POLYNOMIALS
C     TO APPROXIMATE THE SOLUTION. SDATRP APPROXIMATES THE
C     SOLUTION AND ITS DERIVATIVE AT TIME XOUT BY EVALUATING
C     ONE OF THESE POLYNOMIALS, AND ITS DERIVATIVE,THERE.
C     INFORMATION DEFINING THIS POLYNOMIAL IS PASSED FROM
C     SDASTP, SO SDATRP CANNOT BE USED ALONE.
C
C     THE PARAMETERS ARE:
C     X     THE CURRENT TIME IN THE INTEGRATION.
C     XOUT  THE TIME AT WHICH THE SOLUTION IS DESIRED
C     YOUT  THE INTERPOLATED APPROXIMATION TO Y AT XOUT
C           (THIS IS OUTPUT)
C     YPOUT THE INTERPOLATED APPROXIMATION TO YPRIME AT XOUT
C           (THIS IS OUTPUT)
C     NEQ   NUMBER OF EQUATIONS
C     KOLD  ORDER USED ON LAST SUCCESSFUL STEP
C     PHI   ARRAY OF SCALED DIVIDED DIFFERENCES OF Y
C     PSI   ARRAY OF PAST STEPSIZE HISTORY
C-----------------------------------------------------------------------
C***ROUTINES CALLED  (NONE)
C***REVISION HISTORY  (YYMMDD)
C   830315  DATE WRITTEN
C   901009  Finished conversion to SLATEC 4.0 format (F.N.Fritsch)
C   901019  Merged changes made by C. Ulrich with SLATEC 4.0 format.
C   901026  Added explicit declarations for all variables and minor
C           cosmetic changes to prologue.  (FNF)
C***END PROLOGUE  SDATRP
C
      INTEGER  NEQ, KOLD
      REAL  X, XOUT, YOUT(*), YPOUT(*), PHI(NEQ,*), PSI(*)
C
      INTEGER  I, J, KOLDP1
      REAL  C, D, GAMMA, TEMP1
C
C***FIRST EXECUTABLE STATEMENT  SDATRP
      KOLDP1=KOLD+1
      TEMP1=XOUT-X
      DO 10 I=1,NEQ
         YOUT(I)=PHI(I,1)
10       YPOUT(I)=0.0E0
      C=1.0E0
      D=0.0E0
      GAMMA=TEMP1/PSI(1)
      DO 30 J=2,KOLDP1
         D=D*GAMMA+C/PSI(J-1)
         C=C*GAMMA
         GAMMA=(TEMP1+PSI(J-1))/PSI(J)
         DO 20 I=1,NEQ
            YOUT(I)=YOUT(I)+C*PHI(I,J)
20          YPOUT(I)=YPOUT(I)+D*PHI(I,J)
30       CONTINUE
      RETURN
C
C------END OF SUBROUTINE SDATRP------
      END
