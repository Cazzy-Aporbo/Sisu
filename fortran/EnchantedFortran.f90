!========================================================================
! Enchanted Fortran Adventure
! Author: Cazzy
! Purpose: Production-level interactive Fortran tutorial
! Features: Lessons on variables, loops, arrays, I/O, subroutines
!========================================================================

program FortranAdventure
  implicit none
  call run_adventure()
contains

  !-------------------------------------------------------
  ! Utility to pause execution
  !-------------------------------------------------------
  subroutine pause(seconds)
    integer, intent(in), optional :: seconds
    integer :: t
    if (present(seconds)) then
       t = seconds
    else
       t = 1
    end if
    call sleep(t)
  end subroutine pause

  !-------------------------------------------------------
  ! Chapter 1: Basics
  !-------------------------------------------------------
  subroutine chapter1()
    integer :: x
    character(len=20) :: name
    print *, '--- Chapter 1: Basics ---'

    ! Lesson 1: Hello World
    print *, 'Lesson 1: Printing Hello World'
    print *, 'Hello, Fortran world!'
    call pause(1)

    ! Lesson 2: Variables
    print *, 'Lesson 2: Variables'
    x = 42
    print *, 'x = ', x
    call pause(1)

    ! Lesson 3: Input
    print *, 'Lesson 3: User Input'
    print *, 'Enter your name:'
    read(*,'(A)') name
    print *, 'Hello, ', trim(name)
    call pause(1)

    ! Lesson 4: Loops
    print *, 'Lesson 4: Loops'
    do x = 1,5
       print *, 'Loop iteration ', x
    end do
    call pause(1)

    ! Lesson 5: Conditionals
    print *, 'Lesson 5: Conditionals'
    if (x > 3) then
       print *, 'x is greater than 3!'
    else
       print *, 'x is not greater than 3!'
    end if
    call pause(1)
  end subroutine chapter1

  !-------------------------------------------------------
  ! Chapter 2: Arrays
  !-------------------------------------------------------
  subroutine chapter2()
    integer, dimension(5) :: arr
    integer :: i
    print *, '--- Chapter 2: Arrays ---'

    ! Lesson 1: Array Initialization
    print *, 'Lesson 1: Array Initialization'
    arr = (/1,2,3,4,5/)
    print *, 'Array: ', arr
    call pause(1)

    ! Lesson 2: Loop through array
    print *, 'Lesson 2: Looping through array'
    do i=1,5
       print *, 'arr(',i,') = ', arr(i)
    end do
    call pause(1)

    ! Lesson 3: Sum of array
    print *, 'Lesson 3: Sum of array'
    print *, 'Sum = ', sum(arr)
    call pause(1)

    ! Lesson 4: Max/Min
    print *, 'Lesson 4: Max and Min'
    print *, 'Max = ', maxval(arr), ' Min = ', minval(arr)
    call pause(1)

    ! Lesson 5: Array slices
    print *, 'Lesson 5: Array Slices'
    print *, 'First 3 elements: ', arr(1:3)
    call pause(1)
  end subroutine chapter2

  !-------------------------------------------------------
  ! Chapter 3: Subroutines and Functions
  !-------------------------------------------------------
  subroutine chapter3()
    integer :: result
    print *, '--- Chapter 3: Subroutines and Functions ---'

    ! Lesson 1: Calling subroutine
    print *, 'Lesson 1: Calling subroutine'
    call greet('Cazzy')
    call pause(1)

    ! Lesson 2: Function return
    print *, 'Lesson 2: Function return'
    result = square(5)
    print *, '5 squared = ', result
    call pause(1)

    ! Lesson 3: Passing arrays
    print *, 'Lesson 3: Passing arrays to subroutine'
    integer, dimension(3) :: nums = (/1,2,3/)
    call print_array(nums)
    call pause(1)
  end subroutine chapter3

  !-------------------------------------------------------
  ! Helper: Greet subroutine
  !-------------------------------------------------------
  subroutine greet(name)
    character(len=*), intent(in) :: name
    print *, 'Hello, ', trim(name), '! Welcome to Fortran!'
  end subroutine greet

  !-------------------------------------------------------
  ! Helper: Square function
  !-------------------------------------------------------
  integer function square(x)
    integer, intent(in) :: x
    square = x*x
  end function square

  !-------------------------------------------------------
  ! Helper: Print array
  !-------------------------------------------------------
  subroutine print_array(a)
    integer, dimension(:), intent(in) :: a
    integer :: i
    print *, 'Array elements:'
    do i=1,size(a)
       print *, 'Element ', i, ' = ', a(i)
    end do
  end subroutine print_array

  !-------------------------------------------------------
  ! Adventure runner
  !-------------------------------------------------------
  subroutine run_adventure()
    print *, '🎉 Welcome to the Enchanted Fortran Adventure! 🎉'
    call pause(1)
    call chapter1()
    call chapter2()
    call chapter3()
    print *, '🏁 Adventure Complete! You are now a Fortran wizard! 🏁'
  end subroutine run_adventure

end program FortranAdventure