# Compute several Fibonacci numbers and put in array, then print
.data
fibs:.word	0 : 19         # "array" of words to contain fib values
size:.word	19             # size of "array" (agrees with array declaration)

.text
      la   $s0, fibs        # load address of array
      la   $s5, size        # load address of size variable
      lw   $s5, 0($s5)      # load array size
      
      li   $s2, 1           # 1 is the known value of first and second Fib. number
      sw   $s2, 0($s0)      # F[0] = 1
      sw   $s2, 4($s0)      # F[1] = F[0] = 1
      addi $s1, $s5, -2     # Counter for loop, will execute (size-2) times
      
      # Loop to compute each Fibonacci number using the previous two Fib. numbers.
loop: lw   $s3, 0($s0)      # Get value from array F[n-2]
      lw   $s4, 4($s0)      # Get value from array F[n-1]
      add  $s2, $s3, $s4    # F[n] = F[n-1] + F[n-2]
      sw   $s2, 8($s0)      # Store newly computed F[n] in array
      addi $s0, $s0, 4      # increment address to now-known Fib. number storage
      addi $s1, $s1, -1     # decrement loop counter
      bgtz $s1, loop        # repeat while not finished