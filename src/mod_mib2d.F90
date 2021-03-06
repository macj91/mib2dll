      MODULE MOD_MIB2D

      IMPLICIT NONE

      PRIVATE

      PUBLIC :: SETUP,FPSETUP,SETJUMPS,WEIGHTS
      PUBLIC :: TEST_MIB1D,TEST_CMIB1D

      CONTAINS

      INCLUDE "mod_mib2d_api.f90"       !PUBLIC SUBROUTINES
      INCLUDE "mod_mib2d_newips.f90"    !LINKED LISTS OF INTERFACE POINTS
      INCLUDE "mod_mib2d_ludcmp.f90"    !LU DECOMPOSITION
      INCLUDE "mod_mib2d_utau.f90"      !APPROXIMATE U_TAU
      INCLUDE "mod_mib2d_mib.f90"       !MIB AND CMIB SUBROUTINES

      END MODULE MOD_MIB2D
