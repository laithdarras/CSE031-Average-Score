.data

orig: .space 100 # In terms of bytes (25 elements * 4 bytes each)
sorted: .space 100
str0: .asciiz "Enter the number of assignments (between 1 and 25): "
str1: .asciiz "Enter score: "
str2: .asciiz "Original scores: "
str3: .asciiz "Sorted scores (in descending order): "
str4: .asciiz "Enter the number of (lowest) scores to drop: "
str5: .asciiz "Average (rounded down) with dropped scores removed: "
newLine: .asciiz "\n"
space: .asciiz " "

.text

# This is the main program.
# It first asks user to enter the number of assignments.
# It then asks user to input the scores, one at a time.
# It then calls selSort to perform selection sort.
# It then calls printArray twice to print out contents of the original and sorted scores.
# It then asks user to enter the number of (lowest) scores to drop.
# It then calls calcSum on the sorted array with the adjusted length (to account for dropped scores).
# It then prints out average score with the specified number of (lowest) scores dropped from the calculation.

main:

addi $sp, $sp -4
sw $ra, 0($sp)
li $v0, 4
la $a0, str0
syscall

li $v0, 5 # Read the number of scores from user
syscall

move $s0, $v0 # $s0 = numScores
move $t0, $0
la $s1, orig # $s1 = orig
la $s2, sorted # $s2 = sorted

loop_in:

li $v0, 4
la $a0, str1
syscall

sll $t1, $t0, 2
add $t1, $t1, $s1
li $v0, 5 # Read elements from user
syscall

sw $v0, 0($t1)
addi $t0, $t0, 1
bne $t0, $s0, loop_in
move $a0, $s0
jal selSort # Call selSort to perform selection sort in original array

li $v0, 4
la $a0, str2
syscall

move $a0, $s1 # More efficient than la $a0, orig
move $a1, $s0
jal printArray # Print original scores

li $v0, 4
la $a0, str3
syscall

move $a0, $s2 # More efficient than la $a0, sorted
jal printArray # Print sorted scores

li $v0, 4
la $a0, str4
syscall

li $v0, 5 # Read the number of (lowest) scores to drop
syscall

move $a1, $v0
sub $a1, $s0, $a1 # numScores - drop
move $a0, $s2
jal calcSum # Call calcSum to RECURSIVELY compute the sum of scores that are not dropped

# Your code here to compute average and print it
lw $ra, 0($sp)
addi $sp, $sp 4
li $v0, 10
syscall
# printList takes in an array and its size as arguments.
# It prints all the elements in one line with a newline at the end.

printArray:
# Your implementation of printList here
    li $t0, 0 	# i = 0

printArrayLoop:
    # Comparison
    slt $t1, $t0, $a1 	# Set t1 to 1 if i < len, else 0
    beq $t1, $zero, printArrayExit 	# Branch if i >= len
    
    # arr[i]
    lw $t2, 0($a0)
    li $v0, 1
    addu $a0, $zero, $t2
    syscall
    
    # Printing a string
    li $v0, 4
    la $a0, space
    syscall
    
    addi $a0, $a0, 4 	# (arr + 1)
    addi $t0, $t0, 1 	# ++i
    j printArrayLoop 	# Jump back to loop

printArrayExit:
    li $v0, 4 	# Syscall code for printing a string
    la $a0, newLine 	# Formatting purposes
    syscall
    jr $ra

# selSort takes in the number of scores as argument.
# It performs SELECTION sort in descending order and populates the sorted array

selSort:
    addi $t0, $zero, 1
    beq $a0, $t0, edgeCase   # Edge case: only one element in the array
    add $t0, $zero, $zero	# Initialize outer loop index

outerLoop:
    addi $t1, $t0, 1	     # Init the starting val
    addu $t2, $zero, $t0     # Sets max index equal to current iteration

innerLoop:
    sll $t3, $t2, 2          # Calculate offset for sorted[maxIndex]
    lw $t3, sorted($t3)      # Load sorted[maxIndex]

    sll $t4, $t1, 2          # Calculate offset for sorted[j]
    lw $t4, sorted($t4)      # Load sorted[j]

    slt $t5, $t3, $t4        # Check if sorted[maxIndex] < sorted[j]

    bne $t5, $zero, update	# Branch to update if sorted[j] > sorted[maxIndex]

    # Increment and continue
    addi $t1, $t1, 1
    bne $t1, $a0, innerLoop

    # Swap elements
    sll $t6, $t0, 2          # Calculate offset for sorted[i]
    lw $t6, sorted($t6)      # Load sorted[i]

    sll $t3, $t2, 2          # Calculate offset for sorted[maxIndex]
    lw $t3, sorted($t3)      # Load sorted[maxIndex]
    addu $t7, $zero, $t3            # Temporarily store sorted[maxIndex]

    sll $t3, $t2, 2          # Calculate offset for sorted[maxIndex]
    sw $t6, sorted($t3)      # Store sorted[i] into sorted[maxIndex]

    sll $t6, $t0, 2          # Calculate offset for sorted[i]
    sw $t7, sorted($t6)      # Store temp value into sorted[i]

    addi $t0, $t0, 1	# Increment outer loop index

    # Continue outer loop
    sub $t8, $a0, 1          # Calculate loop termination condition
    bne $t0, $t8, outerLoop

    jr $ra

update:
    # Update max index
    addu $t2, $zero, $t1
    j innerLoop

edgeCase:
    # Only one element in the array
    lw $t0, orig($zero)
    sw $t0, sorted($zero)
    jr $ra

# calcSum takes in an array and its size as arguments.
# It RECURSIVELY computes and returns the sum of elements in the array.
# Note: you MUST NOT use iterative approach in this function.

calcSum:
# Your implementation of calcSum here
# Recursive summation of [0 ... len-1]
# a0 is pointer to array, a1 is length
    addi $t0, $a1, 1
    li $t1, 0
    slt $t2, $t0, $t1 	# len < 0
    bne $t2, $zero, calcSumExit 	# Branch if len <= 0 then return to caller
    
    # Recursive part
    addi $a1, $a1, -1 	# (len - 1)
    lw $t0, 0($a0)	# Load arr[len - 1] into t0
    addi $a0, $a0, 4	# Move pointer to next element (arr + 1)
    jal calcSum 	# Recursive call
    add $v0, $v0, $t0 	# Add arr[len - 1] to sum
    
calcSumExit:
    jr $ra