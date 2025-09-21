!========================================================
! File: MatrixAlchemy.f90
! Author: Cazzy
! Purpose: Advanced lessons in matrix abstraction, recursion,
!          and emergent patterns for Fortran learners
!========================================================

module matrix_utils
  implicit none
contains

  !----------------------------------------
  ! Lesson 1: Transpose without built-in
  ! Concept: Manipulate matrices manually
  !----------------------------------------
  subroutine manual_transpose(A, B, n, m)
    integer, intent(in) :: n, m
    real, intent(in) :: A(n,m)
    real, intent(out) :: B(m,n)
    integer :: i,j
    do i=1,n
       do j=1,m
          B(j,i) = A(i,j)
       end do
    end do
  end subroutine manual_transpose

  !----------------------------------------
  ! Lesson 2: Spiral matrix generation
  ! Concept: Emergent visualization via index manipulation
  !----------------------------------------
  subroutine spiral_matrix(N, M)
    integer, intent(in) :: N, M
    integer :: i,j,count,top,bottom,left,right
    integer :: mat(N,M)
    mat = 0
    count = 1
    top = 1; bottom = N
    left = 1; right = M
    do while(count <= N*M)
       do j=left,right
          mat(top,j) = count; count = count + 1
       end do
       top = top + 1
       do i=top,bottom
          mat(i,right) = count; count = count + 1
       end do
       right = right - 1
       if(top <= bottom) then
          do j=right,left,-1
             mat(bottom,j) = count; count = count + 1
          end do
          bottom = bottom - 1
       end if
       if(left <= right) then
          do i=bottom,top,-1
             mat(i,left) = count; count = count + 1
          end do
          left = left + 1
       end if
    end do
    print *, "Lesson 2: Spiral Matrix"
    do i=1,N
       write(*,'(20I3)') (mat(i,j), j=1,M)
    end do
  end subroutine spiral_matrix

  !----------------------------------------
  ! Lesson 3: Recursive sum of diagonal
  ! Concept: Recursion with array abstraction
  !----------------------------------------
  recursive function diagonal_sum(mat, n) result(s)
    integer, intent(in) :: n
    integer, intent(in) :: mat(n,n)
    integer :: s
    if(n == 1) then
       s = mat(1,1)
    else
       s = mat(n,n) + diagonal_sum(mat(1:n-1,1:n-1), n-1)
    end if
  end function diagonal_sum

  !----------------------------------------
  ! Lesson 4: Abstract masking
  ! Concept: Create patterns via logical masking
  !----------------------------------------
  subroutine mask_pattern(N)
    integer, intent(in) :: N
    integer :: i,j
    print *, "Lesson 4: Checkerboard Mask"
    do i=1,N
       do j=1,N
          if(mod(i+j,2) == 0) then
             write(*,'(A)', advance='no') '#'
          else
             write(*,'(A)', advance='no') '.'
          end if
       end do
       print *, ""
    end do
  end subroutine mask_pattern

  !----------------------------------------
  ! Lesson 5: Matrix-based random walk
  ! Concept: Abstract movement in 2D grid
  !----------------------------------------
  subroutine matrix_walk(N, steps)
    integer, intent(in) :: N, steps
    integer :: mat(N,N), i, j, s, dx, dy
    integer :: x, y
    mat = 0
    x = N/2
    y = N/2
    mat(x,y) = 1
    call random_seed()
    print *, "Lesson 5: Matrix Random Walk"
    do s=1,steps
       call random_number(dx)
       call random_number(dy)
       dx = int(3*dx) - 1
       dy = int(3*dy) - 1
       x = max(1, min(N, x + dx))
       y = max(1, min(N, y + dy))
       mat(x,y) = 1
    end do
    do i=1,N
       do j=1,N
          if(mat(i,j) == 1) then
             write(*,'(A)', advance='no') 'X'
          else
             write(*,'(A)', advance='no') '.'
          end if
       end do
       print *, ""
    end do
  end subroutine matrix_walk

end module matrix_utils

!========================================================
program matrix_demo
  use matrix_utils
  implicit none
  integer :: A(3,3), B(3,3), diagMat(4,4)
  integer :: i,j

  !----------------------------------------
  ! Lesson 1: Transpose
  A = reshape([1,2,3,4,5,6,7,8,9], [3,3])
  call manual_transpose(A, B, 3,3)
  print *, "Lesson 1: Manual Transpose"
  do i=1,3
     print *, B(i,:)
  end do

  !----------------------------------------
  ! Lesson 2: Spiral matrix
  call spiral_matrix(5,5)

  !----------------------------------------
  ! Lesson 3: Recursive diagonal sum
  diagMat = reshape([1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16], [4,4])
  print *, "Lesson 3: Recursive Diagonal Sum =", diagonal_sum(diagMat, 4)

  !----------------------------------------
  ! Lesson 4: Masking pattern
  call mask_pattern(8)

  !----------------------------------------
  ! Lesson 5: Matrix Random Walk
  call matrix_walk(10, 15)

  print *, "MatrixAlchemy demo complete!"
end program matrix_demo