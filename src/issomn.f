*DECK ISSOMN
      INTEGER FUNCTION ISSOMN (N, B, X, NELT, IA, JA, A, ISYM, MSOLVE,
     +   NSAVE, ITOL, TOL, ITMAX, ITER, ERR, IERR, IUNIT, R, Z, P, AP,
     +   EMAP, DZ, CSAV, RWORK, IWORK, AK, BNRM, SOLNRM)
C***BEGIN PROLOGUE  ISSOMN
C***SUBSIDIARY
C***PURPOSE  Preconditioned Orthomin Stop Test.
C            This routine calculates the stop test for the Orthomin
C            iteration scheme.  It returns a non-zero if the error
C            estimate (the type of which is determined by ITOL) is
C            less than the user specified tolerance TOL.
C***LIBRARY   SLATEC (SLAP)
C***CATEGORY  D2A4, D2B4
C***TYPE      SINGLE PRECISION (ISSOMN-S, ISDOMN-D)
C***KEYWORDS  ITERATIVE PRECONDITION, NON-SYMMETRIC LINEAR SYSTEM,
C             ORTHOMIN, SLAP, SPARSE, STOP TEST
C***AUTHOR  Greenbaum, Anne, (Courant Institute)
C           Seager, Mark K., (LLNL)
C             Lawrence Livermore National Laboratory
C             PO BOX 808, L-60
C             Livermore, CA 94550 (510) 423-3141
C             seager@llnl.gov
C***DESCRIPTION
C
C *Usage:
C     INTEGER  N, NELT, IA(NELT), JA(NELT), ISYM, NSAVE, ITOL, ITMAX
C     INTEGER  ITER, IERR, IUNIT, IWORK(USER DEFINED)
C     REAL     B(N), X(N), A(NELT), TOL, ERR, R(N), Z(N)
C     REAL     P(N,0:NSAVE), AP(N,0:NSAVE), EMAP(N,0:NSAVE)
C     REAL     DZ(N), CSAV(NSAVE), RWORK(USER DEFINED), AK
C     REAL     BNRM, SOLNRM
C     EXTERNAL MSOLVE
C
C     IF( ISSOMN(N, B, X, NELT, IA, JA, A, ISYM, MSOLVE, NSAVE,
C    $     ITOL, TOL, ITMAX, ITER, ERR, IERR, IUNIT, R, Z, P, AP,
C    $     EMAP, DZ, CSAV, RWORK, IWORK, AK, BNRM, SOLNRM)
C    $     .NE.0 ) THEN ITERATION CONVERGED
C
C *Arguments:
C N      :IN       Integer.
C         Order of the matrix.
C B      :IN       Real B(N).
C         Right-hand side vector.
C X      :IN       Real X(N).
C         On input X is your initial guess for solution vector.
C         On output X is the final approximate solution.
C NELT   :IN       Integer.
C         Number of Non-Zeros stored in A.
C IA     :IN       Integer IA(NELT).
C JA     :IN       Integer JA(NELT).
C A      :IN       Real A(NELT).
C         These arrays should hold the matrix A in either the SLAP
C         Triad format or the SLAP Column format.  See "Description"
C         in the SSDOMN or SSLUOM prologue.
C ISYM   :IN       Integer.
C         Flag to indicate symmetric storage format.
C         If ISYM=0, all non-zero entries of the matrix are stored.
C         If ISYM=1, the matrix is symmetric, and only the upper
C         or lower triangle of the matrix is stored.
C MSOLVE :EXT      External.
C         Name of a routine which solves a linear system MZ = R for
C         Z given R with the preconditioning matrix M (M is supplied via
C         RWORK and IWORK arrays).  The name of the MSOLVE routine must
C         be declared external in the calling program.  The calling
C         sequence to MSOLVE is:
C             CALL MSOLVE(N, R, Z, NELT, IA, JA, A, ISYM, RWORK, IWORK)
C         Where N is the number of unknowns, R is the right-hand side
C         vector and Z is the solution upon return.  NELT, IA, JA, A and
C         ISYM are defined as above.  RWORK is a real array that can
C         be used to pass necessary preconditioning information and/or
C         workspace to MSOLVE.  IWORK is an integer work array for
C         the same purpose as RWORK.
C NSAVE  :IN       Integer.
C         Number of direction vectors to save and orthogonalize against.
C ITOL   :IN       Integer.
C         Flag to indicate type of convergence criterion.
C         If ITOL=1, iteration stops when the 2-norm of the residual
C         divided by the 2-norm of the right-hand side is less than TOL.
C         If ITOL=2, iteration stops when the 2-norm of M-inv times the
C         residual divided by the 2-norm of M-inv times the right hand
C         side is less than TOL, where M-inv is the inverse of the
C         diagonal of A.
C         ITOL=11 is often useful for checking and comparing different
C         routines.  For this case, the user must supply the "exact"
C         solution or a very accurate approximation (one with an error
C         much less than TOL) through a common block,
C             COMMON /SSLBLK/ SOLN( )
C         If ITOL=11, iteration stops when the 2-norm of the difference
C         between the iterative approximation and the user-supplied
C         solution divided by the 2-norm of the user-supplied solution
C         is less than TOL.  Note that this requires the user to set up
C         the "COMMON /SSLBLK/ SOLN(LENGTH)" in the calling routine.
C         The routine with this declaration should be loaded before the
C         stop test so that the correct length is used by the loader.
C         This procedure is not standard Fortran and may not work
C         correctly on your system (although it has worked on every
C         system the authors have tried).  If ITOL is not 11 then this
C         common block is indeed standard Fortran.
C TOL    :IN       Real.
C         Convergence criterion, as described above.
C ITMAX  :IN       Integer.
C         Maximum number of iterations.
C ITER   :IN       Integer.
C         Current iteration count.  (Must be zero on first call.)
C ERR    :OUT      Real.
C         Error estimate of error in final approximate solution, as
C         defined by ITOL.
C IERR   :OUT      Integer.
C         Error flag.  IERR is set to 3 if ITOL is not one of the
C         acceptable values, see above.
C IUNIT  :IN       Integer.
C         Unit number on which to write the error at each iteration,
C         if this is desired for monitoring convergence.  If unit
C         number is 0, no writing will occur.
C R      :IN       Real R(N).
C         The residual R = B-AX.
C Z      :WORK     Real Z(N).
C P      :IN       Real P(N,0:NSAVE).
C         Workspace used to hold the conjugate direction vector(s).
C AP     :IN       Real AP(N,0:NSAVE).
C         Workspace used to hold the matrix A times the P vector(s).
C EMAP   :IN       Real EMAP(N,0:NSAVE).
C         Workspace used to hold M-inv times the AP vector(s).
C DZ     :WORK     Real DZ(N).
C         Workspace.
C CSAV   :DUMMY    Real CSAV(NSAVE)
C         Reserved for future use.
C RWORK  :WORK     Real RWORK(USER DEFINED).
C         Real array that can be used for workspace in MSOLVE.
C IWORK  :WORK     Integer IWORK(USER DEFINED).
C         Integer array that can be used for workspace in MSOLVE.
C AK     :IN       Real.
C         Current iterate Orthomin iteration parameter.
C BNRM   :OUT      Real.
C         Current solution B-norm, if ITOL = 1 or 2.
C SOLNRM :OUT      Real.
C         True solution norm, if ITOL = 11.
C
C *Function Return Values:
C       0 : Error estimate (determined by ITOL) is *NOT* less than the
C           specified tolerance, TOL.  The iteration must continue.
C       1 : Error estimate (determined by ITOL) is less than the
C           specified tolerance, TOL.  The iteration can be considered
C           complete.
C
C *Cautions:
C     This routine will attempt to write to the Fortran logical output
C     unit IUNIT, if IUNIT .ne. 0.  Thus, the user must make sure that
C     this logical unit is attached to a file or terminal before calling
C     this routine with a non-zero value for IUNIT.  This routine does
C     not check for the validity of a non-zero IUNIT unit number.
C
C***SEE ALSO  SOMN, SSDOMN, SSLUOM
C***ROUTINES CALLED  R1MACH, SNRM2
C***COMMON BLOCKS    SSLBLK
C***REVISION HISTORY  (YYMMDD)
C   871119  DATE WRITTEN
C   881213  Previous REVISION DATE
C   890915  Made changes requested at July 1989 CML Meeting.  (MKS)
C   890922  Numerous changes to prologue to make closer to SLATEC
C           standard.  (FNF)
C   890929  Numerous changes to reduce SP/DP differences.  (FNF)
C   891003  Removed C***REFER TO line, per MKS.
C   910411  Prologue converted to Version 4.0 format.  (BAB)
C   910502  Removed MSOLVE from ROUTINES CALLED list.  (FNF)
C   910506  Made subsidiary to SOMN.  (FNF)
C   920407  COMMON BLOCK renamed SSLBLK.  (WRB)
C   920511  Added complete declaration section.  (WRB)
C   920930  Corrected to not print AK when ITER=0.  (FNF)
C   921026  Changed 1.0E10 to R1MACH(2).  (FNF)
C   921113  Corrected C***CATEGORY line.  (FNF)
C***END PROLOGUE  ISSOMN
C     .. Scalar Arguments ..
      REAL AK, BNRM, ERR, SOLNRM, TOL
      INTEGER IERR, ISYM, ITER, ITMAX, ITOL, IUNIT, N, NELT, NSAVE
C     .. Array Arguments ..
      REAL A(NELT), AP(N,0:NSAVE), B(N), CSAV(NSAVE), DZ(N),
     +     EMAP(N,0:NSAVE), P(N,0:NSAVE), R(N), RWORK(*), X(N), Z(N)
      INTEGER IA(NELT), IWORK(*), JA(NELT)
C     .. Subroutine Arguments ..
      EXTERNAL MSOLVE
C     .. Arrays in Common ..
      REAL SOLN(1)
C     .. Local Scalars ..
      INTEGER I
C     .. External Functions ..
      REAL R1MACH, SNRM2
      EXTERNAL R1MACH, SNRM2
C     .. Common blocks ..
      COMMON /SSLBLK/ SOLN
C***FIRST EXECUTABLE STATEMENT  ISSOMN
      ISSOMN = 0
C
      IF( ITOL.EQ.1 ) THEN
C         err = ||Residual||/||RightHandSide|| (2-Norms).
         IF(ITER .EQ. 0) BNRM = SNRM2(N, B, 1)
         ERR = SNRM2(N, R, 1)/BNRM
      ELSE IF( ITOL.EQ.2 ) THEN
C                  -1              -1
C         err = ||M  Residual||/||M  RightHandSide|| (2-Norms).
         IF(ITER .EQ. 0) THEN
            CALL MSOLVE(N, B, DZ, NELT, IA, JA, A, ISYM, RWORK, IWORK)
            BNRM = SNRM2(N, DZ, 1)
         ENDIF
         ERR = SNRM2(N, Z, 1)/BNRM
      ELSE IF( ITOL.EQ.11 ) THEN
C         err = ||x-TrueSolution||/||TrueSolution|| (2-Norms).
         IF(ITER .EQ. 0) SOLNRM = SNRM2(N, SOLN, 1)
         DO 10 I = 1, N
            DZ(I) = X(I) - SOLN(I)
 10      CONTINUE
         ERR = SNRM2(N, DZ, 1)/SOLNRM
      ELSE
C
C         If we get here ITOL is not one of the acceptable values.
         ERR = R1MACH(2)
         IERR = 3
      ENDIF
C
      IF(IUNIT .NE. 0) THEN
         IF( ITER.EQ.0 ) THEN
            WRITE(IUNIT,1000) NSAVE, N, ITOL
            WRITE(IUNIT,1010) ITER, ERR
         ELSE
            WRITE(IUNIT,1010) ITER, ERR, AK
         ENDIF
      ENDIF
      IF(ERR .LE. TOL) ISSOMN = 1
C
      RETURN
 1000 FORMAT(' Preconditioned Orthomin(',I3,') for ',
     $     'N, ITOL = ',I5, I5,
     $     /' ITER','   Error Estimate','            Alpha')
 1010 FORMAT(1X,I4,1X,E16.7,1X,E16.7)
C------------- LAST LINE OF ISSOMN FOLLOWS ----------------------------
      END
