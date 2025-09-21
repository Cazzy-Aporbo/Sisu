!========================================================
! File: NeuralNetGarden.f90
! Author: Cazzy
! Purpose: Advanced abstract simulation of emergent "garden neurons"
!          teaching probabilistic thinking, adaptive connections,
!          and unconventional Fortran approaches
!========================================================

module neural_utils
  implicit none
contains

  !----------------------------------------
  ! Lesson 1: Random weight initialization
  !----------------------------------------
  subroutine init_weights(weights, n, m)
    integer, intent(in) :: n, m
    real, intent(out) :: weights(n,m)
    integer :: i,j
    call random_seed()
    do i=1,n
       do j=1,m
          call random_number(weights(i,j))
          weights(i,j) = weights(i,j)*2.0 - 1.0 ! range [-1,1]
       end do
    end do
  end subroutine init_weights

  !----------------------------------------
  ! Lesson 2: Sigmoid activation
  !----------------------------------------
  real function sigmoid(x)
    real, intent(in) :: x
    sigmoid = 1.0 / (1.0 + exp(-x))
  end function sigmoid

  !----------------------------------------
  ! Lesson 3: Single forward pass
  ! Concept: Weighted sum of inputs
  !----------------------------------------
  subroutine forward_pass(inputs, weights, output)
    real, intent(in) :: inputs(:)
    real, intent(in) :: weights(:, :)
    real, intent(out) :: output(size(weights,2))
    integer :: i,j
    real :: sum_val
    do j=1,size(weights,2)
       sum_val = 0.0
       do i=1,size(weights,1)
          sum_val = sum_val + inputs(i) * weights(i,j)
       end do
       output(j) = sigmoid(sum_val)
    end do
  end subroutine forward_pass

  !----------------------------------------
  ! Lesson 4: Probabilistic garden neuron growth
  ! Concept: create connections randomly and visualize abstractly
  !----------------------------------------
  subroutine garden_growth(n_neurons, connections)
    integer, intent(in) :: n_neurons
    integer, intent(out) :: connections(n_neurons,n_neurons)
    integer :: i,j
    do i=1,n_neurons
       do j=1,n_neurons
          call random_number(connections(i,j))
          if(connections(i,j) > 0.7) then
             connections(i,j) = 1
          else
             connections(i,j) = 0
          end if
       end do
    end do

    ! visualize
    print *, "Lesson 4: Neural Garden Connections"
    do i=1,n_neurons
       do j=1,n_neurons
          if(connections(i,j) == 1) then
             write(*,'(A)', advance='no') "*"
          else
             write(*,'(A)', advance='no') "."
          end if
       end do
       print *, ""
    end do
  end subroutine garden_growth

  !----------------------------------------
  ! Lesson 5: Random signal propagation
  ! Concept: abstract dynamics and stochasticity
  !----------------------------------------
  subroutine propagate_signal(connections, steps)
    integer, intent(in) :: connections(:,:)
    integer, intent(in) :: steps
    integer :: n, i, j, s
    integer :: active(:)
    n = size(connections,1)
    allocate(active(n))
    active = 0
    ! start random activation
    active(int(n*rand())+1) = 1

    print *, "Lesson 5: Signal Propagation"
    do s=1,steps
       write(*,'(A)') "Step "//trim(adjustl(itoa(s)))
       integer :: new_active(n)
       new_active = 0
       do i=1,n
          if(active(i) == 1) then
             do j=1,n
                if(connections(i,j) == 1 .and. rand() > 0.3) then
                   new_active(j) = 1
                end if
             end do
          end if
       end do
       active = new_active
       ! display
       do i=1,n
          if(active(i) == 1) then
             write(*,'(A)', advance='no') "O"
          else
             write(*,'(A)', advance='no') "."
          end if
       end do
       print *, ""
    end do
  end subroutine propagate_signal

  ! helper to convert int to string
  pure function itoa(i) result(str)
    integer, intent(in) :: i
    character(len=12) :: str
    write(str,'(I0)') i
  end function itoa

end module neural_utils

!========================================================
program neural_garden_demo
  use neural_utils
  implicit none

  real :: inputs(5), outputs(3)
  real :: weights(5,3)
  integer :: connections(6,6)

  !----------------------------------------
  ! Lesson 1: Initialize weights
  call init_weights(weights,5,3)
  print *, "Lesson 1: Random Weights"
  print *, weights

  !----------------------------------------
  ! Lesson 2: Sigmoid test
  print *, "Lesson 2: Sigmoid(0.5) =", sigmoid(0.5)

  !----------------------------------------
  ! Lesson 3: Forward pass
  inputs = [0.1,0.5,0.3,0.7,0.2]
  call forward_pass(inputs, weights, outputs)
  print *, "Lesson 3: Forward Pass Outputs"
  print *, outputs

  !----------------------------------------
  ! Lesson 4: Garden neuron connections
  call garden_growth(6,connections)

  !----------------------------------------
  ! Lesson 5: Signal propagation
  call propagate_signal(connections, 5)

  print *, "NeuralNetGarden demo complete!"
end program neural_garden_demo