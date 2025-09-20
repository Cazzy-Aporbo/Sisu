! Compile: gfortran savings_sim.f90 -o sim && ./sim
program savings_sim
  implicit none
  integer, parameter :: n=120, trials=10000  ! 10 years monthly
  real :: base=500.0, mu=0.002, sigma=0.01
  real :: total, shock
  integer :: i, t, better

  call random_seed()
  better = 0
  do t=1, trials
     total = 0.0
     do i=1, n
        call random_number(shock)
        shock = (shock - 0.5)*2.0*sigma
        total = total + base*(1.0+mu+shock)
     end do
     if (total > 70000.0) better = better + 1
  end do
  print *, "P(total > 70k) ≈ ", real(better)/real(trials)
end program
