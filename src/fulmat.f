*DECK FULMAT
      SUBROUTINE FULMAT (I, J, AIJ, INDCAT, PRGOPT, DATTRV, IFLAG)
C***BEGIN PROLOGUE  FULMAT
C***SUBSIDIARY
C***PURPOSE  Subsidiary to SPLP
C***LIBRARY   SLATEC
C***TYPE      SINGLE PRECISION (FULMAT-S, DFULMT-D)
C***AUTHOR  (UNKNOWN)
C***DESCRIPTION
C
C     DECODES A STANDARD TWO-DIMENSIONAL FORTRAN ARRAY PASSED
C     IN THE ARRAY DATTRV(IA,*).  THE ROW DIMENSION IA AND THE
C     MATRIX DIMENSIONS MRELAS AND NVARS MUST SIMULTANEOUSLY BE
C     PASSED USING THE OPTION ARRAY, PRGOPT(*).  IT IS AN ERROR
C     IF THIS DATA IS NOT PASSED TO FULMAT( ).
C     EXAMPLE-- (FOR USE TOGETHER WITH SPLP().)
C      EXTERNAL USRMAT
C      DIMENSION DATTRV(IA,*)
C      PRGOPT(01)=7
C      PRGOPT(02)=68
C      PRGOPT(03)=1
C      PRGOPT(04)=IA
C      PRGOPT(05)=MRELAS
C      PRGOPT(06)=NVARS
C      PRGOPT(07)=1
C     CALL SPLP(  ... FULMAT INSTEAD OF USRMAT...)
C
C***SEE ALSO  SPLP
C***ROUTINES CALLED  XERMSG
C***REVISION HISTORY  (YYMMDD)
C   811215  DATE WRITTEN
C   891214  Prologue converted to Version 4.0 format.  (BAB)
C   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
C   900328  Added TYPE section.  (WRB)
C***END PROLOGUE  FULMAT
      REAL            AIJ,ZERO,DATTRV(*),PRGOPT(*)
      INTEGER IFLAG(10)
      SAVE ZERO
C***FIRST EXECUTABLE STATEMENT  FULMAT
      IF (.NOT.(IFLAG(1).EQ.1)) GO TO 50
C     INITIALIZE POINTERS TO PROCESS FULL TWO-DIMENSIONAL FORTRAN
C     ARRAYS.
      ZERO = 0.
      LP = 1
   10 NEXT = PRGOPT(LP)
      IF (.NOT.(NEXT.LE.1)) GO TO 20
      NERR = 29
      LEVEL = 1
      CALL XERMSG ('SLATEC', 'FULMAT',
     +   'IN SPLP PACKAGE, ROW DIM., MRELAS, NVARS ARE MISSING FROM ' //
     +   'PRGOPT.', NERR, LEVEL)
      IFLAG(1) = 3
      GO TO 110
   20 KEY = PRGOPT(LP+1)
      IF (.NOT.(KEY.NE.68)) GO TO 30
      LP = NEXT
      GO TO 10
   30 IF (.NOT.(PRGOPT(LP+2).EQ.ZERO)) GO TO 40
      LP = NEXT
      GO TO 10
   40 IFLAG(2) = 1
      IFLAG(3) = 1
      IFLAG(4) = PRGOPT(LP+3)
      IFLAG(5) = PRGOPT(LP+4)
      IFLAG(6) = PRGOPT(LP+5)
      GO TO 110
   50 IF (.NOT.(IFLAG(1).EQ.2)) GO TO 100
   60 I = IFLAG(2)
      J = IFLAG(3)
      IF (.NOT.(J.GT.IFLAG(6))) GO TO 70
      IFLAG(1) = 3
      GO TO 110
   70 IF (.NOT.(I.GT.IFLAG(5))) GO TO 80
      IFLAG(2) = 1
      IFLAG(3) = J + 1
      GO TO 60
   80 AIJ = DATTRV(IFLAG(4)*(J-1)+I)
      IFLAG(2) = I + 1
      IF (.NOT.(AIJ.EQ.ZERO)) GO TO 90
      GO TO 60
   90 INDCAT = 0
      GO TO 110
  100 CONTINUE
  110 RETURN
      END
