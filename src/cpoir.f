*DECK CPOIR
      SUBROUTINE CPOIR (A, LDA, N, V, ITASK, IND, WORK)
C***BEGIN PROLOGUE  CPOIR
C***PURPOSE  Solve a positive definite Hermitian system of linear
C            equations.  Iterative refinement is used to obtain an
C            error estimate.
C***LIBRARY   SLATEC
C***CATEGORY  D2D1B
C***TYPE      COMPLEX (SPOIR-S, CPOIR-C)
C***KEYWORDS  HERMITIAN, LINEAR EQUATIONS, POSITIVE DEFINITE, SYMMETRIC
C***AUTHOR  Voorhees, E. A., (LANL)
C***DESCRIPTION
C
C    Subroutine CPOIR solves a complex positive definite Hermitian
C    NxN system of single precision linear equations using LINPACK
C    subroutines CPOFA and CPOSL.  One pass of iterative refine-
C    ment is used only to obtain an estimate of the accuracy.  That
C    is, if A is an NxN complex positive definite Hermitian matrix
C    and if X and B are complex N-vectors, then CPOIR solves the
C    equation
C
C                          A*X=B.
C
C    Care should be taken not to use CPOIR with a non-Hermitian
C    matrix.
C
C    The matrix A is first factored into upper and lower
C    triangular matrices R and R-TRANSPOSE.  These
C    factors are used to calculate the solution, X.
C    Then the residual vector is found and used
C    to calculate an estimate of the relative error, IND.
C    IND estimates the accuracy of the solution only when the
C    input matrix and the right hand side are represented
C    exactly in the computer and does not take into account
C    any errors in the input data.
C
C    If the equation A*X=B is to be solved for more than one vector
C    B, the factoring of A does not need to be performed again and
C    the option to only solve (ITASK .GT. 1) will be faster for
C    the succeeding solutions.  In this case, the contents of A,
C    LDA, N, and WORK must not have been altered by the user
C    following factorization (ITASK=1).  IND will not be changed
C    by CPOIR in this case.
C
C  Argument Description ***
C    A       COMPLEX(LDA,N)
C             the doubly subscripted array with dimension (LDA,N)
C             which contains the coefficient matrix.  Only the
C             upper triangle, including the diagonal, of the
C             coefficient matrix need be entered.  A is not
C             altered by the routine.
C    LDA    INTEGER
C             the leading dimension of the array A.  LDA must be great-
C             er than or equal to N.  (terminal error message IND=-1)
C    N      INTEGER
C             the order of the matrix A.  N must be greater than
C             or equal to one.  (terminal error message IND=-2)
C    V      COMPLEX(N)
C             on entry, the singly subscripted array(vector) of di-
C               mension N which contains the right hand side B of a
C               system of simultaneous linear equations A*X=B.
C             on return, V contains the solution vector, X .
C    ITASK  INTEGER
C             if ITASK = 1, the matrix A is factored and then the
C               linear equation is solved.
C             if ITASK .GT. 1, the equation is solved using the existing
C               factored matrix A (stored in WORK).
C             if ITASK .LT. 1, then terminal terminal error IND=-3 is
C               printed.
C    IND    INTEGER
C             GT. 0  IND is a rough estimate of the number of digits
C                     of accuracy in the solution, X.  IND=75 means
C                     that the solution vector X is zero.
C             LT. 0  see error message corresponding to IND below.
C    WORK   COMPLEX(N*(N+1))
C             a singly subscripted array of dimension at least N*(N+1).
C
C  Error Messages Printed ***
C
C    IND=-1  terminal   N is greater than LDA.
C    IND=-2  terminal   N is less than one.
C    IND=-3  terminal   ITASK is less than one.
C    IND=-4  terminal   The matrix A is computationally singular
C                         or is not positive definite.
C                         A solution has not been computed.
C    IND=-10 warning    The solution has no apparent significance.
C                         the solution may be inaccurate or the matrix
C                         a may be poorly scaled.
C
C               NOTE-  the above terminal(*fatal*) error messages are
C                      designed to be handled by XERMSG in which
C                      LEVEL=1 (recoverable) and IFLAG=2 .  LEVEL=0
C                      for warning error messages from XERMSG.  Unless
C                      the user provides otherwise, an error message
C                      will be printed followed by an abort.
C
C***REFERENCES  J. J. Dongarra, J. R. Bunch, C. B. Moler, and G. W.
C                 Stewart, LINPACK Users' Guide, SIAM, 1979.
C***ROUTINES CALLED  CCOPY, CPOFA, CPOSL, DCDOT, R1MACH, SCASUM, XERMSG
C***REVISION HISTORY  (YYMMDD)
C   800530  DATE WRITTEN
C   890531  Changed all specific intrinsics to generic.  (WRB)
C   890831  Modified array declarations.  (WRB)
C   890831  REVISION DATE from Version 3.2
C   891214  Prologue converted to Version 4.0 format.  (BAB)
C   900315  CALLs to XERROR changed to CALLs to XERMSG.  (THJ)
C   900510  Convert XERRWV calls to XERMSG calls, cvt GOTO's to
C           IF-THEN-ELSE.  (RWC)
C   920501  Reformatted the REFERENCES section.  (WRB)
C***END PROLOGUE  CPOIR
C
      INTEGER LDA,N,ITASK,IND,INFO,J
      COMPLEX A(LDA,*),V(*),WORK(N,*)
      REAL SCASUM,XNORM,DNORM,R1MACH
      DOUBLE PRECISION DR1,DI1,DR2,DI2
      CHARACTER*8 XERN1, XERN2
C***FIRST EXECUTABLE STATEMENT  CPOIR
      IF (LDA.LT.N) THEN
         IND = -1
         WRITE (XERN1, '(I8)') LDA
         WRITE (XERN2, '(I8)') N
         CALL XERMSG ('SLATEC', 'CPOIR', 'LDA = ' // XERN1 //
     *      ' IS LESS THAN N = ' // XERN2, -1, 1)
         RETURN
      ENDIF
C
      IF (N.LE.0) THEN
         IND = -2
         WRITE (XERN1, '(I8)') N
         CALL XERMSG ('SLATEC', 'CPOIR', 'N = ' // XERN1 //
     *      ' IS LESS THAN 1', -2, 1)
         RETURN
      ENDIF
C
      IF (ITASK.LT.1) THEN
         IND = -3
         WRITE (XERN1, '(I8)') ITASK
         CALL XERMSG ('SLATEC', 'CPOIR', 'ITASK = ' // XERN1 //
     *      ' IS LESS THAN 1', -3, 1)
         RETURN
      ENDIF
C
      IF (ITASK.EQ.1) THEN
C
C        MOVE MATRIX A TO WORK
C
         DO 10 J=1,N
            CALL CCOPY(N,A(1,J),1,WORK(1,J),1)
   10    CONTINUE
C
C        FACTOR MATRIX A INTO R
C
         CALL CPOFA(WORK,N,N,INFO)
C
C        CHECK FOR  SINGULAR OR NOT POS.DEF. MATRIX
C
         IF (INFO.NE.0) THEN
            IND = -4
            CALL XERMSG ('SLATEC', 'CPOIR',
     *         'SINGULAR OR NOT POSITIVE DEFINITE - NO SOLUTION', -4, 1)
            RETURN
         ENDIF
      ENDIF
C
C     SOLVE AFTER FACTORING
C     MOVE VECTOR B TO WORK
C
      CALL CCOPY(N,V(1),1,WORK(1,N+1),1)
      CALL CPOSL(WORK,N,N,V)
C
C     FORM NORM OF X0
C
      XNORM = SCASUM(N,V(1),1)
      IF (XNORM.EQ.0.0) THEN
         IND = 75
         RETURN
      ENDIF
C
C     COMPUTE  RESIDUAL
C
      DO 40 J=1,N
         CALL DCDOT(J-1,-1.D0,A(1,J),1,V(1),1,DR1,DI1)
         CALL DCDOT(N-J+1,1.D0,A(J,J),LDA,V(J),1,DR2,DI2)
         DR1 = DR1+DR2-DBLE(REAL(WORK(J,N+1)))
         DI1 = DI1+DI2-DBLE(AIMAG(WORK(J,N+1)))
         WORK(J,N+1) = CMPLX(REAL(DR1),REAL(DI1))
   40 CONTINUE
C
C     SOLVE A*DELTA=R
C
      CALL CPOSL(WORK,N,N,WORK(1,N+1))
C
C     FORM NORM OF DELTA
C
      DNORM = SCASUM(N,WORK(1,N+1),1)
C
C     COMPUTE IND (ESTIMATE OF NO. OF SIGNIFICANT DIGITS)
C     AND CHECK FOR IND GREATER THAN ZERO
C
      IND = -LOG10(MAX(R1MACH(4),DNORM/XNORM))
      IF (IND.LE.0) THEN
         IND = -10
         CALL XERMSG ('SLATEC', 'CPOIR',
     *      'SOLUTION MAY HAVE NO SIGNIFICANCE', -10, 0)
      ENDIF
      RETURN
      END
