      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ! SETUTAU --
      !    SET NODES AND ASSOCIATED WEIGHTS FOR U_TAU APPROXIMATION AT AN INTERFACE PT
      ! ARGUMENTS:
      !    DATA  IN/OUT  A LISTED INTERFACE POINT
      ! NOTES:
      !
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      SUBROUTINE SETUTAU(DATA)

      USE MOD_DATA

      TYPE(LIST_DATA) :: DATA

      INTEGER,PARAMETER :: N = 3 !# OF SUPPORTING GRIDS TO INTERPOLATE U AT ONE AUXILIARY PT
      INTEGER,PARAMETER :: M = 0 !HIGHEST DERIVATIVE TO BE INTERPOLATED

      REAL :: WAUX(0:N-1,0:M) !WEIGHTS ON THE SUPPORTING GRIDS
      REAL :: ATAU !ANGLE FORMED BY THE TANGENTIAL LINE TAU AND X-AXIS
      REAL :: DTAU !SCALING DX

      ATAU = DATA%THETA + PI/2.0D0 !ANGLE FORM BY TAU AND X AXIS

      IF (DATA%AXTP .EQ. 0) THEN !INTERFACE PT IS ON ONE IX GRID LINE
         IF (COS(ATAU) .GT. 0.0D0) THEN !TANGENT LINE TAU IS ALONG POSITIVE X-DIRECTION
            DATA%ITAU =  1
         ELSE !TANGENT LINE TAU IS ALONG NEGATIVE X-DIRECTION
            DATA%ITAU = -1
         END IF
         DTAU = ABS(DX/COS(ATAU))

         !---------- LOWER AUXILIARY PT
         DATA%AUXL_AXTP = 0 !LOWER AUXILIARY PT IS ON A IX GRID LINE
         DATA%AUXL_AXID = DATA%AXID - DATA%ITAU !LOWER AUXILARY AXIS
         DATA%AUXL_X    = XI(DATA%AUXL_AXID) !X COORDINATE OF LOWER AUXILIARY PT
         DATA%AUXL_Y    = TAN(ATAU)*(DATA%AUXL_X-DATA%X) + DATA%Y !Y COORDINATE OF LOWER AUXILIARY PT
         DATA%DAUXL     = DTAU !DISTANCE OF THE LOWER AUXILIARY PT TO THE INTERFACE PT

         !3 GRIDS TO INTERPOLATE U AT LOWER AUXILIARY PT
         WAUX = 0.0D0
         CALL SPTX(DATA%AUXL_AXID,DATA%AUXL_Y,N,M,DATA%AUXL,DATA%IAUXL,WAUX)
         DATA%WAUXL = WAUX(:,0)

         !---------- UPPER AUXILIARY PT
         DATA%AUXR_AXTP = 0 !UPPER AUXILIARY PT IS ON A IX GRID LINE
         DATA%AUXR_AXID = DATA%AXID + DATA%ITAU !UPPER AUXILARY AXIS
         DATA%AUXR_X    = XI(DATA%AUXR_AXID) !X COORDINATE OF UPPER AUXILIARY PT
         DATA%AUXR_Y    = TAN(ATAU)*(DATA%AUXR_X-DATA%X) + DATA%Y !Y COORDINATE OF UPPER AUXILIARY PT
         DATA%DAUXR     = DTAU !DISTANCE OF THE UPPER AUXILIARY PT TO THE INTERFACE PT

         !3 GRIDS TO INTERPOLATE U AT UPPER AUXILIARY PT
         WAUX = 0.0D0
         CALL SPTX(DATA%AUXR_AXID,DATA%AUXR_Y,N,M,DATA%AUXR,DATA%IAUXR,WAUX)
         DATA%WAUXR = WAUX(:,0)

      ELSE !INTERFACE PT IS ON ONE IY GRID LINE
         IF ( SIN(ATAU) .GT. 0.0D0 ) THEN !TANGENT LINE TAU IS ALONG POSITIVE Y-DIRECTION
            DATA%ITAU =  1
         ELSE !TANGENT LINE TAU IS ALONG NEGATIVE Y-DIRECTION
            DATA%ITAU = -1
         END IF
         DTAU = ABS( DX/SIN(ATAU) )

         !---------- LEFT AUXILIARY PT
         DATA%AUXL_AXTP = 1 ! LEFT AUXILIARY PT IS ON A IY GRID LINE
         DATA%AUXL_AXID = DATA%AXID - DATA%ITAU !LEFT AUXILARY AXIS
         DATA%AUXL_Y    = YI( DATA%AUXL_AXID )
         DATA%AUXL_X    = ( DATA%AUXL_Y - DATA%Y ) / TAN(ATAU) + DATA%X
         DATA%DAUXL     = DTAU !DISTANCE OF THE LEFT AUXILIARY PT TO THE INTERFACE PT

         !3 GRIDS TO INTERPOLATE U AT LOWER AUXILIARY PT
         WAUX = 0.0D0
         CALL SPTY(DATA%AUXL_AXID,DATA%AUXL_X,N,M,DATA%AUXL,DATA%IAUXL,WAUX)
         DATA%WAUXL = WAUX(:,0)

         !---------- RIGHT AUXILIARY PT
         DATA%AUXR_AXTP = 1 ! RIGHT AUXILIARY PT IS ON A IX GRID LINE
         DATA%AUXR_AXID = DATA%AXID + DATA%ITAU !RIGHT AUXILARY AXIS
         DATA%AUXR_Y    = YI(DATA%AUXR_AXID)
         DATA%AUXR_X    = ( DATA%AUXR_Y - DATA%Y ) / TAN(ATAU) + DATA%X
         DATA%DAUXR     = DTAU !DISTANCE OF THE RIGHT AUXILIARY PT TO THE INTERFACE PT

         !3 GRIDS TO INTERPOLATE U AT LOWER AUXILIARY PT
         WAUX = 0.0D0
         CALL SPTY(DATA%AUXR_AXID,DATA%AUXR_X,N,M,DATA%AUXR,DATA%IAUXR,WAUX)
         DATA%WAUXR = WAUX(:,0)

      END IF

      !---------- INTERPOLATING U FROM OPPOSITE SIDE OF THE INTERFACE AT TWO AUXILIARY PTS. ADDITIONAL
      !           STEPS ARE REQUIRED TO CALCULATE U FROM THE OTHER SIDE OF THE INTERFACE.
      !
      !           MATH. FORMULA:
      !              (U^+_AUXL + U^+_AUXR)/2     - (U^-_AUXL + U^-_AUXR)/2     = [U]_IP     =  PHI_IP
      !              (U^+_AUXR - U^+_AUXL)/2DTAU - (U^-_AUXR - U^-_AUXL)/2DTAU = [U_TAU]_IP = (PHI_TAU)_IP
      !           SO THAT
      !              1. WHEN U^+_AUXL AND U^-_AUXR ARE READY, WE HAVE
      !              (U^+_TAU)_IP = -1/(2L)U^+_AL + 1/(2L)U^-_AR + 1/(2L)[U]_IP + 1/2*[U_TAU]_IP
      !                           = -1/(2L)U^+_AL + 1/(2L)U^-_AR + 1/(2L)PHI_IP + 1/2*(PHI_TAU)_IP
      !
      !              2. WHEN U^-_AUXL AND U^+_AUXR ARE READY, WE HAVE
      !              (U^-_TAU)_IP = -1/(2L)U^-_AL + 1/(2L)U^+_AR - 1/(2L)[U]_IP - 1/2*[U_TAU]_IP
      !                           = -1/(2L)U^-_AL + 1/(2L)U^+_AR - 1/(2L)PHI_IP - 1/2*(PHI_TAU)_IP
      !           WHERE THE LAST TWO TERMS ON THE RIGHT ARE CALLED "EXCESS TERMS", AND WILL BE ADDED IN THE
      !           SUBROUTINE SETJUMPS.
      DATA%WAUXL = -0.5D0 / DATA%DAUXL * DATA%WAUXL
      DATA%WAUXR =  0.5D0 / DATA%DAUXR * DATA%WAUXR

      IF ( DATA%AUXL*DATA%AUXR .LT. 0 ) THEN
         NALTAUXS = NALTAUXS + 1
      END IF

      RETURN

      END SUBROUTINE SETUTAU

      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ! SPTX --
      !    SETUP SUPPROTING GRIDS TO APPROXIMATE U AT ONE AUXILIARY PT ON ONE IX GRID LINE
      ! ARGUMENTS:
      !    AXID            IN     ID OF THE IX GRID LINE
      !    Y               IN     Y COORDINATE OF THE AUXILIARY PT (LOCATION WHERE
      !                           APPROXIMATIONS ARE TO BE ACCURATE)
      !    N               IN     # OF GRIDS
      !    M               IN     HIGHEST DERIVATIVE TO BE INTERPOLATED
      !    TYPE            OUT    INDICATOR FOR INTERPLOATING U^+ (= 0) OR U^- (= 1)
      !    IY(N)           OUT    INDICES OF N GRIDS
      !    WY(0:N-1,0:M)   OUT    ASSOCIATED WEIGHTS
      ! NOTES:
      !
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      SUBROUTINE SPTX(AXID,Y,N,M,TYPE,IY,WY)

      USE MOD_DATA

      INTEGER :: AXID,N,M,TYPE,IY(N)
      REAL    :: Y,WY(0:N-1,0:M)

      INTEGER :: IYP(N),IYN(N) !SUPPORTING GRIDS TO INTERPLOATE U^+ AND U^- AT THE AUXILIARY PT
      INTEGER :: NYP,NYN !COUNTER FOR POSITIVE GRIDS AND NEGATIVE GRIDS
      INTEGER :: IGDY,TOWHERE,NGRD
      REAL    :: NDS(0:N-1) !INTERPOLATING NODES
      INTEGER :: I

      IGDY = ANINT( (Y-YL)/DX ) + 1 !Y INDEX OF THE NEAREST GRID
      IF (YI(IGDY) .LT. Y) THEN !THE 1ST GRID IS BELOW THE AUXILIARY PT
         TOWHERE =  -1
      ELSE !THE 1ST GRID IS ABOVE THE AUXILIARY PT
         TOWHERE =   1
      END IF

      NGRD = 0
      IYP  = 0; NYP = 0
      IYN  = 0; NYN = 0
      DO WHILE (NYP .LT. 3 .AND. NYN .LT. 3)
         IF ( IGDY .LT. 1 .OR. IGDY .GT. NY) THEN !INDEX IN ONE DIRECTION IS OUT OF RANGE
            GOTO 100
         END IF

         IF (INODE(IGDY,AXID) .EQ. 1) THEN !OMEGA^+
            NYP = NYP + 1; IYP(NYP) = IGDY
         ELSE IF (INODE(IGDY,AXID) .EQ. -1) THEN !OMEGA^-
            NYN = NYN + 1; IYN(NYN) = IGDY
         END IF

100      NGRD    =  NGRD + 1
         TOWHERE = -TOWHERE !ALTERNATE DIRECTION
         IGDY    =  IGDY + TOWHERE*NGRD
      END DO

      NDS = 0.0D0; WY = 0.0D0
      IF (NYP .EQ. 3) THEN
         TYPE =  1; IY = IYP
      ELSE IF (NYN .EQ. 3) THEN
         TYPE = -1; IY = IYN
      END IF

      DO I = 0,N-1
         NDS(I) = YI( IY(I+1) )
      END DO

      CALL WEIGHTS(Y,NDS,N-1,N-1,M,WY)

      RETURN

      END SUBROUTINE SPTX

      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      ! SPTY --
      !    SETUP SUPPROTING GRIDS TO APPROXIMATE U AT ONE AUXILIARY PT ON ONE IY GRID LINE
      ! ARGUMENTS:
      !    AXID            IN     ID OF THE IY GRID LINE
      !    X               IN     X COORDINATE OF THE AUXILIARY PT (LOCATION WHERE
      !                           APPROXIMATIONS ARE TO BE ACCURATE)
      !    N               IN     # OF GRIDS
      !    M               IN     HIGHEST DERIVATIVE TO BE INTERPOLATED
      !    TYPE            OUT    INDICATOR FOR INTERPLOATING U^+ (= 0) OR U^- (= 1)
      !    IX(N)           OUT    INDICES OF N GRIDS
      !    WX(0:N-1,0:M)   OUT    ASSOCIATED WEIGHTS
      ! NOTES:
      !
      !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      SUBROUTINE SPTY(AXID,X,N,M,TYPE,IX,WX)

      USE MOD_DATA

      INTEGER :: AXID,N,M,TYPE,IX(N)
      REAL    :: X,WX(0:N-1,0:M)

      INTEGER :: IXP(N),IXN(N) !SUPPORTING GRIDS TO INTERPLOATE U^+ AND U^- AT THE AUXILIARY PT
      INTEGER :: NXP,NXN !COUNTER FOR POSITIVE GRIDS AND NEGATIVE GRIDS
      INTEGER :: IGDX,TOWHERE,NGRD
      REAL    :: NDS(0:N-1) !INTERPOLATING NODES
      INTEGER :: I

      IGDX = ANINT( (X-XL)/DX ) + 1 !X INDEX OF THE NEAREST GRID
      IF (XI(IGDX) .LT. X) THEN !THE 1ST GRID IS BELOW THE AUXILIARY PT
         TOWHERE =  -1
      ELSE !THE 1ST GRID IS ABOVE THE AUXILIARY PT
         TOWHERE =   1
      END IF

      NGRD = 0
      IXP  = 0; NXP = 0
      IXN  = 0; NXN = 0
      DO WHILE (NXP .LT. 3 .AND. NXN .LT. 3 .AND. IGDX .GE. 1 .AND. IGDX .LE. NX)
         IF (IGDX .LT. 1 .OR. IGDX .GT. NX) THEN
            GOTO 200
         END IF

         IF (INODE(AXID,IGDX) .EQ. 1) THEN !OMEGA^+
            NXP = NXP + 1; IXP(NXP) = IGDX
         ELSE IF (INODE(AXID,IGDX) .EQ. -1) THEN !OMEGA^-
            NXN = NXN + 1; IXN(NXN) = IGDX
         END IF

200      NGRD    =  NGRD + 1
         TOWHERE = -TOWHERE !ALTERNATE DIRECTION
         IGDX    =  IGDX + TOWHERE*NGRD
      END DO

      NDS = 0.0D0; WX = 0.0D0
      IF (NXP .EQ. 3) THEN
         TYPE =  1; IX = IXP
      ELSE IF (NXN .EQ. 3) THEN
         TYPE = -1; IX = IXN
      END IF

      DO I = 0,N-1
         NDS(I) = XI(IX(I+1))
      END DO

      CALL WEIGHTS(X,NDS,N-1,N-1,M,WX)

      RETURN

      END SUBROUTINE SPTY
