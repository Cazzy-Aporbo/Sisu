!---------------------------------------------------
! QuantumFluxGarden.f90
! Author: Cazzy
! Purpose: Advanced emergent ecosystem in Fortran
! Multiple agents, multiple flux fields, multiple plants
! Demonstrates adaptive behaviors, competition, and emergent patterns
!---------------------------------------------------

program QuantumFluxGarden
    implicit none
    integer, parameter :: MAX_AGENTS=20, MAX_PLANTS=30, MAX_FLUX=5
    integer :: i, j, step, nearest_flux_idx
    integer :: width, height
    real :: rand_val

    ! Environment size
    width = 40
    height = 20

    !-------------------------------
    ! Data structures
    !-------------------------------
    type :: Agent
        integer :: x, y
        integer :: energy
        integer :: memory(MAX_AGENTS,2)
    end type Agent

    type :: Plant
        integer :: x, y
        integer :: energy
    end type Plant

    type :: Flux
        integer :: x, y
        real :: strength
    end type Flux

    type(Agent) :: agents(MAX_AGENTS)
    type(Plant) :: plants(MAX_PLANTS)
    type(Flux) :: fluxes(MAX_FLUX)

    !-------------------------------
    ! Initialize random seed
    !-------------------------------
    call random_seed()

    !-------------------------------
    ! Initialize agents
    !-------------------------------
    do i=1,MAX_AGENTS
        call random_pos(width, height, agents(i)%x, agents(i)%y)
        agents(i)%energy = 20 + int(rand()*10)
        agents(i)%memory = 0
    end do

    !-------------------------------
    ! Initialize plants
    !-------------------------------
    do i=1,MAX_PLANTS
        call random_pos(width, height, plants(i)%x, plants(i)%y)
        plants(i)%energy = 5 + int(rand()*10)
    end do

    !-------------------------------
    ! Initialize flux fields
    !-------------------------------
    do i=1,MAX_FLUX
        call random_pos(width, height, fluxes(i)%x, fluxes(i)%y)
        call random_number(rand_val)
        fluxes(i)%strength = 0.5 + rand_val*2.0
    end do

    !-------------------------------
    ! Main simulation loop
    !-------------------------------
    do step=1,50
        call clear_screen()
        print*, "🌿 QuantumFlux Garden - Step ", step

        ! Move agents influenced by nearest flux
        do i=1,MAX_AGENTS
            nearest_flux_idx = nearest_flux(agents(i)%x, agents(i)%y, fluxes, MAX_FLUX)
            call move_agent(agents(i), fluxes(nearest_flux_idx), width, height)

            ! Agent interacts with plants
            do j=1,MAX_PLANTS
                if (agents(i)%x==plants(j)%x .and. agents(i)%y==plants(j)%y .and. plants(j)%energy>0) then
                    agents(i)%energy = agents(i)%energy + plants(j)%energy
                    plants(j)%energy = 0
                    print*, "🪴 Agent ", i, " consumed plant ", j, " at (", agents(i)%x,",",agents(i)%y,")"
                end if
            end do

            ! Energy decay
            agents(i)%energy = agents(i)%energy - 1
        end do

        ! Display garden
        call draw_garden(width, height, agents, MAX_AGENTS, plants, MAX_PLANTS, fluxes, MAX_FLUX)

        ! Pause for visualization
        call sleep(1)
    end do

contains

    !---------------------------------------------------
    ! Random position
    !---------------------------------------------------
    subroutine random_pos(w, h, x, y)
        integer, intent(in) :: w, h
        integer, intent(out) :: x, y
        real :: r1, r2
        call random_number(r1)
        call random_number(r2)
        x = int(r1*w)
        y = int(r2*h)
    end subroutine random_pos

    !---------------------------------------------------
    ! Move agent influenced by flux
    !---------------------------------------------------
    subroutine move_agent(agent, flux, w, h)
        type(Agent), intent(inout) :: agent
        type(Flux), intent(in) :: flux
        integer, intent(in) :: w, h
        real :: r1, r2
        integer :: dx, dy

        call random_number(r1)
        call random_number(r2)
        dx = sign(1,int(r1*2)) ! -1,0,1
        dy = sign(1,int(r2*2))
        ! Move towards flux proportionally to its strength
        dx = int(dx*flux%strength)
        dy = int(dy*flux%strength)
        agent%x = max(0,min(w-1,agent%x + dx))
        agent%y = max(0,min(h-1,agent%y + dy))
    end subroutine move_agent

    !---------------------------------------------------
    ! Find nearest flux field
    !---------------------------------------------------
    integer function nearest_flux(x, y, fluxes, num_flux)
        integer, intent(in) :: x, y, num_flux
        type(Flux), intent(in) :: fluxes(num_flux)
        integer :: i, best_i
        real :: min_dist, dist

        min_dist = 1.0e6
        best_i = 1
        do i=1,num_flux
            dist = sqrt(real((fluxes(i)%x - x)**2 + (fluxes(i)%y - y)**2))
            if (dist < min_dist) then
                min_dist = dist
                best_i = i
            end if
        end do
        nearest_flux = best_i
    end function nearest_flux

    !---------------------------------------------------
    ! Draw garden
    !---------------------------------------------------
    subroutine draw_garden(w, h, agents, num_agents, plants, num_plants, fluxes, num_flux)
        integer, intent(in) :: w, h, num_agents, num_plants, num_flux
        type(Agent), intent(in) :: agents(num_agents)
        type(Plant), intent(in) :: plants(num_plants)
        type(Flux), intent(in) :: fluxes(num_flux)
        integer :: i, j
        character(len=1) :: c

        do j=0,h-1
            do i=0,w-1
                c=' '
                ! Flux visualization
                do k=1,num_flux
                    if (i==fluxes(k)%x .and. j==fluxes(k)%y) then
                        c='~'
                    end if
                end do
                ! Plant visualization
                do k=1,num_plants
                    if (i==plants(k)%x .and. j==plants(k)%y .and. plants(k)%energy>0) then
                        c='*'
                    end if
                end do
                ! Agent visualization
                do k=1,num_agents
                    if (i==agents(k)%x .and. j==agents(k)%y) then
                        c='A'
                    end if
                end do
                write(*,'(A)', advance='no') trim(c)
            end do
            print*,''
        end do
    end subroutine draw_garden

    !---------------------------------------------------
    ! Clear screen
    !---------------------------------------------------
    subroutine clear_screen()
        print*, char(27)//"[2J"
    end subroutine clear_screen

    !---------------------------------------------------
    ! Sleep
    !---------------------------------------------------
    subroutine sleep(seconds)
        integer, intent(in) :: seconds
        call system("sleep " // trim(adjustl(itoa(seconds))))
    end subroutine sleep

    !---------------------------------------------------
    ! Integer to string
    !---------------------------------------------------
    function itoa(i) result(str)
        integer, intent(in) :: i
        character(len=10) :: str
        write(str,'(I0)') i
    end function itoa

end program QuantumFluxGarden