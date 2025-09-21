! File: lessons_fortran.f90
! Purpose: Demonstrate Fortran basics with clear code

program fortran_lessons
    implicit none
    integer :: i
    integer, parameter :: n = 10
    integer :: numbers(n)
    
    ! -----------------------------
    ! Lesson 1: Arrays & Loops
    ! -----------------------------
    print *, "Lesson 1: Fill an array and print it"
    do i = 1, n
        numbers(i) = i * 2
    end do

    print *, "Numbers array:"
    do i = 1, n
        print *, numbers(i)
    end do

    ! -----------------------------
    ! Lesson 2: Conditional Logic
    ! -----------------------------
    print *, "Lesson 2: Check even/odd"
    do i = 1, n
        if (mod(numbers(i),2) == 0) then
            print *, numbers(i), "is even"
        else
            print *, numbers(i), "is odd"
        end if
    end do

    ! -----------------------------
    ! Lesson 3: Functions
    ! -----------------------------
    print *, "Lesson 3: Factorial function"
    print *, "Factorial of 5 =", factorial(5)

    ! -----------------------------
    ! Lesson 4: Sum of Array Elements
    ! -----------------------------
    print *, "Lesson 4: Sum of numbers array =", sum_array(numbers, n)

    ! -----------------------------
    ! Lesson 5: Demonstrate recursion (Fibonacci)
    ! -----------------------------
    print *, "Lesson 5: Fibonacci sequence up to 10"
    do i = 0, 9
        print *, "Fib(", i, ") =", fib(i)
    end do

contains

    ! Factorial using recursion
    recursive function factorial(n) result(res)
        integer, intent(in) :: n
        integer :: res
        if (n == 0) then
            res = 1
        else
            res = n * factorial(n-1)
        end if
    end function factorial

    ! Sum of array
    function sum_array(arr, size) result(total)
        integer, intent(in) :: arr(size)
        integer, intent(in) :: size
        integer :: total, i
        total = 0
        do i = 1, size
            total = total + arr(i)
        end do
    end function sum_array

    ! Fibonacci (recursive)
    recursive function fib(n) result(res)
        integer, intent(in) :: n
        integer :: res
        if (n == 0) then
            res = 0
        else if (n == 1) then
            res = 1
        else
            res = fib(n-1) + fib(n-2)
        end if
    end function fib

end program fortran_lessons