.data
# Important Positions
displayAddress: .word 0x10008000

frogInitialPos: .word 0x10008E38
frogX: .word 0x0000003C		# NOTE: X and Y do not include the displayAddress. D.A is added to X and Y in the calculateFrogPos function
frogY: .word 0x00000E00

endOfFinishLine: .word 0x10008380

endOfWaterAndLogsRow1: .word 0x10008580
endOfWaterAndLogsRow2: .word 0x10008780
topLogsAnchor: .word 0x10008380 # Represetns where to start drawing the top row of logs from. This changes each time the screen updates
bottomLogsAnchor: .word 0x100085A0 # Represetns where to start drawing the bottom row of logs from. This changes each time the screen updates

endOfMidSafeZone: .word 0x10008980

endOfRoadAndCarsRow1: .word 0x10008B80
endOfRoadAndCarsRow2: .word  0x10008D80
topCarsAnchor: .word 0x10008980 # Represetns where to start drawing the top row of cars from. This changes each time the screen updates
bottomCarsAnchor: .word 0x10008BA0 # Represetns where to start drawing the bottom row of cars from. This changes each time the screen updates

endOfStartingLine: .word 0x10009000

topRowsOffset: .word 0x00000004 # Value to offset the top rows by (initially set to 4)
bottomRowsOffset: .word 0xFFFFFFFC # Value to offset the bottom rows by (initially set to -4)


frogStatus: .word 0x00000001 # If this is 1, the frog is alive. If it is 0, the frog is dead
redrawFrog: .word 0x00000005 # If this is 0, the program will redraw the frog at the starting position. This is done to show the frog has died before resetting

moveObstacles: .word 0x0000000A # If this is 0, the program will redraw the obstacles after they have moved. This is done to ease the frog in its movement across the scene

lives: .word 0x00000003


# Colours
redColourCode: .word 0xf44336
greenColourCode: .word 0xa4ec00
blueColourCode: .word 0x0000ff
purpleColourCode: .word 0xe700e7
tanColourCode: .word 0xd2b48c
brownColourCode: .word 0x7f6000
blackColourCode: .word 0x000000
darkGreenColourCode: .word 0x1e792c
lightBlueColourCode: .word 0x47fed3
yellowColourCode: .word 0xffd700


# Space allocation
firstRowOfLogs: .space 2048
secondRowOfLogs: .space 2048

firstRowOfCars: .space 2048
secondRowOfCars: .space 2048

.text
main:
# This block marks all of the important parts on the map. Exclusively for testing purposes
#lw $t0, displayAddress
#lw $t1, redColourCode
#sw $t1, 892($t0)
#sw $t1, 1916($t0)
#sw $t1, 2428($t0)
#sw $t1, 3452($t0)
#sw $t1, 4092($t0)

mainLoop:

jal drawScene
jal drawFrog
jal updateScreen




# Wait and repaint screen
li $v0, 32
li $a0, 100
syscall
j mainLoop


Exit:
li $v0, 10 # terminate the program gracefully
syscall


draw: #draw(start($a0), end($a1), colour($a2)): Draws starting from $a0, ending at $a1, in the colour $a2.
	drawRectanglesLoop:
		beq $a0, $a1, endDrawing
		sw $a2, 0($a0)
		addi $a0, $a0, 4
		j drawRectanglesLoop
		
		endDrawing:
		jr $ra
			
			
drawScene: #drawScene(start($a0), end($a1), colour($a2)): Draw the whole scene. Finish line, water, checkpoint, cars, and starting line
	addi $sp, $sp, -4 # Push $ra value to stack so when any of the nested function return, they return to drawScene
	sw $ra, 0($sp)
	lw $a0, displayAddress # Draw the finish line
	lw $a1, endOfFinishLine
	lw $a2, greenColourCode
	jal draw
	
	lw $a0, endOfFinishLine # Draw the water
	lw $a1, endOfWaterAndLogsRow2
	lw $a2, blueColourCode
	jal draw
	
	lw $a0, topLogsAnchor # Draw the top row of logs
	lw $a1, topLogsAnchor
	lw $a2, brownColourCode
	jal drawObstacleRow
	
	lw $a0, bottomLogsAnchor # Draw the bottom row of logs
	lw $a1, bottomLogsAnchor
	lw $a2, brownColourCode
	jal drawObstacleRow
	

	lw $a0, endOfWaterAndLogsRow2 # Draw the checkpoint
	lw $a1, endOfMidSafeZone
	lw $a2, tanColourCode
	jal draw
	
	lw $a0, endOfMidSafeZone # Draw the road
	lw $a1, endOfRoadAndCarsRow2
	lw $a2, blackColourCode
	jal draw
	
	lw $a0, topCarsAnchor # Draw the top row of cars
	lw $a1, topCarsAnchor
	lw $a2, redColourCode
	jal drawObstacleRow
	
	lw $a0, bottomCarsAnchor # Draw the top row of cars
	lw $a1, bottomCarsAnchor
	lw $a2, redColourCode
	jal drawObstacleRow


	lw $a0, endOfRoadAndCarsRow2 # Draw the starting line
	lw $a1, endOfStartingLine
	lw $a2, yellowColourCode
	jal draw
	
	# jal drawHearts
	
	lw $ra, 0($sp) # Restore $ra to the correct value so that it can return to main
	addi, $sp, $sp, 4
	jr $ra


drawObstacleRow: #drawObstacleRow(anchorPoint($a0), anchorPoint2($a1), colour($a2): Draw a single row of obstacles
	li $t0, 4 # Iteration counter
	addi $a1, $a1, 32 # Start drawing 8 pixels right from the beggining of the screen
	
	addi $sp, $sp, -4 # Push $ra value to stack so when any of the nested function return, they return to drawScene
	sw $ra, 0($sp)
	
	drawObstacle1Loop: # Draw the top left log
	beq $t0, $zero, setupObstacle2 # Iterate this loop 4 times (for 4 rows). When it is done, move on to the top right log
		
		jal draw
		
		subi $t0, $t0, 1 # Decrement $t0 to indicate a loop iteration
		addi $a0, $a0, 96 # Change $a0 to represent the beggining of the next row of the log
		addi $a1, $a1, 128 # Change $a1 to represent the end of the next row of the log
		
		j drawObstacle1Loop # loop
	
	setupObstacle2: 
	# Reset the variables so we can draw the second log properly
	li $t0, 4
	subi $a0, $a0, 448
	subi $a1, $a1, 448
	
		drawObstacle2Loop:  # Draw the top right log
		beq $t0, $zero, endObstacles # Iterate this loop 4 times (for 4 rows). When it is done, end the function
		
			jal draw
		
			subi $t0, $t0, 1 # Decrement $t0 to indicate a loop iteration
			addi $a0, $a0, 96 # Change $a0 to represent the beggining of the next row of the log
			addi $a1, $a1, 128 # Change $a1 to represent the end of the next row of the log
		
			j drawObstacle2Loop
	
	endObstacles: # End this function
		lw $ra, 0($sp) # Restore $ra to the correct value so that it can return to main
		addi, $sp, $sp, 4
		jr $ra



calculateFrogPos: # calculateFrogPos(frogX), y(frogY)): Add frogX with frogY and the display address to calculate the position of the frog
	lw $t0, frogX
	lw $t1, frogY
	lw $t3, displayAddress
	
	add $t0, $t0, $t1
	add $t0, $t0, $t3
	li $v0, 0
	add $v0, $v0, $t0
	
	jr $ra

drawFrog: #drawFrog(x(frogX), y(frogY)): Draw the frog at the position x+y
	addi $sp, $sp, -4 # Push $ra value to stack so when calculateFrogPos returns, it will return to drawFrog not main
	sw $ra, 0($sp)
	jal calculateFrogPos
	lw $ra, 0($sp) # Restore $ra to the correct value so that it can return to main
	addi, $sp, $sp, 4
	
	lw $t0, darkGreenColourCode # $t4 stores the dark green colour code
	lw $t1, frogStatus
	
	drawAliveFrog: # This is the frog we draw when it is alive
	beq $t1, 0x00000000, drawDeadFrog
	
		sw $t0, 0($v0) # Draw top left part of frog at the calculated position
		sw $t0, 12($v0) #Draw top right part of frog
		sw $t0, 128($v0) # Next 6 lines draw body of frog
		sw $t0, 132($v0)
		sw $t0, 136($v0)
		sw $t0, 140($v0)
		sw $t0, 260($v0)
		sw $t0, 264($v0)
		sw $t0, 384($v0) # Draw bottom of the frog
		sw $t0, 388($v0) 
		sw $t0, 392($v0) 
		sw $t0, 396($v0) 
		jr $ra 
	
	drawDeadFrog: # This is the frog we draw when it is dead
		sw $t0, 0($v0) # Draw top left part of frog at the calculated position
		sw $t0, 12($v0) #Draw top right part of frog
		sw $t0, 132($v0) #Next 4 lines draw body of frog
		sw $t0, 136($v0)
		sw $t0, 260($v0)
		sw $t0, 264($v0)
		sw $t0, 384($v0) # Draw bottom left of frog
		sw $t0, 396($v0) # Draw bottom right of frog
		
		jr $ra 
		
killFrog:
	la $t0, frogStatus # Change the frog status to 0 so the correct frog is drawn
	li $t1, 0x00000000
	sw $t1, ($t0)
	
	lw $t0, redrawFrog
	bne $t0, 0x00000000, endKilling
	# Reset the frog X position to its initial position
	la $t0, frogX 
	li $t1, 0x0000003C
	sw $t1, ($t0)
	
	# Reset the frog Y position to its initial position
	la $t0, frogY 
	li $t1, 0x00000E00
	sw $t1, ($t0)
	
	# Change the frog status so the correct frog is drawn next iteration
	la $t0, frogStatus 
	li $t1, 0x00000001
	sw $t1, ($t0)
	
	# Change the redrawFrog value so there is enough delay between the frog dying and the frog being reset to its original position
	la $t0, redrawFrog 
	li $t1, 0x00000005
	sw $t1, ($t0)
	
	
	endKilling:
		# Decrement the redrawFrog value so there is enough delay between the frog dying and the frog being reset to its original position
		la $t0, redrawFrog 
		lw $t1, redrawFrog
		subi $t1, $t1, 1
		sw $t1, ($t0)
		jr $ra

handleInput:
	# If a key is pressed, $t8 will be set to 1 and the code should enter into keyboard_input
	lw $t8, 0xffff0000
	beq $t8, 1, keyboard_input
		jr $ra		# If there is no keyboard input, exit into main
		
	keyboard_input: #!!!NOTE!!!: Currently being met with address out of range error
		lw $t2, 0xffff0004 # Load the ascii value of the pressed key
		beq $t2, 0x77, respond_to_W
		beq $t2, 0x61, respond_to_A
		beq $t2, 0x73, respond_to_S
		beq $t2, 0x64, respond_to_D
		
		respond_to_W:
			#access
   			lw $a0, frogY 

   			#modify
   			la $a0, frogY #get address
   			lw $t1, 0($a0) #new value
   			addi $t1, $t1, -128 # Move up 2 rows
   			sw $t1, ($a0) #save new value
   			
   			j inputHandled
   			
		respond_to_A:
			#access
   			lw $a0, frogX 

   			#modify
   			la $a0, frogX #get address
   			lw $t1, 0($a0) #new value
   			addi $t1, $t1, -4 # Move left two columns
   			sw $t1, ($a0) #save new value
   			
   			j inputHandled

		respond_to_S:
			#access
   			lw $a0, frogY 

   			#modify
   			la $a0, frogY #get address
   			lw $t1, 0($a0) #new value
   			addi $t1, $t1, 128 # Move down 2 rows
   			sw $t1, ($a0) #save new value
   			
   			j inputHandled
   			
		respond_to_D:
			#access
   			lw $a0, frogX 

   			#modify
   			la $a0, frogX #get address
   			lw $t1, 0($a0) #new value
   			addi $t1, $t1, 4 # Move right two columns
   			sw $t1, ($a0) #save new value
   			
   			j inputHandled
   	inputHandled:
   		jr $ra


   			
updateLogs:
	addi $sp, $sp, -4 # Push $ra value to stack so when calculateFrogPos returns, it will return to drawFrog not main
	sw $ra, 0($sp)
	

	la $a0, topLogsAnchor #get address
   	lw $t1, 0($a0) #new value

   	lw $t2, topRowsOffset # Decide whether the log should move left or right
   	add $t1, $t1, $t2 # Move right/left two columns (Depending on topRowsOffset)
   	sw $t1, ($a0) #save new value
   	
   	
   	la $a0, bottomLogsAnchor #get address
   	lw $t1, 0($a0) #new value
   	lw $t2, bottomRowsOffset # Decide whether the log should move left or right
   	add $t1, $t1, $t2 # Move left two columns
	sw $t1, ($a0) #save new value
	
	lw $ra, 0($sp) # Restore $ra to the correct value so that it can return to main
	addi, $sp, $sp, 4
	
   	jr $ra
   	
   	

updateCars:
	addi $sp, $sp, -4 # Push $ra value to stack so when calculateFrogPos returns, it will return to drawFrog not main
	sw $ra, 0($sp)
	
	la $a0, topCarsAnchor #get address
   	lw $t1, 0($a0) #new value
   	lw $t2, topRowsOffset # Decide whether the log should move left or right
   	add $t1, $t1, $t2 # Move right two columns
   	sw $t1, ($a0) #save new value
   	
   	
   	la $a0, bottomCarsAnchor #get address
   	lw $t1, 0($a0) #new value
   	lw $t2, bottomRowsOffset # Decide whether the log should move left or right
   	add $t1, $t1, $t2 # Move left two columns
   	sw $t1, ($a0) #save new value
   	
   	lw $ra, 0($sp) # Restore $ra to the correct value so that it can return to main
	addi, $sp, $sp, 4
   	jr $ra
   			   			   			   			

handleRowOverflow: # This function checks to see if the logs are in a certain location. If they are, the function reverses the direction of all the obstacles
	lw $t0, topLogsAnchor
	
	rightOverflow: # Handle top obstacles overflowing in the right direction
	bne $t0, 0x100083A0, leftOverflow # Check to see if the top logs are about to overflow in the right direction
		la $t1, topRowsOffset #get address
		lw $t2, topRowsOffset #get value
		li $t3, 0xFFFFFFFF # negative 1
		mult $t2, $t3
		mflo $t2
		sw $t2, ($t1) # Reverse the direction the top logs & cars are moving
		
		la $t1, bottomRowsOffset #get address
		lw $t2, bottomRowsOffset #get value
		li $t3, 0xFFFFFFFF # negative 1
		mult $t2, $t3
		mflo $t2
		sw $t2, ($t1) # Reverse the direction the bottom logs & cars are moving
		
		j overflowHandled
	
	leftOverflow: # Handle top obstacles overflowing in the left direction
	bne $t0, 0x10008380, overflowHandled # Check to see if the top logs are about to overflow in the left direction
		la $t1, topRowsOffset #get address
		lw $t2, topRowsOffset #get value
		li $t3, 0xFFFFFFFF # negative 1
		mult $t2, $t3
		mflo $t2
		sw $t2, ($t1) # Reverse the direction the top logs & cars are moving
		
		la $t1, bottomRowsOffset #get address
		lw $t2, bottomRowsOffset #get value
		li $t3, 0xFFFFFFFF # negative 1
		mult $t2, $t3
		mflo $t2
		sw $t2, ($t1) # Reverse the direction the bottom logs & cars are moving
		
		j overflowHandled
		
	overflowHandled:
		jr $ra
		   			

handleCollision: # !!!NOTE!!! Still need to add code for right side of frog colliding with obstacles
	# Push $ra value to stack so when calculateFrogPos returns, it will return to drawFrog not main
	addi $sp, $sp, -4 
	sw $ra, 0($sp)
	
	# Set up variables to check for collision
	lw $a0, frogX
   	lw $a1, frogY
	lw $t0, displayAddress
	add $t0, $t0, $a0
	add $t0, $t0, $a1 #$t0 now holds the address of the location of the top left foot of the frog
	
	subi $t1, $t0, 4 #$t1 now holds the address of the location immediately left of the top left foot of the frog
	lw $t2, 0($t1) #$t2 now holds the location immediately left to the top left foot of the frog 
	
	addi $t1, $t0, 380 #$t1 now holds the address of the location immediately left to the bottom left foot of the frog
	lw $t3, 0($t1) #$t3 now holds the location immediately left to the bottom left foot of the frog 
	
	addi $t1, $t0, 16 #$t1 now holds the address immediately to the right of the top right foot of the frog
	lw $t4, 0($t1) #$t1 now holds the location immediately to the right of the top right foot of the frog
	
	addi $t1, $t0, 396 #$t1 now holds the address of the location immediately right of the bottom right foot of the frog
	lw $t5, 0($t1) #$t3 now holds the location mmediately right to the bottom right foot of the frog 
	
	# If chunk to check if any of the corners of the frog have hit a car
	beq $t2, 0xf44336, obstacleHit
	beq $t3, 0xf44336, obstacleHit
	beq $t4, 0xf44336, obstacleHit
	beq $t5, 0xf44336, obstacleHit
	
	# If chunk to check if any of the corners of the frog have hit water
	beq $t2, 0x0000ff, obstacleHit
	beq $t3, 0x0000ff, obstacleHit
	beq $t4, 0x0000ff, obstacleHit
	beq $t5, 0x0000ff, obstacleHit
	
	# Checks if the frog has fully crossed into the mid checkpoint
	beq $t3, 0xd2b48c, crossedCheckpoint
	
	# Checks if the frog has fully crossed into the finish line
	beq $t3, 0xa4ec00, crossedFinishLine
	
	j handledCollisions
	
	obstacleHit: # Inidicate the frog has hit an obstacle so it has died
		jal killFrog
		j handledCollisions
	
	crossedCheckpoint: # Fill in the midcheckpoint with light blue to indicate the frog has crossed into it
		la $t2 tanColourCode #get address
   		lw $t3, lightBlueColourCode
   		sw $t3, ($t2) #save new value
   		j handledCollisions
   	
   	crossedFinishLine:  # Fill in the finish line with light blue to indicate the frog has crossed into it
   		la $t2 greenColourCode #get address
   		lw $t3, lightBlueColourCode
   		sw $t3, ($t2) #save new value
   		j handledCollisions
	
#	carsCheck:
#	bne $t2, 0xf44336, logsCheck # Check if the top left foot of the frog is touching a car
#	bne $t4, 0xf44336, logsCheck # Check if the top right foot of the frog is touching a car
#		jal killFrog
#		j handledCollisions
#	
#	logsCheck:
#	bne $t2, 0x0000ff, checkpointCheck
#	bne $t3, 0x0000ff, checkpointCheck
#		jal killFrog
#		j handledCollisions
#	
#	checkpointCheck: # handle if the frog has fully entered the middle safe zone
#	bne $t3, 0xd2b48c, finishLineCheck # Check if the bottom left foot of the frog is in the tan colour zone
#		la $t2 tanColourCode #get address
#   		lw $t3, lightBlueColourCode
#   		sw $t3, ($t2) #save new value
#   		j handledCollisions
#   	
#   	finishLineCheck:
#   	bne $t3, 0xa4ec00, handledCollisions
#   		la $t2 greenColourCode #get address
#   		lw $t3, lightBlueColourCode
#   		sw $t3, ($t2) #save new value
#   		j handledCollisions
#   		
		
		
	handledCollisions:
		lw $ra, 0($sp) # Restore $ra to the correct value so that it can return to main
		addi, $sp, $sp, 4
		jr $ra



drawObstacles:
	addi $sp, $sp, -4 # Push $ra value to stack so when calculateFrogPos returns, it will return to drawFrog not main
	sw $ra, 0($sp)
	
	lw $t0, moveObstacles
	li $t1, 0x00000000
	
	# Check if the program should redraw the obstacles or not
	bne $t0, $t1, obstaclesNotRedrawn 
		jal updateLogs
		jal updateCars
		jal handleRowOverflow
		la $t0, moveObstacles
		li $t1, 0x0000000A
		sw $t1, ($t0)
		j doneRedrawing
		
	# If the program does not redraw the obstacles. Decrement the obstacle counter by 1 and exit the function
	obstaclesNotRedrawn:
		la $t0, moveObstacles
		lw $t1, moveObstacles
		subi $t1, $t1, 1
		sw $t1, ($t0)
		j doneRedrawing
	
	doneRedrawing:
	lw $ra, 0($sp) # Restore $ra to the correct value so that it can return to main
	addi, $sp, $sp, 4
	jr $ra


drawHearts:
	lw $t0, lives
	la $t1, displayAddress
	lw $t2, redColourCode
	la $t3, ($t1)
	heartsLoop:
	beq $t0, 0x00000000, heartsDrawn
		sw $t2, 0($t3)
		addi $t3, $t3, 8
		j heartsLoop
	
	heartsDrawn:
		jr $ra


updateScreen:
 	addi $sp, $sp, -4 # Push $ra value to stack so when calculateFrogPos returns, it will return to drawFrog not main
	sw $ra, 0($sp)
	
	jal handleInput
	jal drawObstacles
#	jal updateLogs
#	jal updateCars
#	jal handleRowOverflow
	jal handleCollision

	
	lw $ra, 0($sp) # Restore $ra to the correct value so that it can return to main
	addi, $sp, $sp, 4
	
	jr $ra
