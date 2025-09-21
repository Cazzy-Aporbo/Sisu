!========================================================
! File: Abstract_Thinking_Lessons.f90
! Author: Cazzy
! Purpose: Advanced Fortran lessons teaching abstract
!          thinking via unconventional, exploratory coding
!========================================================

module abstract_utils
  implicit none
contains

  !----------------------------------------
  ! Lesson 1: Represent functions as arrays
  ! Concept: Functions as data, not just code
  !----------------------------------------
  subroutine function_as_array(x, y)
    real, intent(in) :: x(:)
    real, intent(out) :: y(size(x))
    integer :: i

    ! y = x^2 + 2x + 1 (vectorized)
    do i = 1, size(x)
       y(i) = x(i)**2 + 2.0*x(i) + 1.0
    end do
  end subroutine function_as_array

  !----------------------------------------
  ! Lesson 2: Multiple evaluation strategies
  ! Concept: Same computation in different ways
  !----------------------------------------
  real function sum_series_loop(n)
    integer, intent(in) :: n
    integer :: i
    sum_series_loop = 0.0
    do i = 1, n
       sum_series_loop = sum_series_loop + 1.0/i
    end do
  end function sum_series_loop

  real function sum_series_formula(n)
    integer, intent(in) :: n
    ! Use approximation: harmonic series ~ ln(n) + gamma
    real, parameter :: gamma = 0.5772156649
    sum_series_formula = log(real(n)) + gamma
  end function sum_series_formula

  !----------------------------------------
  ! Lesson 3: Higher-order thinking
  ! Concept: Pass subroutines as arguments (meta-coding)
  !----------------------------------------
  interface
     subroutine simple_proc(x)
       real, intent(inout) :: x
     end subroutine simple_proc
  end interface

  subroutine apply_twice(proc, val)
    procedure(simple_proc), pointer :: proc
    real, intent(inout) :: val
    call proc(val)
    call proc(val)
  end subroutine apply_twice

  subroutine double_value(x)
    real, intent(inout) :: x
    x = x * 2.0
  end subroutine double_value

  !----------------------------------------
  ! Lesson 4: Recursive abstraction
  ! Concept: Use recursion to think hierarchically
  !----------------------------------------
  recursive real function factorial(n) result(res)
    integer, intent(in) :: n
    if (n <= 1) then
       res = 1.0
    else
       res = real(n) * factorial(n-1)
    end if
  end function factorial

  !----------------------------------------
  ! Lesson 5: Array transformations as abstract patterns
  ! Concept: Map, reduce, filter manually
  !----------------------------------------
  subroutine transform_array(arr, res)
    real, intent(in) :: arr(:)
    real, intent(out) :: res(size(arr))
    integer :: i

    ! Map: square each element
    do i = 1, size(arr)
       res(i) = arr(i)**2
    end do

    ! Reduce: sum of transformed elements
    print *, "Sum of squares: ", sum(res)

    ! Filter: only elements > 10
    print *, "Elements > 10: "
    do i = 1, size(res)
       if (res(i) > 10.0) print *, res(i)
    end do
  end subroutine transform_array

end module abstract_utils

!========================================================
program abstract_demo
  use abstract_utils
  implicit none

  real :: x(5) = [1.0,2.0,3.0,4.0,5.0]
  real :: y(5)
  real :: val
  integer :: n

  !----------------------------------------
  ! Lesson 1: Functions as data
  !----------------------------------------
  call function_as_array(x, y)
  print *, "Function as array output: ", y

  !----------------------------------------
  ! Lesson 2: Multiple strategies
  !----------------------------------------
  n = 1000
  print *, "Sum of series (loop): ", sum_series_loop(n)
  print *, "Sum of series (approx formula): ", sum_series_formula(n)

  !----------------------------------------
  ! Lesson 3: Higher-order thinking
  !----------------------------------------
  val = 3.0
  print *, "Original val: ", val
  call apply_twice(double_value, val)
  print *, "After apply_twice(double_value): ", val

  !----------------------------------------
  ! Lesson 4: Recursive abstraction
  !----------------------------------------
  n = 5
  print *, "Factorial of ", n, " = ", factorial(n)

  !----------------------------------------
  ! Lesson 5: Array transformation
  !----------------------------------------
  call transform_array(x, y)

  !----------------------------------------
  ! Lesson 6: Dynamic memory & pointers
  ! Concept: Abstract resource management
  !----------------------------------------
  real, allocatable :: ptr(:)
  allocate(ptr(5))
  ptr = x * 1.5
  print *, "Dynamic array (x*1.5): ", ptr
  deallocate(ptr)

  !----------------------------------------
  ! Lesson 7: Nested abstractions
  ! Concept: Combine multiple lessons
  !----------------------------------------
  val = 2.0
  call apply_twice(double_value, val)        ! double
  print *, "Nested abstraction result: ", val**3 ! cube it

  !----------------------------------------
  ! Lesson 8: Mathematical exploration
  ! Concept: Harmonic + factorial relationship
  print *, "Harmonic(5)*Factorial(5) = ", sum_series_loop(5)*factorial(5)

  !----------------------------------------
  ! Lesson 9: Conditional mapping
  ! Concept: Apply different functions based on value
  do n = 1,5
     if (x(n) < 3.0) then
        y(n) = x(n)**2
     else
        y(n) = sqrt(x(n))
     end if
  end do
  print *, "Conditional mapping result: ", y

  !----------------------------------------
  ! Lesson 10: Abstract patterns in loops
  ! Concept: Observe patterns emerge
  do n = 1, 10
     print *, "Pattern ", n, ": ", factorial(n)/real(n**n)
  end do

  print *, "Abstract thinking Fortran demo complete!"
end program abstract_demo