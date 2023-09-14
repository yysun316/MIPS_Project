# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# write down your info and the answers for TASK 0 as COMMENTS here

# TASK 0:
# Question 1: (5*8 + 6)*32 = 1472 bytes


# Question 2:
# $s0 = 5
# $s1 = 4



#--------------------------------------------------------------------





.data
#--------------------------------------------------------------------
# a 8 x 8 grid, each tile has 8 integer attributes, 
# each attribute occupies 4 bytes, 
# all 512 words are initialized to 0.
# 
# tile attributes(strictly ordered): 
# x: the horizontal coordinate of the tile in the GUI
# y: the vertical coordinate of the tile in the GUI
# row: the rowIndex(vertical) of the tile in the grid (starts from 0)
# col: the colIndex(horizontal) of the tile in the grid (starts from 0)
# kind: the kind of the tile, ranged from 0 to 5
# match: the points of the tile gained from matched patterns
# hscore: the points of the tile gained from being in a horizontal matched pattern
# vscore: the points of the tile gained from being in a vertical matched pattern
#--------------------------------------------------------------------
grid: .word 0:512

tileSize: .word 54 # the size(length) of each square cell in the grid GUI
isSwap: .word 0 # if current game loop has two tiles swapped
isMoving: .word 0 # if current game loop has unfinished moving tiles
click: .word 0 # the number of clicks in current game loop, ranged from 0 to 2
row0: .word 0 # the rowIndex of the first clicked tile
col0: .word 0 # the colIndex of the first clicked tile
row1: .word 0 # the rowIndex of the second clicked tile
col1: .word 0 # the colIndex of the second clicked tile
step: .word 0 # the cummulative number of successful swaps 
score: .word 0 # the cummulative score of the game
matchFound: .word 0 # if current game loop has at least one matched patterns
winScore: .word 400 # the score required to win the game, !! you can freely adjust this value for easy testing
stepLimit: .word 30 # the step limit of the game, !! you can freely adjust this value for easy testing
winText:	.asciiz "You Win! "
loseText:	.asciiz "Game Over! "


#--------------------------------------------------------------------
#--------------------------------------------------------------------
#--------------------------------------------------------------------
.text
#--------------------------------------------------------------------
# procedure: initialize the game grid
#--------------------------------------------------------------------
initializeGrid:

	#***** Task 1 *****
	# Initialize the grid to fill each cell with a tile of random kind.
	#
	# hint: 
	# step 1: Iterate over each tile of the grid using a nested loop.
    # step 2: For each tile, do the following:
    #         2 - 1. for attribute x, assign the product of the tile's colIndex and tileSize to it.
    #         2 - 2. for attribute y, assign the product of the tile's rowIndex and tileSize to it.
    #         2 - 3. for attribute row, assign the tile's rowIndex to it.
    #         2 - 4. for attribute col, assign the tile's colIndex to it.
    #         2 - 5. for attribute kind, assign a random number ranged from 0 to 5 (inclusive) to it, use syscall 42
    #         2 - 6. remove the skeleton code as indicated below.
	#------ Your code starts here ------
	la $t0, tileSize
	lw $t0, 0($t0) #$t0 = tileSize
	addi $t1, $zero, 0 #$t1 = rowIdx
	
intRowLoop:
	addi $t3, $zero, 8 # $t3 = 8
	beq $t1, $t3, ExitIntLoop
	addi $t2, $zero, 0 #$t2 = colIdx

intColLoop:
	addi $t3, $zero, 8
	beq $t2, $t3, NextIntLoop

intAttributes:
	add $a0, $t1, $zero # rowIdx
	add $a1, $t2, $zero # colIdx
	addi $sp, $sp, -16
	sw $t0, 12($sp)
	sw $t1, 8($sp)
	sw $t2, 4($sp)
	sw $ra, 0($sp)
	jal getCellAddress
	lw $ra, 0($sp)
	lw $t2, 4($sp)
	lw $t1, 8($sp)
	lw $t0, 12($sp)
	addi $sp, $sp, 16
	add $t4, $v0, $zero # $t4 = cellAddress
	
	mult $t2, $t0 # colIdx x tileSize 
	mflo $t5 # x
	sw $t5, 0($t4)
	
	mult $t1, $t0
	mflo $t5 # y
	sw $t5, 4($t4)
	
	sw $t1, 8($t4) #row
	
	sw $t2, 12($t4) #col
	
	addi $a1,$zero, 6 #upperbound = 6
	li $v0, 42
	syscall #rand number is in $a0
	sw $a0, 16($t4)
	
	addi $t2, $t2, 1 # colIndex ++
	j intColLoop

NextIntLoop:
	addi $t1, $t1, 1 # rowIndex ++
	j intRowLoop
	
ExitIntLoop: 
	
	

	#------ Your code ends here ------

    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # Remove the following code after you finish task 1, this loads a pre-defined grid for testing.
    # If you cannot finish task 1, leave it so that your later tasks can be tested, but you will not get the mark for task 1
    # la $a0, grid
     # li $v0, 208
     # syscall
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

li $v0, 200
syscall

##########################################################
la $a0, grid
li $a1, 1
li $v0, 209
syscall

la $a0, grid
li $v0, 210
syscall
##########################################################

#--------------------------------------------------------------------
# procedure: main game loop
#--------------------------------------------------------------------
mainGameLoop:

    jal handleMouseClick
    jal checkHorizontalMatch
    jal checkVerticalMatch #***** Task 2 *****
    
    ##########################################################
    la $a0, grid
    li $a1, 2
    li $v0, 209
    syscall
    ##########################################################
    jal updateMatch        #***** Task 3 *****
    
    ##########################################################
    la $a0, grid
    li $a1, 3
    li, $v0, 209
    syscall
    ##########################################################
    
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # This is not neccessary for your tasks
    # Read the project description and tutorial slides about how to use syscall 207
    # Remember to set a BREAKPOINT in MARS
#la $a0, grid
#li $a1, 0
#li $v0, 207
#syscall
    #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    jal updatePos
    jal revertSwap
    jal moveMatch          #***** Task 4 *****
    ##########################################################
    la $a0, grid
    li $a1, 4
    li, $v0, 209
    syscall
    ##########################################################
    jal replaceMatch       #***** Task 5 *****
    ##########################################################
    la $a0, grid
    li $a1, 5
    li, $v0, 209
    syscall
    ##########################################################


    # The following statements are to render the grid in the GUI
    # They are implemented for you already, do not modify them
    # You can read the project description about each syscall
    la $t0, matchFound
    lw $t0, 0($t0)
    beq $t0, $zero, mainGameLoopContinue

    la $t1, isMoving
    lw $t1, 0($t1)
    li $t2, 1
    beq $t1, $t2, mainGameLoopContinue

    li $v0, 204
    syscall

    mainGameLoopContinue:
    la $t0, click
    la $t1, col0
    la $t2, row0

    la $a0, grid
    lw $a1, 0($t0)
    lw $a2, 0($t1)
    lw $a3, 0($t2)
    li $v0, 201
    syscall

    la $t0, score
    lw $a0, 0($t0)
    li $v0, 202
    syscall

    la $t0, step
    lw $a0, 0($t0)
    li $v0, 203
    syscall	

    li $a0, 15
    li $v0, 32
    syscall

	la $t0, isMoving
    lw $t0, 0($t0)
    li $t1, 1
    beq $t0, $t1, skipConditionCheck

    la $t0, score 
    lw $t0, 0($t0)
    la $t1, winScore
    lw $t1, 0($t1)
    sub $t2, $t0, $t1
    bgez $t2, endGame

    la $t0, step
    lw $t0, 0($t0)
    la $t1, stepLimit
    lw $t1, 0($t1)
    sub $t2, $t0, $t1
    bgtz $t2, endGame

	skipConditionCheck:
    j mainGameLoop

endMainGameLoop:


#--------------------------------------------------------------------
# procedure: perform actions based the number of clicks
#--------------------------------------------------------------------
handleMouseClick:
    addi $sp, $sp, -36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)

    li $v0, 206
    syscall
    add $t0, $v0, $zero # returned posX
    add $t1, $v1, $zero # returned posY
    bltz $t0, endHandleMouseClick
    bltz $t1, endHandleMouseClick

    la $s0, click
    la $s1, tileSize
    lw $s1, 0($s1)
    add $s2, $t0, $zero # posX of cursor
    add $s3, $t1, $zero # posY of cursor

    updateClick:
        la $t0, isSwap
        lw $t0, 0($t0)
        la $t1, isMoving
        lw $t1, 0($t1)
        or $t2, $t0, $t1
        li $t5, 1
        beq $t2, $t5, endUpdateClick # if(!isSwap && !isMoving)
        lw $t4, 0($s0) # click++
        addi $t4, $t4, 1
        sw $t4, 0($s0)

    endUpdateClick:


    lw $t1, 0($s0) 
    li $t2, 1
    li $t3, 2
    beq $t1, $t2, handleClickOnce
    beq $t1, $t3, handleClickTwice
    j endHandleMouseClick


    handleClickOnce:
        div $s2, $s1
        mflo $t0 # colIndex of currently clicked tile
        la $t2, col0
        sw $t0, 0($t2)
        div $s3, $s1
        mflo $t1 # rowIndex of currently clicked tile
        la $t3, row0
        sw $t1, 0($t3)
        
        bltz $t0, clearClickCount # cursor boundary check
        bltz $t1, clearClickCount
        sub $t2, $t0, 7
        sub $t3, $t1, 7
        bgtz $t2, clearClickCount
        bgtz $t3, clearClickCount
        j endHandleClickOnce

    clearClickCount:
        sw $zero, 0($s0)

    endHandleClickOnce:
        j endHandleMouseClick


    handleClickTwice:
        div $s2, $s1
        mflo $s4 # colIndex of currently clicked tile
        la $t6, col1
        sw $s4, 0($t6)
        div $s3, $s1
        mflo $s5 # rowIndex of currently clicked tile
        la $t7, row1
        sw $s5, 0($t7)

        la $t6, col0
        lw $t2, 0($t6) # colIndex of first clicked tile
        sub $t4, $s4, $t2
        add $a0, $t4, $zero
        jal absoluteValue
        add $s6, $v0, $zero
        la $t7, row0
        lw $t3, 0($t7) # rowIndex of first clicked tile
        sub $t5, $s5, $t3
        add $a0, $t5, $zero
        jal absoluteValue
        add $t5, $v0, $zero
        add $t6, $s6, $t5 # index difference between first and second clicked tile
        li $t7, 1
        bne $t6, $t7, revertClickCount
        bltz $s4, revertClickCount # cursor boundary check
        bltz $s5, revertClickCount
        sub $t4, $s4, 7
        sub $t5, $s5, 7
        bgtz $t4, revertClickCount
        bgtz $t5, revertClickCount


        la $t7, row0
        lw $t3, 0($t7) # rowIndex of first clicked tile
        la $t6, col0
        lw $t2, 0($t6) # colIndex of first clicked tile
        add $a0, $t3, $zero 
        add $a1, $t2, $zero
        add $a2, $s5, $zero
        add $a3, $s4, $zero
        jal swapTiles
        la $t0, isSwap # isSwap = true
        addi $t1, $zero, 1
        sw $t1, 0($t0)
        sw $zero, 0($s0) # reset click count
        la $t2, step
        lw $t3, 0($t2)
        addi $t3, $t3, 1
        sw $t3, 0($t2) # step++
        j endHandleMouseClick

    revertClickCount:
        addi $t0, $zero, 1
        sw $t0, 0($s0) 


endHandleMouseClick:
    lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36
    jr $ra


#--------------------------------------------------------------------
# procedure: Check for matched patterns in horizontal direction
#     - If a tile is part of a matched pattern, then set its hscore 
#        attribute to the points it earned.
#--------------------------------------------------------------------
checkHorizontalMatch:
    addi $sp, $sp, -36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)

    li $s0, 0 # rowIndex

    rowLoopMatchHorizontal:
        li $t0, 8
        beq $s0, $t0, endCheckHorizontalMatch

        li $s1, 0 # colIndex

        colLoopMatchHorizontal:
            li $t0, 8
            beq $s1, $t0, endColLoopMatchHorizontal

            add $a0, $s0, $zero
            add $a1, $s1, $zero
            jal getCellAddress
            add $s2, $v0, $zero # address of current tile

            lw $t0, 24($s2) # grid[i][j].hscore
            bne $t0, $zero, colLoopMatchHorizontalContinue

            add $s3, $s1, $zero # leftborder of matched pattern
            add $s4, $s1, $zero # rightborder of matched pattern
            lw $s5, 16($s2) # grid[i][j].kind

            expandLeftBorder:
                bltz $s3, expandRightBorder
                add $a0, $s0, $zero
                add $a1, $s3, $zero	
                jal getCellAddress
                add $t0, $v0, $zero # address of left border tile
                lw $t1, 16($t0) # grid[i][leftborder].kind
                bne $t1, $s5, expandRightBorder

                addi $s3, $s3, -1
                j expandLeftBorder

            expandRightBorder:
                add $t0, $s4, $zero
                addi $t0, $t0, -8
                bgez $t0, endExpandRightBorder #>= 0 rightmost
                add $a0, $s0, $zero
                add $a1, $s4, $zero
                jal getCellAddress
                add $t0, $v0, $zero # address of right border tile
                lw $t1, 16($t0) # grid[i][rightborder].kind
                bne $t1, $s5, endExpandRightBorder

                addi $s4, $s4, 1
                j expandRightBorder

            endExpandRightBorder:
                sub $s6, $s4, $s3 # patternLength
                addi $s6, $s6, -1
                addi $t0, $s6, -3
                bltz $t0, colLoopMatchHorizontalContinue

            addi $s7, $s3, 1
            updateHScore:
                sub $t0, $s7, $s4
                bgez $t0, colLoopMatchHorizontalContinue

                add $a0, $s0, $zero
                add $a1, $s7, $zero
                jal getCellAddress
                add $t1, $v0, $zero # address of tile to be updated
                sw $s6, 24($t1)

                addi $s7, $s7, 1
                j updateHScore


        colLoopMatchHorizontalContinue:
            addi $s1, $s1, 1
            j colLoopMatchHorizontal

        endColLoopMatchHorizontal:
            addi $s0, $s0, 1
            j rowLoopMatchHorizontal


endCheckHorizontalMatch:
    lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36
    jr $ra


#--------------------------------------------------------------------
# procedure: Check for matched patterns in vertical direction
#    - If a tile is part of a matched pattern, then set its vscore
#        attribute to the points it earned.
#--------------------------------------------------------------------
checkVerticalMatch:

	#***** Task 2 *****
	# Check for matched tiles in vertical direction, if three or more tiles of the same kind are aligned sequentially
	# in the vertical direction, then all of these matched tiles have their vscore attribute set to the length of the
	# matched pattern that they belong to.
	#
	# hint: 
	# step 1: Read and understand the function "checkHorizontalMatch".
	# step 2: Iterate over each tile of the grid using a nested loop.
	# step 3: For each tile, find the upper bound of the sequence of tiles that have the same kind as it.
	# step 4: For each tile, find the lower bound of the sequence of tiles that have the same kind as it.
	# step 5: If the length of the matched pattern between the upper and lower bounds is greater than or equal to 3,
	#		 then set the vscore attribute of all tiles in this matched pattern to the length of the matched pattern.
	# step 6: If a tile has its vscore attribute already been set (not equal to 0), then skip updating it. 
	#------ Your code starts here ------
addi $sp, $sp, -36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)

    li $s0, 0 # colIndex
    
    colLoopMatchVertical:
    	li $t0, 8 # for comparison
    	beq $s0, $t0, endCheckVerticalMatch # if the col index = 8, finish checking
    	#else
    	li $s1, 0 # rowIndex
    	
    	rowLoopMatchVertical:
    		li $t0, 8 #for comparison
    		beq $s1, $t0, endRowLoopMatchVertical # if the row index = 8, go to next col
    		
    		add $a0, $s1, $zero
    		add $a1, $s0, $zero
    		jal getCellAddress
    		add $s2, $v0, $zero # address of current tile
    		
    		lw $t0, 24($s2) # grid[i][j].hscore
    		bne $t0, $zero, rowLoopMatchVerticalContinue # the score is alrd updated, we skip this and move to the next row 
    		#else we find the one might need to be updated
    		add $s3, $s1, $zero # the upperborder of matched pattern
    		add $s4, $s1, $zero # the lowerborder of matched pattern
    		lw $s5 16($s2) # get the kind of current cell for checking update
    		
    		expandUpperBorder:
    			bltz $s3, expandLowerBorder # if the row index < 0, we reach the limit of upperboarder.
    			#else
    			add $a0, $s3, $zero
			add $a1, $s0, $zero
			jal getCellAddress
			add $t0, $v0, $zero # address of upper border tile
			lw $t1, 16($t0) #kind of the upperboarder tile
			bne $t1, $s5, expandLowerBorder
			
			addi $s3, $s3, -1
			j expandUpperBorder
			
		expandLowerBorder:
			add $t0, $s4, $zero
			addi $t0, $t0, -8
			bgez $t0, endExpandLowerBorder # if the rowIndex - 8 >= 0 meaning that rowIndex >= 8 which is the limit
			#else
			add $a0, $s4, $zero
			add $a1, $s0, $zero
			jal getCellAddress
			add $t0, $v0, $zero # address of lowerborder tile
			lw $t1, 16($t0) # kind of lowerboarder tile
			bne $t1, $s5, endExpandLowerBorder

                		addi $s4, $s4, 1
               		j expandLowerBorder
		
		endExpandLowerBorder:
			sub $s6, $s4, $s3 # pattern length 
			addi $s6, $s6, -1 # get the real length because it points they are not pointing to the one with same kind
			# 1| 2 3 4 5| 6 -> 6-1-1 = 4 which is the pattern length
			addi $t0, $s6, -3 
			bltz $t0, rowLoopMatchVerticalContinue #if the pattern length - 3 < 0 meaning the length < 3
			#then we should start the row checking again with row index + 1
			#else 
			addi $s7, $s3, 1 # get the uppermost row index of the matched pattern
			
		updateVScore:
			sub $t0, $s7, $s4
			bgez $t0, rowLoopMatchVerticalContinue # leftmost index - (rightmost index + 1)
			# 2 - 6 = -4 so we will loop 4 times which is the loop count
			
			add $a0, $s7, $zero
			add $a1, $s0, $zero
			jal getCellAddress
			add $t1, $v0, $zero, # address of the tile
			sw $s6, 28($t1)
	#la $a0, grid
    	#li $a1, 7
    	#li $v0, 207
    	#syscall			
			addi $s7, $s7, 1
			j updateVScore
	rowLoopMatchVerticalContinue:
		addi $s1, $s1, 1 #rowINdex ++
		j rowLoopMatchVertical
	
	endRowLoopMatchVertical:
		addi $s0, $s0, 1 #colIndex ++
		j colLoopMatchVertical
			
		

endCheckVerticalMatch:
    lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36
   

	#------ Your code ends here ------
    jr $ra


#--------------------------------------------------------------------
# procedure: calculate the total points each tile earned
#   - The total points of a tile is the sum of its hscore and vscore attributes.
#--------------------------------------------------------------------
updateMatch:

	#***** Task 3 *****
	# Update the match attribute of each tile in the grid, and set the value of matchFound variable accordingly.
	# Note that "matchFound" is a global variable indicating whether at least one matched pattern exists in the 
    # current game loop. This variable is used in procedure "revertSwap".
	#
	# hint: 
	# step 1: Assign the value of matchFound variable to 0(false).
	# step 2: Iterate over each tile of the grid using a nested loop.
	# step 3: For each tile, set its match attribute to the sum of its hscore and vscore attributes.
	# step 4: If the match attribute of any tile is greater than 0, then set the value of matchFound variable to 1(true).
	#------ Your code starts here ------
	addi $sp, $sp, -4
	sw $ra, 0($sp) 
	
	addi $t0, $zero, 0
	la $t1, matchFound
	sw $t0, 0($t1) #assign the value of matchFound to 0
	
	addi $t2, $zero, 0 # rowIndex
	
	rowLoopUpdateMatch:
		addi $t0, $zero, 8
		beq $t2, $t0, endRowLoopUpdateMatch # if rowIndex == 8, finish
		#else
		addi $t3, $zero, 0 # colIndex
		
	colLoopUpdateMatch:
		addi $t0, $zero, 8
		beq $t3, $t0, endColLoopUpdateMatch # if colIndex == 8, go to next row
		#else set match attributes to the sum of its hscore and vsxore attributes
		add $a0, $t2, $zero
		add $a1, $t3, $zero
		addi $sp, $sp, -16
		sw $t0, 12($sp) #comparison
		sw $t1, 8($sp)	#matchFound
		sw $t2, 4($sp)	#rowIndex
		sw $t3, 0($sp)	#colIndex
		jal getCellAddress
		lw $t0, 12($sp)
		lw $t1, 8($sp)
		lw $t2, 4($sp)
		lw $t3, 0($sp)
		addi $sp, $sp, 16
		add $t4, $v0, $zero # address of gird[i][j]
		add $t8, $zero, $zero # intermediate sum
		
		lw $t5, 24($t4) # hsscore
		add $t8, $t5, $t8 # intermediate sum += hsscore
		
		lw $t5, 28($t4) #vscore
		add $t8, $t5, $t8 #intermediate sum += vscore
		
		bgtz $t8, UpdateMatchFound # if intermediate sum > 0, update matchFound to 1
		#else
	UpdateAfter:
		sw $t8, 20($t4)
		
		addi $t3, $t3, 1 # colIndex ++ 
		j colLoopUpdateMatch
		
	UpdateMatchFound:
		addi $t0, $zero, 1
		la $t1, matchFound
		sw $t0, 0($t1) #addign the value of matchFound to 1
		
		j UpdateAfter
		
	endColLoopUpdateMatch:
		addi $t2, $t2, 1 # rowIndex ++
		j rowLoopUpdateMatch
		
	endRowLoopUpdateMatch:
		lw $ra, 0($sp)
		addi $sp, $sp, 4	
	
	

	#------ Your code ends here ------
    jr $ra


#--------------------------------------------------------------------
# procedure: Update Tile coordinates to match their indices in the grid
#--------------------------------------------------------------------
updatePos:
    addi $sp, $sp, -32
    sw $ra, 28($sp)
    sw $s0, 24($sp)
    sw $s1, 20($sp)
    sw $s2, 16($sp)
    sw $s3, 12($sp)
    sw $s4, 8($sp)
    sw $s5, 4($sp)
    sw $s6, 0($sp)

    la $s2, isMoving # address of isMoving
    sw $zero, 0($s2)

    li $s0, 0 # rowIndex
    rowUpdatePos:
        li $t0, 8
        beq $s0, $t0, endUpdatePos

        li $s1, 0 # colIndex
        colUpdatePos:
            li $t0, 8
            beq $s1, $t0, endColUpdatePos

            add $a0, $s0, $zero
            add $a1, $s1, $zero
            jal getCellAddress
            add $s3, $v0, $zero # address of current tile

            li $s4, 0 # dx: offset of x coordinate and colIndex
            li $s5, 0 # dy: offset of y coordinate and rowIndex

            li $s6, 0 # animation loop index
            animation:
                li $t0, 4 # animation speed
                beq $s6, $t0, endAnimation

                la $t0, tileSize
                lw $t0, 0($t0) # tileSize

                lw $t1, 12($s3) # grid[i][j].col
                mult $t1, $t0
                mflo $t1
                lw $t2, 0($s3) # grid[i][j].x
                sub $s4, $t2, $t1

                lw $t1, 8($s3) # grid[i][j].row
                mult $t1, $t0
                mflo $t1
                lw $t2, 4($s3) # grid[i][j].y
                sub $s5, $t2, $t1

                bgtz $s4, decX
                bltz $s4, incX

                j endCheckX

                incX:
                    lw $t0, 0($s3)
                    addi $t0, $t0, 1
                    sw $t0, 0($s3)
                    j endCheckX

                decX:
                    lw $t0, 0($s3)
                    addi $t0, $t0, -1
                    sw $t0, 0($s3)

                endCheckX:	
                bgtz $s5, decY
                bltz $s5, incY
                j animationContinue

                incY:
                    lw $t0, 4($s3)
                    addi $t0, $t0, 1
                    sw $t0, 4($s3)
                    j animationContinue

                decY:
                    lw $t0, 4($s3)
                    addi $t0, $t0, -1
                    sw $t0, 4($s3)

            animationContinue:
                addi $s6, $s6, 1
                j animation

            endAnimation:

                # add $t0, $s4, $s5
                # beq $t0, $zero, colUpdatePosContinue

                bne $s4, $zero, updateIsMoving
                bne $s5, $zero, updateIsMoving
                j colUpdatePosContinue

            updateIsMoving:
                li $t0, 1
                sw $t0, 0($s2)

        colUpdatePosContinue:
            addi $s1, $s1, 1
            j colUpdatePos

        endColUpdatePos:
            addi $s0, $s0, 1
            j rowUpdatePos


endUpdatePos:
    lw $s6, 0($sp)
    lw $s5, 4($sp)
    lw $s4, 8($sp)
    lw $s3, 12($sp)
    lw $s2, 16($sp)
    lw $s1, 20($sp)
    lw $s0, 24($sp)
    lw $ra, 28($sp)
    addi $sp, $sp, 32
    jr $ra


#--------------------------------------------------------------------
# procedure: revert the swap action if no match is found
#--------------------------------------------------------------------
revertSwap:
    addi $sp, $sp, -8
    sw $ra, 4($sp)
    sw $s0, 0($sp)

    la $s0, isSwap # address of isSwap
    lw $t0, 0($s0)
    beq $t0, $zero, endRevertSwap

    la $t0, isMoving
    lw $t0, 0($t0)
    li $t1, 1
    beq $t0, $t1, endRevertSwap

    la $t0, matchFound
    lw $t0, 0($t0)
    li $t1, 1
    beq $t0, $t1, resetIsSwap

    la $t0, row0
    lw $t0, 0($t0)
    la $t1, col0
    lw $t1, 0($t1)
    la $t2, row1
    lw $t2, 0($t2)
    la $t3, col1
    lw $t3, 0($t3)
    add $a0, $t0, $zero
    add $a1, $t1, $zero
    add $a2, $t2, $zero
    add $a3, $t3, $zero
    jal swapTiles

    la $t0, step
    lw $t1, 0($t0)
    addi $t1, $t1, -1
    sw $t1, 0($t0)

    resetIsSwap:

    sw $zero, 0($s0)	

endRevertSwap:
    lw $s0, 0($sp)
    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra


#--------------------------------------------------------------------
# procedure: move matched tiles to the top of the grid
#--------------------------------------------------------------------
moveMatch:

	#***** Task 4 *****
	# Push the registers that need to be preserved onto the stack here.
	addi $sp, $sp, -32
    	sw $ra, 28($sp)
    	sw $s0, 24($sp)
    	sw $s1, 20($sp)
    	sw $s2, 16($sp)
    	sw $s3, 12($sp)
    	sw $s4, 8($sp)
    	sw $s5, 4($sp)
    	sw $s6, 0($sp)


    #******************

	# The following 4 lines of code are for animations, and they are not part of the Task 4 logic.
    # You can ignore the following piece of code, but remember DO NOT modify it.
    # DO NOT modify the "endMoveMatch" label at the end of this procedure.
	la $t0, isMoving
    lw $t0, 0($t0)
    li $t1, 1
    beq $t0, $t1, endMoveMatch


	#***** Task 4 *****
	# "Push" the matched tiles (tiles with attribute match not equal to 0) upwards to the upper boundary of the grid,   
	# meanwhile the unmatched tiles above them will fall down to fill the empty cells. After this procedure, the matched 
	# tiles should only occupy the topmost cells of the grid.
	#
	# hint: 
	# step 1: Iterate over each tile of the grid using a nested loop. NOTE that for row iterations, you need to 
	# iterate from the BOTTOM row to the TOP row.
	# step 2: For each tile, if the "match" attribute is 0, then skip to the next tile.
	# step 3: For each tile with non-0 match attribute, find the bottom-most unmatched tile above it (in the same column).
    #   - For example, if the current tile is at (3, 3), and it its match attribute is not 0, suppose tile (2, 3) also 
    #     has a non-0 match attribute, tile (1, 3), (0, 3) have match attributes equal to 0, then swap (3, 3) with (1, 3).
    #   - If there is no unmatched tile above the current tile, then skip the current tile.      
	# step 4: For each tile with non-0 match attribute, call the procedure "swapTiles" to swap it with the bottom-most
    # unmatched tile above it identified in step 3.
    #   - Read the source codes of "swapTiles" to understand how to use it.
	#------ Your code starts here ------
	addi $s0, $zero, 7 #rowIndex
	rowLoopMoveMatch:
		addi $t2, $zero, -1
		beq $s0, $t2, endMoveMatch #if rowIndex == 8, end the loop
		#else
		add $s1, $zero, $zero #colIndex
	colLoopMoveMatch:
		addi $t2, $zero, 8
		beq $s1, $t2, endColLoopMoveMatch #if colIndex == 8, end the loop
		#else
		add $a0, $s0, $zero
		add $a1, $s1, $zero
		jal getCellAddress
		add $s2, $v0, $zero # cell address
		
		lw $s3, 20($s2) # cell.match
		beqz $s3, skipMoveMatch #if match = 0, skip it
		#else check if there is any unmatched tile above it
		addi $s4, $s0, -1 # rowIndex - 1
		
	checkUnmatchedtile:
		bltz $s4, skipMoveMatch # if the matched tile is at row 0
		#else check its match
		add $a0, $s4, $zero
		add $a1, $s1, $zero
		jal getCellAddress
		add $s5, $v0, $zero # cell address of tile above
		
		lw $s6, 20($s5)
		beqz $s6, swapMoveMatch #if we find the zero, swap it
		#else we move up
		addi $s4, $s4, -1
		j checkUnmatchedtile
	
	swapMoveMatch:
		add $a0, $s0, $zero
		add $a1, $s1, $zero
		add $a2, $s4, $zero
		add $a3, $s1, $zero
		jal swapTiles
		
	skipMoveMatch:
		addi $s1, $s1, 1 #colIndex++
		j colLoopMoveMatch
	endColLoopMoveMatch:
		addi $s0, $s0, -1 #rowIndex++
		j rowLoopMoveMatch
		
	

	#------ Your code ends here ------

endMoveMatch:

	#***** Task 4 *****
	# Pop the registers that were preserved onto the stack.
    lw $s6, 0($sp)
    lw $s5, 4($sp)
    lw $s4, 8($sp)
    lw $s3, 12($sp)
    lw $s2, 16($sp)
    lw $s1, 20($sp)
    lw $s0, 24($sp)
    lw $ra, 28($sp)
    addi $sp, $sp, 32

    #******************
    jr $ra


#--------------------------------------------------------------------
# procedure: replace matched tiles with new tiles
#--------------------------------------------------------------------
replaceMatch:

	#***** Task 5 *****
	# Push the registers that need to be preserved onto the stack here.
	addi $sp, $sp, -36
    sw $ra, 32($sp)
    sw $s0, 28($sp)
    sw $s1, 24($sp)
    sw $s2, 20($sp)
    sw $s3, 16($sp)
    sw $s4, 12($sp)
    sw $s5, 8($sp)
    sw $s6, 4($sp)
    sw $s7, 0($sp)
    #******************

	# The following 4 lines of code are for animations, and they are not part of the Task 5 logic.
    # You can ignore the following piece of code, but remember DO NOT modify it.
    # DO NOT modify the "endReplaceMatch" label at the end of this procedure.
    la $t0, isMoving
    lw $t0, 0($t0)
    li $t1, 1
    beq $t0, $t1, endReplaceMatch

	#***** Task 5 *****
	# Replace the matched tiles with new tiles, set the y-attribute of the new tiles above the upper boundary of the grid,
	# so that they will fall down to the grid in the proceeding game loops. 
	#
	# hint: 
	# step 1: Iterate over each tile of the grid using a nested loop. The outer loop should iterate over the columns, and the 
	# inner loop should iterate over the rows from the bottom to the top.
	# step 2: For each matched tile, assign the y-attribute a negative multiple of the value stored in the "tileSize" variable.
	# Make sure, that the newly generated tiles are spaced out by the value stored in the "tileSize" variable. 
	# For example, if a column has 3 matched tiles, then set the bottom-most matched tile's y-attribute to -1*tileSize, 
	# the middle matched tile's y-attribute to -2*tileSize, and the top-most matched tile's y-attribute to -3*tileSize.
	# step 3: For each matched tile, increment the global variable "score" by the value stored in attribute "match".
	# step 4: For each macthed tile, set the value of attributes "match", "hscore" and "vscore" to 0.
	# step 5: For each macthed tile, use syscall 42 to generate a random number between 0 and 5 (both inclusive), 
	# assign the random value to the "kind" attribute of the tile.
	#
	#------ Your code starts here ------

    li $s0, 0 # colIndex
    
    colLoopReplaceMatch:
    	li $s7, 8 # for comparison
    	beq $s0, $s7, endColLoopReplaceMatch # if the col index = 8, finish checking
    	#else
    	li $s1, 7 # rowIndex bottom to the top
    	
    	rowLoopReplaceMatch:
    		li $s7, -1 #for comparison
    		beq $s1, $s7, endRowLoopReplaceMatch # if the row index = -1, go to next col
    		
    		add $a0, $s1, $zero
    		add $a1, $s0, $zero
    		jal getCellAddress
    		add $s2, $v0, $zero # address of current tile
    		
    		lw $s3, 20($s2) # match
    		bnez $s3, assignYAttribute
    		j rowLoopReplaceMatchContinue
    	assignYAttribute: 
    		#rowidx = 3 -> row 4 but we need -1
    		#match = 4 -> because length is 4.
    		#-1 = rowidx - match = $s1 - $s3
    		sub $s4, $s1, $s3
    		la $s5, tileSize
		lw $s5, 0($s5) #$s5 = tileSize
    		mult $s4, $s5
    		mflo $s6
    		sw $s6, 4($s2) # y = $s6
    		
    	incrementScore:
    		lw $s6, 20($s2) #match
    		la $s7, score
    		lw $s3, 0($s7)
    		add $s6, $s6, $s3
    		sw $s6, 0($s7)
    		
    	resetAttributes:
    	# step 4: For each macthed tile, set the value of attributes "match", "hscore" and "vscore" to 0.
    		add $s6, $zero, $zero # 0
    		sw $s6, 20($s2)
    		sw $s6, 24($s2)
    		sw $s6, 28($s2)
    	assignRandomTiles:
    	# step 5: For each macthed tile, use syscall 42 to generate a random number between 0 and 5 (both inclusive), 
	# assign the random value to the "kind" attribute of the tile.
		addi $a1,$zero, 6 #upperbound = 6
		li $v0, 42
		syscall #rand number is in $a0
		sw $a0, 16($s2)
    		
    	rowLoopReplaceMatchContinue:
    	#next row
    		addi $s1, $s1, -1 #move up by 1
    		j rowLoopReplaceMatch
	
	endRowLoopReplaceMatch:
		addi $s0, $s0, 1
		j colLoopReplaceMatch
		
	endColLoopReplaceMatch:
	
	#------ Your code ends here ------

endReplaceMatch:

	#***** Task 5 *****
	# Pop the registers that were preserved onto the stack.

lw $s7, 0($sp)
    lw $s6, 4($sp)
    lw $s5, 8($sp)
    lw $s4, 12($sp)
    lw $s3, 16($sp)
    lw $s2, 20($sp)
    lw $s1, 24($sp)
    lw $s0, 28($sp)
    lw $ra, 32($sp)
    addi $sp, $sp, 36
   


    #******************
    jr $ra


#--------------------------------------------------------------------
# procedure: calculate the absoluteValue of a number
#--------------------------------------------------------------------
absoluteValue:
    add $t0, $a0, $zero
    bgez $t0, endAbsoluteValue
    subu $t0, $zero, $t0

endAbsoluteValue:
    add $v0, $t0, $zero
    jr $ra


#--------------------------------------------------------------------
# procedure: swap two tiles in the grid
#--------------------------------------------------------------------
swapTiles:
    addi $sp, $sp, -20
    sw $ra, 16($sp)
    sw $s0, 12($sp)
    sw $s1, 8($sp)
    sw $s2, 4($sp)
    sw $s3, 0($sp)

    add $t0, $a0, $zero #rowIndex0
    add $t1, $a1, $zero #colIndex0
    add $s2, $a2, $zero #rowIndex1
    add $s3, $a3, $zero #colIndex1
    jal getCellAddress
    add $s0, $v0, $zero #address of the first tile
    add $a0, $s2, $zero
    add $a1, $s3, $zero
    jal getCellAddress
    add $s1, $v0, $zero #address of the second tile

	li $t0, 0 #iterator
	swapFields:
		li $t1, 32
		beq $t0, $t1, endSwapTiles
		li $t1, 8
		beq $t0, $t1, swapFieldsContinue
		li $t1, 12
		beq $t0, $t1, swapFieldsContinue

		add $t1, $s0, $t0
		add $t2, $s1, $t0
		lw $t3, 0($t1)
		lw $t4, 0($t2)
		sw $t4, 0($t1)
		sw $t3, 0($t2)

	swapFieldsContinue:
		addi $t0, $t0, 4
		j swapFields

endSwapTiles:
    lw $s3, 0($sp)
    lw $s2, 4($sp)
    lw $s1, 8($sp)
    lw $s0, 12($sp)
    lw $ra, 16($sp)
    addi $sp, $sp, 20
    jr $ra


#--------------------------------------------------------------------
# procedure: get the base address of a tile
#--------------------------------------------------------------------
getCellAddress:
    add $t0, $a0, $zero #rowIndex
    add $t1, $a1, $zero #colIndex
    la $t2, grid
    sll $t3, $t0, 3
    add $t3, $t3, $t1
    sll $t3, $t3, 5
    add $t4, $t3, $t2
    add $v0, $t4, $zero
    jr $ra


#--------------------------------------------------------------------
# procedure: end game
#--------------------------------------------------------------------
endGame:
    la $t0, score
    lw $t0, 0($t0)
    la $t1, winScore
    lw $t1, 0($t1)
    sub $t2, $t0, $t1
    bgez $t2, win
    j lose

    win:
        la $a0, winText
        li $v0, 205
        syscall

        j endEndGame
    lose:
        la $a0, loseText
        li $v0, 205
        syscall

endEndGame:
