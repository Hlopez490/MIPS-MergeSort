# Hector Lopez Lopez HXL190015
# Run Program and follow directions on console

.data
input: 		.asciiz "Enter List Size: "
userAsk: 	.asciiz "Enter List values one at a time: "
invalid: 	.asciiz "! Not Valid List Size !"
space: 		.asciiz " "
result: 	.asciiz "Sorted List: "
.align 4
list:		.word


.text

main:
    	# Print input label
   	li 	$v0, 4
   	la 	$a0, input
    	syscall 

        # Read amount of integers to be inputed.
    	li 	$v0, 5
   	syscall
   	addi	$s5, $v0, 0		# Save size into $s5

        # Put input into $t7, number of integers in list    
    	addi 	$t7, $s5, 0		# Move length into $t7 for using
    	li 	$t4, 4

    	bgt 	$t7, 32, invd		# Ensure list size is under 32
    	
 	li 	$v0, 4			# Ask user to input numbers of the list
   	la 	$a0, userAsk
    	syscall
	
   	li 	$t6, 0 			# Used to index list at insertion
    	j 	insert

insert: 
        beq 	$t7, 0, next		# Check if 0 == input
            
        li 	$v0, 5			# Take in user input
        syscall
            
        sw 	$v0, list($t6)		# Store user input into list
        addi 	$t6, $t6, 4 		# Add 4 to the index of the list
        addi 	$t7, $t7, -1		# Subtract 1 from the number of items to add to list
            
        j 	insert
        
next:
	la	$a0, list		# Load the start address of the list
	move	$t0, $s5		# Give list length
	sll	$t0, $t0, 2		# Multiple the list length by 4 (the size of the elements)
	add	$a1, $a0, $t0		# Calculate the list end address
	jal	mergeRecursive			# Call the merge sort function
  	b	print			# We are finished sorting and ready to print
  	
mergeRecursive:

	addi	$sp, $sp, -16		# Adjust stack pointer
	sw	$ra, 0($sp)		# Store the return address on the stack
	sw	$a0, 4($sp)		# Store the list start address on the stack
	sw	$a1, 8($sp)		# Store the list end address on the stack
	
	sub 	$t0, $a1, $a0		# Calculate the difference between the start and end address

	ble	$t0, 4, sort		# If the list only contains a single element return
	
	srl	$t0, $t0, 3		# Divide the list size by 8 to half the number of elements
	sll	$t0, $t0, 2		# Multiple that number by 4 to get half of the list size
	add	$a1, $a0, $t0		# Calculate the midpoint address of the list
	sw	$a1, 12($sp)		# Store the list midpoint address on the stack
	
	jal	mergeRecursive		# Call recursively on the first half of the list
	
	lw	$a0, 12($sp)		# Load the midpoint address of the list from the stack
	lw	$a1, 8($sp)		# Load the end address of the list from the stack
	
	jal	mergeRecursive		# Call recursively on the second half of the list
	
	lw	$a0, 4($sp)		# Load the list start address from the stack
	lw	$a1, 12($sp)		# Load the list midpoint address from the stack
	lw	$a2, 8($sp)		# Load the list end address from the stack
	
	jal	merge			# Merge the two list halves
	
sort:				

	lw	$ra, 0($sp)		# Load the return address from the stack
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr	$ra			
	
merge:
	addi	$sp, $sp, -16		# Adjust the stack pointer
	sw	$ra, 0($sp)		# Store the return address on the stack
	sw	$a0, 4($sp)		# Store the start address on the stack
	sw	$a1, 8($sp)		# Store the midpoint address on the stack
	sw	$a2, 12($sp)		# Store the end address on the stack
	
	move	$s0, $a0		# Create a copy of the first half address
	move	$s1, $a1		# Create a copy of the second half address
	
loop:

	lw	$t0, 0($s0)		# Load the first half position pointer
	lw	$t1, 0($s1)		# Load the second half position pointer
	
	bgt	$t1, $t0, noshift	# If the lower value is already first don't shift
	
	move	$a0, $s1		# Load the argument for the element to move
	move	$a1, $s0		# Load the argument for the address to move it to shift the element to the new position 
	jal	shift			
	
	addi 	$s1, $s1, 4		# Increment the second half index
noshift:
	addi	$s0, $s0, 4		# Increment the first half index
	
	lw	$a2, 12($sp)		# Reload the end address
	bge	$s0, $a2, mergeEnd	# End the loop when both halves are empty
	bge	$s1, $a2, mergeEnd	# End the loop when both halves are empty
	b	loop
	
mergeEnd:
	
	lw	$ra, 0($sp)		# Load the return address
	addi	$sp, $sp, 16		# Adjust the stack pointer
	jr 	$ra			

shift:
	li	$t0, 10
	ble	$a0, $a1, sEnd		# If we are at the location, stop shifting
	addi	$t6, $a0, -4		# Find the previous address in the list
	lw	$t7, 0($a0)		# Get the current pointer
	lw	$t8, 0($t6)		# Get the previous pointer
	sw	$t7, 0($t6)		# Save the current pointer to the previous address
	sw	$t8, 0($a0)		# Save the previous pointer to the current address
	move	$a0, $t6		# Shift the current position back
	b 	shift			
sEnd:
	jr	$ra			# Return to merge

print:
	la 	$t1, list		# Load address of mergedList
	move	$t2, $s5		# Move length of list into $t2
	
	li      $v0, 4      		# Print out Resulting list
    	la    	$a0, result
    	syscall
	L1:
		lw 	$t3, 0($t1)	# $t3 = list[i]
			
		li      $v0, 1      	# Output integer in list[i]
    		move    $a0, $t3
    		syscall
    			
    		li      $v0, 4      	# Output and space
    		la    	$a0, space
    		syscall
			
		addi	$t1, $t1, 4   	# Iterate through list
		addi	$t2, $t2, -1
		bgtz  	$t2, L1  	# If at end value return to exit
		j	exit		# Jump to ending
	
invd:
   	 li 	$v0, 4			# Print out invalid list 
   	 la 	$a0, invalid
  	 syscall
			
exit:					# Exit Program
	li	$v0 , 10
	syscall

