!========================================================
! File: AdaptiveFlow.f90
! Author: Cazzy
! Purpose: Abstract, advanced data-flow network simulation
!          Demonstrates emergent behavior, adaptive connections,
!          and probabilistic logic in Fortran
!========================================================

module flow_utils
  implicit none
contains

  !----------------------------------------
  ! Lesson 1: Initialize nodes with random values
  !----------------------------------------
  subroutine init_nodes(nodes, n)
    real, intent(out) :: nodes(n)
    integer, intent(in) :: n
    integer :: i
    call random_seed()
    do i=1,n
       call random_number(nodes(i))
       nodes(i) = nodes(i)*10.0   ! scale for visualization
    end do
  end subroutine init_nodes

  !----------------------------------------
  ! Lesson 2: Random adjacency matrix
  !----------------------------------------
  subroutine init_adjacency(adj, n)
    integer, intent(out) :: adj(n,n)
    integer, intent(in) :: n
    integer :: i,j
    real :: r
    do i=1,n
       do j=1,n
          call random_number(r)
          if(r > 0.7) then
             adj(i,j) = 1
          else
             adj(i,j) = 0
          end if
       end do
    end do
  end subroutine init_adjacency

  !----------------------------------------
  ! Lesson 3: Propagate values across network
  ! Concept: sum inputs from connected nodes
  !----------------------------------------
  subroutine propagate(nodes, adj, steps)
    real, intent(inout) :: nodes(:)
    integer, intent(in) :: adj(:,:)
    integer, intent(in) :: steps
    integer :: i,j,s,n
    real :: temp(size(nodes))
    n = size(nodes)
    
    print *, "Lesson 3: Propagation Steps"
    do s=1,steps
       temp = 0.0
       do i=1,n
          do j=1,n
             if(adj(j,i) == 1) temp(i) = temp(i) + 0.5*nodes(j)
          end do
       end do
       nodes = nodes + temp
       
       ! Display current state
       write(*,*) "Step ", s, ": ",
       do i=1,n
          write(*,'(F5.2)', advance='no') nodes(i)
       end do
       print *
    end do
  end subroutine propagate

  !----------------------------------------
  ! Lesson 4: Adaptive feedback
  ! Concept: If node exceeds threshold, redistribute energy
  !----------------------------------------
  subroutine adaptive_feedback(nodes)
    real, intent(inout) :: nodes(:)
    integer :: i
    real :: threshold
    threshold = 15.0
    do i=1,size(nodes)
       if(nodes(i) > threshold) then
          nodes(i) = nodes(i)*0.7
          nodes(mod(i,size(nodes))+1) = nodes(mod(i,size(nodes))+1) + 0.3*nodes(i)
       end if
    end do
  end subroutine adaptive_feedback

  !----------------------------------------
  ! Lesson 5: Abstract visualization
  ! Concept: print nodes with ASCII bars proportional to value
  !----------------------------------------
  subroutine visualize_nodes(nodes)
    integer :: i, bar_len
    print *, "Lesson 5: Node Visualization"
    do i=1,size(nodes)
       bar_len = int(nodes(i))
       write(*,'(A)', advance='no') "|"
       write(*,'(A)', advance='no') repeat("*",bar_len)
       print *, ""
    end do
  end subroutine visualize_nodes

end module flow_utils

!========================================================
program adaptive_flow_demo
  use flow_utils
  implicit none

  real :: nodes(8)
  integer :: adjacency(8,8)
  integer :: step

  !----------------------------------------
  ! Lesson 1: Initialize nodes
  call init_nodes(nodes, 8)
  print *, "Lesson 1: Initial Node Values"
  print *, nodes

  !----------------------------------------
  ! Lesson 2: Initialize adjacency
  call init_adjacency(adjacency, 8)
  print *, "Lesson 2: Adjacency Matrix"
  print *, adjacency

  !----------------------------------------
  ! Lesson 3: Propagation
  call propagate(nodes, adjacency, 5)

  !----------------------------------------
  ! Lesson 4: Adaptive feedback
  call adaptive_feedback(nodes)
  print *, "Lesson 4: Nodes after Feedback"
  print *, nodes

  !----------------------------------------
  ! Lesson 5: Visualization
  call visualize_nodes(nodes)

  print *, "AdaptiveFlow demo complete!"
end program adaptive_flow_demo