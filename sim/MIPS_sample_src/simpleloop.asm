        lui     $s1, 0          # set s1 = 0
        addi    $s1, $s1, 5     # set s1 = 5
loop:   addi    $s1, $s1, -1    # s1 = s1 - 1
        bgez    $s1, loop       # while s1 >= 0