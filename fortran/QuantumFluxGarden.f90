!========================================================
! File: QuantumFluxGarden.f90
! Author: Cazzy
! Purpose: create emergent ecosystem with flux fields in Fortran
!========================================================
module flux_utils
  implicit none
  integer, parameter :: n_nodes=10
contains
  ! Initialize flux field (quantum-like probabilities)
  subroutine init_flux_field(flux)
    real, intent(out) :: flux(n_nodes,n_nodes)
    integer :: i,j
    call random_seed()
    do i=1,n_nodes
       do j=1,n_nodes
          call random_number(flux(i,j))
       end do
    end do
  end subroutine init_flux_field

  ! Propagate flux influence on plants
  subroutine propagate_flux(plants,flux)
    real, intent(inout) :: plants(n_nodes)
    real, intent(in) :: flux(n_nodes,n_nodes)
    integer :: i,j
    real :: influence
    do i=1,n_nodes
       influence=0.0
       do j=1,n_nodes
          influence = influence + 0.5*plants(j)*flux(j,i)
       end do
       plants(i) = plants(i) + influence
       if(plants(i)>10.0) plants(i) = 0.7*plants(i)
    end do
  end subroutine propagate_flux
end module flux_utils

!========================================================
module agent_utils
  implicit none
  integer, parameter :: n_agents=6
  type :: agent
     character(len=10) :: species
     real :: energy
     integer :: x,y
  end type agent
contains
  ! Initialize agents
  subroutine init_agents(agents)
    type(agent), intent(out) :: agents(n_agents)
    integer :: i
    call random_seed()
    do i=1,n_agents
       if(mod(i,2)==0) then
          agents(i)%species = "Prey"
          agents(i)%energy = 5.0
       else
          agents(i)%species = "Predator"
          agents(i)%energy = 10.0
       end if
       call random_number(agents(i)%x)
       call random_number(agents(i)%y)
       agents(i)%x = int(agents(i)%x*10)
       agents(i)%y = int(agents(i)%y*10)
    end do
  end subroutine init_agents

  ! Move agents influenced by flux field
  subroutine move_agents(agents,flux)
    type(agent), intent(inout) :: agents(n_agents)
    real, intent(in) :: flux(:,:)
    integer :: i
    real :: dx,dy,fx,fy
    do i=1,n_agents
       call random_number(dx)
       call random_number(dy)
       fx = flux(mod(agents(i)%x,10)+1, mod(agents(i)%y,10)+1)
       fy = flux(mod(agents(i)%y,10)+1, mod(agents(i)%x,10)+1)
       agents(i)%x = mod(agents(i)%x + int(dx*2 + fx*2), 10)
       agents(i)%y = mod(agents(i)%y + int(dy*2 + fy*2), 10)
    end do
  end subroutine move_agents

  ! Predator-prey interaction
  subroutine interact_agents(agents)
    type(agent), intent(inout) :: agents(n_agents)
    integer :: i,j
    do i=1,n_agents
       do j=i+1,n_agents
          if(agents(i)%x==agents(j)%x .and. agents(i)%y==agents(j)%y) then
             if(agents(i)%species=="Predator" .and. agents(j)%species=="Prey") then
                agents(i)%energy = agents(i)%energy + 3.0
                agents(j)%energy = 0.0
             else if(agents(i)%species=="Prey" .and. agents(j)%species=="Predator") then
                agents(j)%energy = agents(j)%energy + 3.0
                agents(i)%energy = 0.0
             end if
          end if
       end do
    end do
  end subroutine interact_agents
end module agent_utils

!========================================================
program QuantumFluxGarden
  use flux_utils
  use agent_utils
  implicit none

  real :: plants(n_nodes)
  real :: flux_field(n_nodes,n_nodes)
  type(agent) :: agents(n_agents)
  integer :: step,i

  ! Initialize ecosystem
  call init_flux_field(flux_field)
  call init_agents(agents)
  call plants_fill(plants)

  ! Simulation loop
  do step=1,10
     print *, "===== Step ", step, " ====="
     call propagate_flux(plants,flux_field)
     call move_agents(agents,flux_field)
     call interact_agents(agents)

     print *, "Plant energies: ", plants
     do i=1,n_agents
        print *, agents(i)%species,"(",agents(i)%energy,") at (",agents(i)%x,",",agents(i)%y,")"
     end do

     ! Randomly update flux field (emergent behavior)
     call init_flux_field(flux_field)
     print *, ""
  end do

contains
  ! Initialize plants with random energy
  subroutine plants_fill(plants)
    real, intent(out) :: plants(n_nodes)
    integer :: i
    call random_seed()
    do i=1,n_nodes
       call random_number(plants(i))
       plants(i) = plants(i)*5.0
    end do
  end subroutine plants_fill

end program QuantumFluxGarden