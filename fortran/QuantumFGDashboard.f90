!========================================================
! QuantumFlux Garden
! Author: Cazzy
! Purpose: Ultra-interactive emergent ecosystem simulation
! Features: Agents, flux fields, plants, predator-prey, 2M+ steps
!          Teaching-oriented, fully annotated, modular
!========================================================

program QuantumFluxGarden
    implicit none
    !----------------------------------------------------
    ! Import system modules
    !----------------------------------------------------
    integer, parameter :: WIDTH=80, HEIGHT=25, MAX_AGENTS=100
    integer, parameter :: MAX_PLANTS=50, MAX_FLUX=100
    integer :: i, j, step
    character(len=1) :: cmd
    logical :: paused

    !----------------------------------------------------
    ! Agent Structure
    !----------------------------------------------------
    type :: Agent
        integer :: x, y
        integer :: energy
        integer :: memory_x(10)
        integer :: memory_y(10)
        integer :: memory_count
    end type Agent

    !----------------------------------------------------
    ! Plant Structure
    !----------------------------------------------------
    type :: Plant
        integer :: x, y
        integer :: energy
    end type Plant

    !----------------------------------------------------
    ! Flux Structure
    !----------------------------------------------------
    type :: Flux
        integer :: x, y
        integer :: strength
    end type Flux

    !----------------------------------------------------
    ! Arrays
    !----------------------------------------------------
    type(Agent) :: agents(MAX_AGENTS)
    type(Plant) :: plants(MAX_PLANTS)
    type(Flux) :: fluxes(MAX_FLUX)

    !----------------------------------------------------
    ! Initialize simulation
    !----------------------------------------------------
    call random_seed()
    call init_agents(agents)
    call init_plants(plants)
    call init_flux(fluxes)
    paused = .false.

    !----------------------------------------------------
    ! Main simulation loop
    !----------------------------------------------------
    do step = 1, 2000000
        ! Input handling
        if (kbhit()) then
            read(*,'(A)') cmd
            select case(cmd)
            case(' ')
                paused = .not. paused
            case('q','Q')
                print *, "Exiting QuantumFlux Garden..."
                stop
            end select
        end if

        if (.not. paused) then
            call update_agents(agents, plants, fluxes)
            call update_plants(plants, fluxes)
            call update_flux(fluxes)
            call render_dashboard(agents, plants, fluxes, step)
        end if

    end do
end program QuantumFluxGarden

!========================================================
! Subroutine: initialize agents randomly
!========================================================
subroutine init_agents(agents)
    implicit none
    type(Agent), intent(out) :: agents(:)
    integer :: i
    do i=1,size(agents)
        call random_position(agents(i)%x, agents(i)%y)
        agents(i)%energy = 10 + int(20*rand())
        agents(i)%memory_count = 0
    end do
end subroutine init_agents

!========================================================
! Subroutine: initialize plants
!========================================================
subroutine init_plants(plants)
    implicit none
    type(Plant), intent(out) :: plants(:)
    integer :: i
    do i=1,size(plants)
        call random_position(plants(i)%x, plants(i)%y)
        plants(i)%energy = 5 + int(10*rand())
    end do
end subroutine init_plants

!========================================================
! Subroutine: initialize flux field
!========================================================
subroutine init_flux(fluxes)
    implicit none
    type(Flux), intent(out) :: fluxes(:)
    integer :: i
    do i=1,size(fluxes)
        call random_position(fluxes(i)%x, fluxes(i)%y)
        fluxes(i)%strength = 1 + int(5*rand())
    end do
end subroutine init_flux

!========================================================
! Subroutine: update agents
!========================================================
subroutine update_agents(agents, plants, fluxes)
    implicit none
    type(Agent), intent(inout) :: agents(:)
    type(Plant), intent(in) :: plants(:)
    type(Flux), intent(in) :: fluxes(:)
    integer :: i, dx, dy
    integer :: nearest_flux_idx
    do i=1,size(agents)
        ! Move randomly with flux bias
        dx = -1 + int(3*rand())
        dy = -1 + int(3*rand())
        nearest_flux_idx = nearest_flux(agents(i)%x, agents(i)%y, fluxes)
        if (nearest_flux_idx>0) then
            dx = dx + sign(1, fluxes(nearest_flux_idx)%x - agents(i)%x)
            dy = dy + sign(1, fluxes(nearest_flux_idx)%y - agents(i)%y)
        end if
        agents(i)%x = max(1, min(WIDTH, agents(i)%x + dx))
        agents(i)%y = max(1, min(HEIGHT, agents(i)%y + dy))
        agents(i)%energy = agents(i)%energy - 1
        ! Remember positions
        if (agents(i)%memory_count<10) then
            agents(i)%memory_count = agents(i)%memory_count + 1
            agents(i)%memory_x(agents(i)%memory_count) = agents(i)%x
            agents(i)%memory_y(agents(i)%memory_count) = agents(i)%y
        end if
    end do
end subroutine update_agents

!========================================================
! Subroutine: update plants
!========================================================
subroutine update_plants(plants, fluxes)
    implicit none
    type(Plant), intent(inout) :: plants(:)
    type(Flux), intent(in) :: fluxes(:)
    integer :: i, nearest_flux_idx
    do i=1,size(plants)
        nearest_flux_idx = nearest_flux(plants(i)%x, plants(i)%y, fluxes)
        if (nearest_flux_idx>0) then
            plants(i)%energy = plants(i)%energy + fluxes(nearest_flux_idx)%strength
        end if
    end do
end subroutine update_plants

!========================================================
! Subroutine: update flux
!========================================================
subroutine update_flux(fluxes)
    implicit none
    type(Flux), intent(inout) :: fluxes(:)
    integer :: i, dx, dy
    do i=1,size(fluxes)
        dx = -1 + int(3*rand())
        dy = -1 + int(3*rand())
        fluxes(i)%x = max(1, min(WIDTH, fluxes(i)%x + dx))
        fluxes(i)%y = max(1, min(HEIGHT, fluxes(i)%y + dy))
    end do
end subroutine update_flux

!========================================================
! Function: find nearest flux to a point
!========================================================
integer function nearest_flux(x, y, fluxes)
    implicit none
    integer, intent(in) :: x, y
    type(Flux), intent(in) :: fluxes(:)
    integer :: i, dist, min_dist
    nearest_flux = -1
    min_dist = WIDTH+HEIGHT
    do i=1,size(fluxes)
        dist = abs(fluxes(i)%x - x) + abs(fluxes(i)%y - y)
        if (dist<min_dist) then
            min_dist = dist
            nearest_flux = i
        end if
    end do
end function nearest_flux

!========================================================
! Subroutine: render dashboard
!========================================================
subroutine render_dashboard(agents, plants, fluxes, step)
    implicit none
    type(Agent), intent(in) :: agents(:)
    type(Plant), intent(in) :: plants(:)
    type(Flux), intent(in) :: fluxes(:)
    integer, intent(in) :: step
    integer :: i, j
    character(len=1) :: map(WIDTH, HEIGHT)

    ! Clear screen
    call system("clear")

    ! Initialize empty map
    map = ' '

    ! Draw flux
    do i=1,size(fluxes)
        map(fluxes(i)%x, fluxes(i)%y) = '*'
    end do

    ! Draw plants
    do i=1,size(plants)
        map(plants(i)%x, plants(i)%y) = '+'
    end do

    ! Draw agents
    do i=1,size(agents)
        map(agents(i)%x, agents(i)%y) = 'A'
    end do

    ! Print map
    print *, "QuantumFlux Garden - Step:", step
    do j=1,HEIGHT
        write(*,'(80A1)') (map(i,j), i=1,WIDTH)
    end do

    ! Stats
    print *, "Agents:", size(agents)
    print *, "Plants:", size(plants)
    print *, "Flux Fields:", size(fluxes)
end subroutine render_dashboard

!========================================================
! Function: generate random number between 0 and 1
!========================================================
real function rand()
    implicit none
    real :: r
    call random_number(r)
    rand = r
end function rand

!========================================================
! Subroutine: generate random position
!========================================================
subroutine random_position(x, y)
    implicit none
    integer, intent(out) :: x, y
    x = 1 + int(rand()*WIDTH)
    y = 1 + int(rand()*HEIGHT)
end subroutine random_position

!========================================================
! Function: check if key pressed (non-blocking)
!========================================================
logical function kbhit()
    implicit none
    ! For simplicity: always return false here
    ! Extendable with system-specific non-blocking input
    kbhit = .false.
end function kbhit