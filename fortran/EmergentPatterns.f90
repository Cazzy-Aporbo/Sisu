!========================================================
! File: EmergentPatterns.f90
! Author: Cazzy
! Purpose: Advanced Fortran lessons demonstrating 
!          emergent behavior and pattern recognition
!========================================================

module emergent_utils
  implicit none
contains

  !----------------------------------------
  ! Lesson 1: Cellular automaton (1D)
  ! Concept: Local rules create global patterns
  !----------------------------------------
  subroutine cellular_automaton(state, steps)
    integer, intent(inout) :: state(:)
    integer, intent(in) :: steps
    integer :: i, s, n
    integer, allocatable :: new_state(:)
    
    allocate(new_state(size(state)))
    do s = 1, steps
       new_state = state
       do i = 2, size(state)-1
          new_state(i) = mod(state(i-1)+state(i)+state(i+1), 2)
       end do
       state = new_state
       print *, "Step ", s, ": ", state
    end do
    deallocate(new_state)
  end subroutine cellular_automaton

  !----------------------------------------
  ! Lesson 2: Random walks as exploration
  ! Concept: Emergent paths from simple stochastic rules
  !----------------------------------------
  subroutine random_walk_2D(x, y, steps)
    integer, intent(inout) :: x, y
    integer, intent(in) :: steps
    integer :: s, dx, dy
    do s = 1, steps
       call random_number(dx)
       call random_number(dy)
       dx = int(3*dx) - 1  ! -1,0,1
       dy = int(3*dy) - 1
       x = max(0, min(20, x + dx))
       y = max(0, min(20, y + dy))
       print *, "Step ", s, " Position: (", x, ",", y, ")"
    end do
  end subroutine random_walk_2D

  !----------------------------------------
  ! Lesson 3: Function composition manually
  ! Concept: Compose functions without language support
  !----------------------------------------
  real function compose_example(val)
    real, intent(in) :: val
    compose_example = sqrt(val**3 + 2*val)
  end function compose_example

  !----------------------------------------
  ! Lesson 4: Multi-dimensional pattern generation
  ! Concept: Nested loops create emergent visuals
  !----------------------------------------
  subroutine emergent_grid(n)
    integer, intent(in) :: n
    integer :: i,j
    do i=1,n
       do j=1,n
          if (mod(i*j,3) == 0) then
             write(*,'(A)', advance='no') '*'
          else
             write(*,'(A)', advance='no') '.'
          end if
       end do
       print *, ""
    end do
  end subroutine emergent_grid

  !----------------------------------------
  ! Lesson 5: Energy propagation in a simple network
  ! Concept: Abstract resource flow
  !----------------------------------------
  subroutine energy_propagation(nodes, steps)
    real, intent(inout) :: nodes(:)
    integer, intent(in) :: steps
    integer :: i, s
    real :: left, right
    do s=1, steps
       do i=2,size(nodes)-1
          left = nodes(i-1)
          right = nodes(i+1)
          nodes(i) = 0.5*(left + right)
       end do
       print *, "Step ", s, ": ", nodes
    end do
  end subroutine energy_propagation

end module emergent_utils

!========================================================
program emergent_demo
  use emergent_utils
  implicit none

  integer :: arr1(10), x, y, i
  real :: grid_nodes(5)

  !----------------------------------------
  ! Initialize for Lesson 1: Cellular automaton
  arr1 = [0,1,0,1,1,0,0,1,0,1]
  print *, "Lesson 1: Cellular Automaton"
  call cellular_automaton(arr1, 5)

  !----------------------------------------
  ! Lesson 2: Random walk
  x = 10; y = 10
  print *, "Lesson 2: Random Walk 2D"
  call random_walk_2D(x, y, 8)

  !----------------------------------------
  ! Lesson 3: Function composition
  print *, "Lesson 3: Compose Example: sqrt(val^3 + 2*val)"
  print *, "Input=2 -> Output=", compose_example(2.0)
  print *, "Input=4 -> Output=", compose_example(4.0)

  !----------------------------------------
  ! Lesson 4: Emergent Grid Patterns
  print *, "Lesson 4: Emergent Grid 10x10"
  call emergent_grid(10)

  !----------------------------------------
  ! Lesson 5: Energy Propagation
  grid_nodes = [10.0, 0.0, 0.0, 0.0, 0.0]
  print *, "Lesson 5: Energy Propagation in Nodes"
  call energy_propagation(grid_nodes, 5)

  print *, "Emergent patterns demo complete!"
end program emergent_demo