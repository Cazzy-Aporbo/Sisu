!========================================================
! File: Modular_Lessons.f90
! Author: Cazzy
! Purpose: Demonstrate modular programming, subroutines,
!          functions, and reusable code in Fortran.
!========================================================

module math_utils
  !============================
  ! Module: math_utils
  ! Purpose: Contain reusable mathematical operations
  !============================
  implicit none
contains

  !----------------------------------------
  ! Lesson 1: Subroutine to add two numbers
  !----------------------------------------
  subroutine add_two_numbers(a, b, result)
    real, intent(in) :: a, b
    real, intent(out) :: result
    result = a + b
  end subroutine add_two_numbers

  !----------------------------------------
  ! Lesson 2: Function to multiply two numbers
  !----------------------------------------
  real function multiply_two_numbers(a, b)
    real, intent(in) :: a, b
    multiply_two_numbers = a * b
  end function multiply_two_numbers

  !----------------------------------------
  ! Lesson 3: Sum of elements in an array
  ! Multiple ways: using loop and intrinsic function
  !----------------------------------------
  subroutine sum_array(arr, sum1, sum2)
    real, intent(in) :: arr(:)
    real, intent(out) :: sum1, sum2
    integer :: i

    ! Method 1: Loop
    sum1 = 0.0
    do i = 1, size(arr)
       sum1 = sum1 + arr(i)
    end do

    ! Method 2: Intrinsic function
    sum2 = sum(arr)
  end subroutine sum_array

  !----------------------------------------
  ! Lesson 4: Find max and min in array
  !----------------------------------------
  subroutine max_min_array(arr, max_val, min_val)
    real, intent(in) :: arr(:)
    real, intent(out) :: max_val, min_val

    max_val = maxval(arr)
    min_val = minval(arr)
  end subroutine max_min_array

  !----------------------------------------
  ! Lesson 5: Swap two numbers using subroutine
  !----------------------------------------
  subroutine swap_numbers(a, b)
    real, intent(inout) :: a, b
    real :: temp
    temp = a
    a = b
    b = temp
  end subroutine swap_numbers

end module math_utils

!========================================================
program modular_demo
  use math_utils
  implicit none

  real :: x, y, result
  real :: arr(5) = [1.0, 2.0, 3.0, 4.0, 5.0]
  real :: sum1, sum2, max_val, min_val

  !--------------------------
  ! Lesson 1: Add two numbers
  !--------------------------
  x = 3.5
  y = 4.2
  call add_two_numbers(x, y, result)
  print *, "Add two numbers (3.5 + 4.2): ", result

  !--------------------------
  ! Lesson 2: Multiply two numbers
  !--------------------------
  result = multiply_two_numbers(x, y)
  print *, "Multiply two numbers (3.5 * 4.2): ", result

  !--------------------------
  ! Lesson 3: Sum of array
  !--------------------------
  call sum_array(arr, sum1, sum2)
  print *, "Sum of array using loop: ", sum1
  print *, "Sum of array using intrinsic function: ", sum2

  !--------------------------
  ! Lesson 4: Max and Min of array
  !--------------------------
  call max_min_array(arr, max_val, min_val)
  print *, "Max of array: ", max_val
  print *, "Min of array: ", min_val

  !--------------------------
  ! Lesson 5: Swap two numbers
  !--------------------------
  print *, "Before swap: x=", x, " y=", y
  call swap_numbers(x, y)
  print *, "After swap: x=", x, " y=", y

  !--------------------------
  ! Lesson 6: Reusing subroutine in loop
  !--------------------------
  do x = 1.0, 5.0
     call add_two_numbers(x, 10.0, result)
     print *, "Adding 10 to ", x, " = ", result
  end do

  !--------------------------
  ! Lesson 7: Inline function usage
  !--------------------------
  print *, "Multiply 2.5 * 4.0 = ", multiply_two_numbers(2.5,4.0)

  !--------------------------
  ! Lesson 8: Array manipulation multiple ways
  !--------------------------
  arr = arr * 2.0      ! Multiply all elements by 2
  print *, "Array after multiplying by 2: ", arr

  arr(2:4) = arr(2:4) + 5.0 ! Add 5 to elements 2 to 4
  print *, "Array after adding 5 to elements 2-4: ", arr

  !--------------------------
  ! Lesson 9: Conditional logic inside subroutine
  !--------------------------
  if (max_val > 3.0) then
     print *, "Max value greater than 3!"
  else
     print *, "Max value less than or equal to 3."
  end if

  !--------------------------
  ! Lesson 10: Nested subroutine calls
  !--------------------------
  call swap_numbers(arr(1), arr(5))
  print *, "Array after swapping first and last elements: ", arr

  print *, "Modular programming demo complete!"
end program modular_demo