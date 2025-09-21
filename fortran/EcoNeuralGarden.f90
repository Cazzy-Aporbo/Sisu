!========================================================
! File: EcoNeuralGarden.f90
! Author: Cazzy
! Purpose: Ultimate Fortran ecosystem + neural-inspired garden
!          Integrates adaptive agents, abstract flows, and emergent behavior
!========================================================

module garden_utils
  implicit none
  integer, parameter :: n_nodes=10
contains

  !--------------------------------------------------------
  ! Lesson 1: Initialize plant nodes with random energy
  !--------------------------------------------------------
  subroutine init_plants(plants)
    real, intent(out) :: plants(n_nodes)
    integer :: i
    call random_seed()
    do i=1,n_nodes
       call random_number(plants(i))
       plants(i) = plants(i)*5.0
    end do
  end subroutine init_plants

  !--------------------------------------------------------
  ! Lesson 2: Initialize adjacency for plant interactions
  !--------------------------------------------------------
  subroutine init_garden_adj(adj)
    integer, intent(out) :: adj(n_nodes,n_nodes)
    integer :: i,j
    real :: r
    do i=1,n_nodes
       do j=1,n_nodes
          call random_number(r)
          if(r>0.6) then
             adj(i,j)=1
          else
             adj(i,j)=0
          end if
       end do
    end do
  end subroutine init_garden_adj

  !--------------------------------------------------------
  ! Lesson 3: Propagate energy through plant network
  !--------------------------------------------------------
  subroutine propagate_energy(plants,adj,steps)
    real, intent(inout) :: plants(:)
    integer, intent(in) :: adj(:,:)
    integer, intent(in) :: steps
    integer :: i,j,s
    real :: temp(size(plants))
    
    do s=1,steps
       temp=0.0
       do i=1,size(plants)
          do j=1,size(plants)
             if(adj(j,i)==1) temp(i) = temp(i) + 0.3*plants(j)
          end do
       end do
       plants = plants + temp
    end do
  end subroutine propagate_energy

  !--------------------------------------------------------
  ! Lesson 4: Adaptive feedback to prevent overgrowth
  !--------------------------------------------------------
  subroutine adaptive_growth(plants)
    real, intent(inout) :: plants(:)
    integer :: i
    do i=1,size(plants)
       if(plants(i) > 8.0) then
          plants(i) = 0.6*plants(i)
       end if
    end do
  end subroutine adaptive_growth

  !--------------------------------------------------------
  ! Lesson 5: ASCII visualization of plant energy
  !--------------------------------------------------------
  subroutine visualize_garden(plants)
    integer :: i, bar_len
    print *, "🌱 Garden State Visualization 🌱"
    do i=1,size(plants)
       bar_len=int(plants(i))
       write(*,'(A)', advance='no') "|"
       write(*,'(A)', advance='no') repeat("*",bar_len)
       print *, ""
    end do
  end subroutine visualize_garden

end module garden_utils

!========================================================
module animal_utils
  implicit none
  integer, parameter :: n_animals=5
  type :: animal
     character(len=10) :: species
     real :: energy
     integer :: x,y
  end type animal
contains

  !--------------------------------------------------------
  ! Lesson 6: Initialize animal agents
  !--------------------------------------------------------
  subroutine init_animals(animals)
    type(animal), intent(out) :: animals(n_animals)
    integer :: i
    call random_seed()
    do i=1,n_animals
       if(mod(i,2)==0) then
          animals(i)%species = "Rabbit"
          animals(i)%energy = 5.0
       else
          animals(i)%species = "Fox"
          animals(i)%energy = 10.0
       end if
       call random_number(animals(i)%x)
       call random_number(animals(i)%y)
       animals(i)%x = int(animals(i)%x*10)
       animals(i)%y = int(animals(i)%y*10)
    end do
  end subroutine init_animals

  !--------------------------------------------------------
  ! Lesson 7: Move animals randomly
  !--------------------------------------------------------
  subroutine move_animals(animals)
    type(animal), intent(inout) :: animals(n_animals)
    integer :: i
    real :: dx,dy
    do i=1,n_animals
       call random_number(dx)
       call random_number(dy)
       animals(i)%x = mod(animals(i)%x + int(dx*3), 10)
       animals(i)%y = mod(animals(i)%y + int(dy*3), 10)
    end do
  end subroutine move_animals

  !--------------------------------------------------------
  ! Lesson 8: Interaction: predator eats prey
  !--------------------------------------------------------
  subroutine interact_animals(animals)
    type(animal), intent(inout) :: animals(n_animals)
    integer :: i,j
    do i=1,n_animals
       do j=i+1,n_animals
          if(animals(i)%x==animals(j)%x .and. animals(i)%y==animals(j)%y) then
             if(animals(i)%species=="Fox" .and. animals(j)%species=="Rabbit") then
                animals(i)%energy = animals(i)%energy + 3.0
                animals(j)%energy = 0.0
             else if(animals(i)%species=="Rabbit" .and. animals(j)%species=="Fox") then
                animals(j)%energy = animals(j)%energy + 3.0
                animals(i)%energy = 0.0
             end if
          end if
       end do
    end do
  end subroutine interact_animals

  !--------------------------------------------------------
  ! Lesson 9: Remove dead animals
  !--------------------------------------------------------
  subroutine cleanup_animals(animals)
    type(animal), intent(inout) :: animals(n_animals)
    integer :: i
    do i=1,n_animals
       if(animals(i)%energy<=0.0) animals(i)%species="Dead"
    end do
  end subroutine cleanup_animals

  !--------------------------------------------------------
  ! Lesson 10: Visualize animals on grid
  !--------------------------------------------------------
  subroutine visualize_animals(animals)
    type(animal), intent(in) :: animals(n_animals)
    integer :: i
    print *, "🐾 Animal Positions"
    do i=1,n_animals
       if(animals(i)%species /= "Dead") then
          print *, animals(i)%species, " at (", animals(i)%x, ",", animals(i)%y, ") Energy:", animals(i)%energy
       end if
    end do
  end subroutine visualize_animals

end module animal_utils

!========================================================
program eco_neural_garden
  use garden_utils
  use animal_utils
  implicit none

  real :: plants(n_nodes)
  integer :: adj(n_nodes,n_nodes)
  type(animal) :: animals(n_animals)
  integer :: step

  !--- Initialize ecosystem ---
  call init_plants(plants)
  call init_garden_adj(adj)
  call init_animals(animals)

  !--- Simulate over 5 steps ---
  do step=1,5
     print *, "===== Eco-Neural Garden Step ", step, " ====="
     
     call propagate_energy(plants, adj, 1)
     call adaptive_growth(plants)
     call visualize_garden(plants)

     call move_animals(animals)
     call interact_animals(animals)
     call cleanup_animals(animals)
     call visualize_animals(animals)

     print *, ""
  end do

  print *, "🌟 Simulation Complete: Emergent Garden & Adaptive Animals 🌟"

end program eco_neural_garden