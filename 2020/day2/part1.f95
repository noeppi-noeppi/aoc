program part1
    implicit none

    integer :: length
    integer :: amount
    integer :: i
    character(100) :: input

    write(*, fmt="(1x,a,i0)", advance="no") "Enter length: "
    read(*,*) length

    amount = 0
    do i = 0, length - 1
        read(*,'(A)') input
        if (valid(input)) then
            amount = amount + 1
        end if
    end do

    print *, amount

    contains

    function valid(input_raw) result(is_valid)
        character(100), intent(in) :: input_raw
        character(100) :: input
        logical :: is_valid

        integer :: splitidx
        character(100) :: rule
        character(100) :: password
        character :: rulechar
        character(100) :: ruleamount
        character(100) :: rulemin_str
        character(100) :: rulemax_str
        integer :: rulemin
        integer :: rulemax
        integer :: counter
        integer :: password_len
        integer :: i

        input = trim(input_raw)

        splitidx = scan(input, ":")
        rule = trim(input(1:splitidx-1))
        password = trim(input(splitidx+1:))

        splitidx = scan(rule, " ")
        ruleamount = trim(rule(1:splitidx-1))
        rulechar = trim(rule(splitidx+1:))

        splitidx = scan(ruleamount, "-")
        rulemin_str = trim(ruleamount(1:splitidx-1))
        rulemax_str = trim(ruleamount(splitidx+1:))

        read(rulemin_str,*) rulemin
        read(rulemax_str,*) rulemax

        password_len = len(password)
        counter = 0
        do i = 0, password_len - 1
            if (rulechar == password(i + 1:i + 1)) then
                counter = counter + 1
            end if
        end do

        is_valid = counter >= rulemin .and. counter <= rulemax
    end function

end program part1