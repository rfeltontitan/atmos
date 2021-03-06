      SUBROUTINE AERTAB
      INCLUDE 'PHOTOCHEM/INPUTFILES/parameters.inc'
      implicit real*8(A-H,O-Z)
      real*8 mass
      character*8 PLANET
      DIMENSION TTAB(NT),PH2O(NT,NF),PH2SO4(NT,NF)
      INCLUDE 'PHOTOCHEM/DATA/INCLUDE/PHOTABLOK.inc'
      INCLUDE 'PHOTOCHEM/DATA/INCLUDE/SULBLK.inc'
      INCLUDE 'PHOTOCHEM/DATA/INCLUDE/AERBLK.inc'
C
C   THIS SUBROUTINE READS A TABLE OF SULFURIC ACID AND H2O VAPOR
C   PRESSURES AS FUNCTIONS OF TEMPERATURE AND CONCENTRATION OF
C   H2SO4 IN THE PARTICLES.  THEN IT PRODUCES A NEW TABLE IN WHICH
C   THE LOG OF THE VAPOR PRESSURES IS STORED AT EACH VERTICAL GRID
C   POINT OF THE MODEL.
c  
c  to replace this i want a simple function
C
C   READ DATAFILE (VAPOR PRESSURES IN MM HG)
      do i=1,NT
        do j=1,NF
          read(2,999) PH2O(i,j), PH2SO4(i,j),TTAB(i),FTAB(j)
        enddo
      enddo
 999  format(E13.5,2x,E13.5,2x,F4.0,1x,F6.2)
 
C
C   CONVERT VAPOR PRESSURES TO BARS
      DO 5 K=1,NF
      DO 5 J=1,NT
      PH2O(J,K) = PH2O(J,K)*1.013/760.      !ACK - check if OK w.r.t pressure change - Kevin keeps this the same for Mars
   5  PH2SO4(J,K) = PH2SO4(J,K)*1.013/760.
C
C   INTERPOLATE TABLE TO TEMPERATURE AT EACH VERTICAL GRID POINT
      DO 1 J=1,NZ
      DO 2 I=1,NT
      IS = I
      IF(TTAB(I) .GT. T(J)) GO TO 3
   2  CONTINUE
   3  IS1 = max0(IS-1,1)
C   T(J) LIES BETWEEN TTAB(IS) AND TTAB(IS1)
      FR = 1.
      IF(IS .GT. IS1) FR = (T(J) - TTAB(IS1))/(TTAB(IS) - TTAB(IS1))
C
C   INTERPOLATE PH2O AND PH2SO4 LOGARITHMICALLY
      DO 4 K=1,NF
      H2OL = LOG(PH2O(IS,K))
      H2OL1 = LOG(PH2O(IS1,K))
      H2SO4L = LOG(PH2SO4(IS,K))
      H2SOL1 = LOG(PH2SO4(IS1,K))
      VH2O(K,J) = FR*H2OL + (1.-FR)*H2OL1
   4  VH2SO4(K,J) = FR*H2SO4L + (1.-FR)*H2SOL1
   1  CONTINUE

      RETURN
      END
