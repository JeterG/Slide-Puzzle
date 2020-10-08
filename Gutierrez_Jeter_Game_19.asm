;Game of 19s in TASM 8086 Assembly
;by Jeter Gutierrez
.model tiny
.code
org 100h
.386

Start:
    push 0B800h
    pop es
    call Instructions
    call Begin
Play:
    call Seed
    call Random
    call Clear_Grid
    call Populate_Grid
Mid:
    call Generate_Grid
    call Place_Cursor

Process_Move: ;MANAGE KEYBOARD INPUTS 
    call Check_Solution
    call Generate_Moves
    call Input        
    cmp ah,01ch;ENTER KEY
    jz Play
	cmp ah,4bh ;LEFT ARROW KEY
	jz Left
	cmp ah,4dh ;RIGHT ARROW KEY
	jz Right
	cmp ah,48h ;UP ARROW KEY
	jz Up
	cmp ah,50h ;DOWN ARROW KEY
	jz Down    
    cmp ah,10h; Q KEY
    jz Quit
	jmp Process_Move	
	
Quit:
    mov ax, 0003h
    int 10h
    mov ah,4Ch
    int 21h
    ret

Left:
	cmp di,0
	jz Process_Move
    sub di,1    
    push ax
    push bx
    push cx
    push dx
    mov ch,dh
    mov cl,dl
    mov ax,160
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,Next_Move[2]
    mov es:[bx-2],al
    mov al,Next_Move[3]
    mov es:[bx],al     
    mov ch,dh
    mov cl,dl
    mov ax,160
    sub cl,3
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,32
    mov es:[bx-2],al
    mov al,32
    mov es:[bx],al
    pop dx 
    pop cx
    pop bx
    pop ax
    call Set_Position
    jmp Process_Move
	
Right:
	cmp di,3
	jz Process_Move
	add di,1  
    push ax
    push bx
    push cx
    push dx
    mov ch,dh
    mov cl,dl
    mov ax,160
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,Next_Move[4]
    mov es:[bx-2],al
    mov al,Next_Move[5]
    mov es:[bx],al     
    mov ch,dh
    mov cl,dl
    mov ax,160
    add cl,3
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,32
    mov es:[bx-2],al
    mov al,32
    mov es:[bx],al
    pop dx 
    pop cx
    pop bx
    pop ax
	call Set_Position
	jmp Process_Move
	
Up:
	cmp si,0
	jz Process_Move
	sub si,1
	push ax
    push bx
    push cx
    push dx
    mov ch,dh
    mov cl,dl
    mov ax,160
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,Next_Move[0]
    mov es:[bx-2],al
    mov al,Next_Move[1]
    mov es:[bx],al     
    mov ch,dh
    mov cl,dl
    mov ax,160
    sub ch,2
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,32
    mov es:[bx-2],al
    mov al,32
    mov es:[bx],al
    pop dx
    pop cx
    pop bx
    pop ax
	call Set_Position
	jmp Process_Move
	
Down:
	cmp si,4
	jz Process_Move
	add si,1
	push ax
    push bx
    push cx
    push dx
    mov ch,dh
    mov cl,dl
    mov ax,160
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,Next_Move[6]
    mov es:[bx-2],al
    mov al,Next_Move[7]
    mov es:[bx],al     
    mov ch,dh
    mov cl,dl
    mov ax,160
    add ch,2
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,32
    mov es:[bx-2],al
    mov al,32
    mov es:[bx],al
    pop dx 
    pop cx
    pop bx
    pop ax
	call Set_Position
	jmp Process_Move
	
Set_Position:
    xor ax,ax
    xor bx,bx
    xor cx,cx
    xor dx,dx
	mov ah,02h
	mov dh,Rows[si]
	mov dl,Columns[di]
	int 10h	
	ret       

Clear_Grid:
    mov cx,2000
    mov di,0
    mov al,' ';Empty Space
    mov ah,70h
Erase:    ; Fills entire screen with the text specified in al and color specified in ah
    mov es:[di], al; Text to place, Empty Space
    inc di
    mov es:[di],ah;Color For background
    inc di
    loop Erase
    ret

Write_Char:
    mov es:[di],al
    inc di
    mov al, 21h 
    mov es:[di], al
    inc di
    ret

Write_Num:
    mov es:[di],al
    inc di
    mov al, 20h
    mov es:[di], al
    inc di
    inc si
    ret

Create_Middle_Row:
    mov al,204
    call Write_Char
    mov al,205
    call Write_Char
    mov al,205
    call Write_Char
    mov al,206 
    call Write_Char
    mov al,205
    call Write_Char
    mov al,205
    call Write_Char
    mov al,206
    call Write_Char
    mov al,205 
    call Write_Char
    mov al,205
    call Write_Char
    mov al,206
    call Write_Char
    mov al,205
    call Write_Char
    mov al,205
    call Write_Char
    mov al,185
    call Write_Char   
    ret

Create_Num_Row:
    mov al,186
    call Write_Char
    mov al,Grid[si]
    call Write_Num
    mov al,Grid[si]
    call Write_Num
    mov al,186 
    call Write_Char
    mov al,Grid[si]
    call Write_Num
    mov al,Grid[si]
    call Write_Num
    mov al,186
    call Write_Char
    mov al,Grid[si]
    call Write_Num
    mov al,Grid[si] 
    call Write_Num
    mov al,186
    call Write_Char
    mov al,Grid[si]
    call Write_Num
    mov al,Grid[si]
    call Write_Num
    mov al,186
    call Write_Char
    ret 

Generate_Grid:
    mov si,0;BEGINNING OF ROW 1
    mov di,0
    mov al,201
    call Write_Char
    mov al,205
    call Write_Char
    mov al,205
    call Write_Char
    mov al,203 
    call Write_Char
    mov al,205
    call Write_Char
    mov al,205
    call Write_Char
    mov al,203 
    call Write_Char
    mov al,205
    call Write_Char
    mov al,205
    call Write_Char
    mov al,203 
    call Write_Char
    mov al,205
    call Write_Char
    mov al,205
    call Write_Char
    mov al,187
    call Write_Char; END OF ROW 1
    mov di,160; BEGINNING OF ROW 2
    call Create_Num_Row; END OF ROW 2
    mov di,320; BEGINNING OF ROW 3
    call Create_Middle_Row; END OF ROW 3
    mov di,480; BEGINNING OF ROW 4
    call Create_Num_Row; END OF ROW 4
    mov di,640; BEGINNING OF ROW 5
    call Create_Middle_Row ;END OF ROW 5
    mov di,800; BEGINNING OF ROW 6
    call Create_Num_Row;END OF ROW 6
    mov di,960; BEGINNING OF ROW 7
    call Create_Middle_Row; END OF ROW 7    
    mov di,1120;BEGINNING OF ROW 8
    call Create_Num_Row;END OF ROW 8
    mov di,1280;BEGINNING OF ROW 9
    call Create_Middle_Row;END OF ROW 9
    mov di,1440;BEGINING OF ROW 10
    call Create_Num_Row; END OF ROW 10
    mov di,1600;BEGINNING OF ROW 11
    mov al,200
    call Write_Char    
    mov al,205
    call Write_Char
    mov al,205
    call Write_Char
    mov al,202 
    call Write_Char
    mov al,205
    call Write_Char
    mov al,205
    call Write_Char
    mov al,202
    call Write_Char
    mov al,205 
    call Write_Char
    mov al,205
    call Write_Char
    mov al,202
    call Write_Char
    mov al,205
    call Write_Char
    mov al,205
    call Write_Char
    mov al,188
    call Write_Char;END OF ROW 11
    ret                     
    jmp Continue

Seed: ; SET THE SEED VALUE
    mov ah,2ch
    int 21h
    mov Randomization_Seed,dx
    xor dx,dx
    ret

Message:
    mov al,Introduction[si]
    call Write_Num
    loop Message
    ret

Instructions:
    mov cx,2000
    mov di,0
    mov al,' ';Empty Space
    mov ah,20h;COLOR OF INITIAL BACKGROUND OF SCREEN WHEN INSTRUCTIONS ARE DISPLAYED.
    call Erase
    mov cx,42
    mov si,0
    mov di,162
    call Message
    mov cx,15
    mov di,322
    call Message
    mov cx,10
    mov di,642
    call Message
    mov cx,41
    mov di,482
    call Message
    mov cx,41
    mov di,802
    call Message
    call Out_of_Screen
    ret
Out_Of_Screen:
    mov ah,2
    mov bh,0
    mov dh,1ah;ROW NOT IN ACTIVE PAGE
    mov dl,51h;COLUMN NOT IN ACTIVE PAGE
    int 10h
    ret
    
Begin:
	call Input
    cmp ah,01ch;ENTER KEY
    jz Play    
    cmp ah,10h; Q KEY
    jz Quit
    call Begin

Random: ;GENERATE RANDOM NUMBER LESS THAN NUMBER OF POSSIBLE GAMES (31)     
    mov  ax, Randomization_Seed
    mov cx,Randomizer 
    imul cx
    mov Randomization_Seed,ax
    xor dx,dx
    mov  cx, 31 ;NUMBER OF PROBLEMS   
    div  cx
	mov Random_Value,dx
    ret 
    
Place_Cursor:;PLACE CURSOR ON BOTTOM LEFT CELL
	mov ah,02h
    mov bh,0
    mov di,3
    mov si,4
    mov dh,9;ROW INDEX
    mov dl,11;COLUMN INDEX
    int 10h
    ret

Input: ;READ KEY PRESSED
	xor ax,ax
	mov ah,0h
	int 16h
    ret   

Populate_Grid:    
    mov cx,40;NUMBER OF CHARACTERS IN ANY GIVEN PROBLEM
    mov ax,Random_Value
    mul cx
    mov si,ax;POINTS TO THE "PROBLEM"
    mov cx,20; NUMBER OF VALUES IN ANY GIVEN PROBLEM
    mov di,0 
    call Generate_Problem
    ret

Generate_Problem:      
    mov dh,Values[si]
    mov Grid[di],dh
    inc si
    inc di
    mov dh,Values[si]
    mov Grid[di],dh
    inc si
    inc di
    loop Generate_Problem
    jmp Mid

 Generate_Moves:
    push ax;BEGINNING OF VALUE ABOVE
    push bx
    push cx
    push dx
    mov ch,dh
    mov cl,dl
    mov ax,160
    sub ch,2
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,es:[bx-2]
    mov Next_Move[0],al
    mov al,es:[bx]     
    mov Next_Move[1],al;END OF VALUE ABOVE
    mov ch,dh;BEGINNING OF VALUE TO THE LEFT 
    mov cl,dl
    mov ax,160
    sub cl,3
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,es:[bx-2]   
    mov Next_Move[2],al
    inc bp
    mov al,es:[bx]     
    mov Next_Move[3],al ;END OF VALUE TO THE LEFT
    mov ch,dh;BEGINNING OF VALUE TO THE RIGHT
    mov cl,dl
    mov ax,160
    add cl,3
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,es:[bx-2]   
    mov Next_Move[4],al
    mov al,es:[bx]     
    mov Next_Move[5],al;END OF VALUE TO THE RIGHT
    mov ch,dh;BEGINNING OF VALUE BELOW
    mov cl,dl
    mov ax,160
    add ch,2
    mul ch
    mov bx,ax
    mov ax,2
    mul cl
    add ax,bx
    mov bx,ax
    mov al,es:[bx-2]   
    mov Next_Move[6],al
    mov al,es:[bx]     
    mov Next_Move[7],al ;END OF VALUE BELOW   
    pop dx
    pop cx
    pop bx
    pop ax
    ret    
     
Check_Solution:
    push ax
    mov al,es:[162];BEGIN READING CURRENT VALUES ON GRID
    mov Current_Grid[0],al
    mov al,es:[164]
    mov Current_Grid[1],al
    mov al,es:[168]
    mov Current_Grid[2],al
    mov al,es:[170]
    mov Current_Grid[3],al
    mov al,es:[174]
    mov Current_Grid[4],al
    mov al,es:[176]
    mov Current_Grid[5],al
    mov al,es:[180]
    mov Current_Grid[6],al
    mov al,es:[182]
    mov Current_Grid[7],al
    mov al,es:[482]
    mov Current_Grid[8],al
    mov al,es:[484]
    mov Current_Grid[9],al
    mov al,es:[488]
    mov Current_Grid[10],al
    mov al,es:[490]
    mov Current_Grid[11],al
    mov al,es:[494]
    mov Current_Grid[12],al
    mov al,es:[496]
    mov Current_Grid[13],al
    mov al,es:[500]
    mov Current_Grid[14],al
    mov al,es:[502]
    mov Current_Grid[15],al
    mov al,es:[802]
    mov Current_Grid[16],al
    mov al,es:[804]
    mov Current_Grid[17],al
    mov al,es:[808]
    mov Current_Grid[18],al
    mov al,es:[810]
    mov Current_Grid[19],al
    mov al,es:[814]
    mov Current_Grid[20],al
    mov al,es:[816]
    mov Current_Grid[21],al
    mov al,es:[820]
    mov Current_Grid[22],al
    mov al,es:[822]
    mov Current_Grid[23],al
    mov al,es:[1122]
    mov Current_Grid[24],al
    mov al,es:[1124]
    mov Current_Grid[25],al
    mov al,es:[1128]
    mov Current_Grid[26],al
    mov al,es:[1130]
    mov Current_Grid[27],al
    mov al,es:[1134]
    mov Current_Grid[28],al
    mov al,es:[1136]
    mov Current_Grid[29],al
    mov al,es:[1140]
    mov Current_Grid[30],al
    mov al,es:[1142]
    mov Current_Grid[31],al
    mov al,es:[1442]
    mov Current_Grid[32],al
    mov al,es:[1444]
    mov Current_Grid[33],al
    mov al,es:[1448]
    mov Current_Grid[34],al
    mov al,es:[1450]
    mov Current_Grid[35],al
    mov al,es:[1454]
    mov Current_Grid[36],al
    mov al,es:[1456]
    mov Current_Grid[37],al
    mov al,es:[1460]
    mov Current_Grid[38],al
    mov al,es:[1462]
    mov Current_Grid[39],al;END READING CURRENT VALUES ON GRID
    pop ax
    push ax
    push cx
    push dx
    push di
    push bx
    mov cx,38
    mov di,0
    
Check:;CHECK IF GAME IS COMPLETE
    mov bl,Current_Grid[di]
    mov bh,Solution[di]
    inc di
    cmp bl,bh
    jnz Wrong
    loop Check
    jmp Correct

Wrong:; WHAT TO DO IF GAMEN NOT YET COMPLETE
    pop bx
    pop di 
    pop dx
    pop cx
    pop ax
    ret

Correct:; WHAT TO DO IF GAME IS COMPLETE
    pop bx
    pop di 
    pop dx
    pop cx
    pop ax
    push ax
    push bx
    push cx
    push dx 
    push si
    push di    
    mov cx,2000
    mov di,0
    mov al,' '
    mov ah,20h
    call Erase
    mov di,962
    mov si,0
    mov cx,78

Final_Message:
    mov al,Congratulations[si]
    call Write_Num
    loop Final_Message
    call Out_of_Screen
    call Process_Move
    pop si
    pop di
    pop dx
    pop bx
    pop ax
    ret 

Values  db ' 6','11',' 1','14',' 2','13',' 8','16','18','19','17','10',' 3','15',' 9','12',' 5',' 7',' 4','  ' ;0
        db ' 4',' 5','10','12','15',' 9',' 6','13','17','18',' 3','11','16',' 7',' 8',' 1','19',' 2','14','  ' ;1
        db '12',' 9',' 7',' 6','18',' 3',' 5',' 8','17','16',' 4','19','13',' 1','10','15','11','14',' 2','  ' ;2
        db '14',' 3',' 5',' 7',' 8','15','19',' 9',' 6','11','10','17',' 1','16','12',' 2','18',' 4','13','  ' ;3
        db '10','17','14','19','15',' 9',' 6',' 1',' 2',' 8',' 3','12','13',' 4',' 7','16',' 5','18','11','  ' ;4
        db ' 8','17',' 5','11','13','12','19',' 6',' 7',' 2','14','10','16',' 3','15',' 4',' 1',' 9','18','  ' ;5
        db ' 6','14',' 7',' 1','13',' 8','10',' 4','15',' 2','11','17',' 3',' 9','16','19','12','18',' 5','  ' ;6
        db ' 2','15',' 3',' 5','19','10','18',' 8','17',' 1','12',' 4','16','11','13',' 6',' 7',' 9','14','  ' ;7
        db '15',' 3','10','11','18','16',' 8',' 5',' 1','13',' 6',' 2',' 9','14','12',' 4',' 7','17','19','  ' ;8
        db ' 5',' 1',' 6',' 9',' 3',' 4',' 8','15',' 7',' 2','17','11','13','18','12','10','14','19','16','  ' ;9
        db '12',' 1','19','16','17',' 9',' 8',' 7','14','13',' 6',' 3','11',' 5',' 2','15',' 4','18','10','  ' ;10
        db '19',' 9',' 7','17',' 4','14',' 2','12','10',' 8','18','13',' 1',' 3','15','11',' 5',' 6','16','  ' ;11
        db '11','12','14','13',' 3',' 5',' 7','10',' 9',' 8','19','17','15','16',' 4',' 2',' 6','18',' 1','  ' ;12
        db ' 4',' 8',' 2',' 7','17','19','11',' 6','18','12','16','13',' 9','14',' 1',' 3','10','15',' 5','  ' ;13
        db ' 2','15',' 8',' 5',' 6',' 1','14','18',' 4','16','17',' 7','19',' 9','12','11','10','13',' 3','  ' ;14
        db '18','17',' 2','15','13',' 1',' 9',' 3',' 5','14','16',' 6',' 8','12',' 4','11','10','19',' 7','  ' ;15
        db ' 2',' 9',' 3','19','17','15','16','11','12','18',' 8',' 1',' 6',' 5','14','13','10',' 4',' 7','  ' ;16
        db '15',' 6','11','19','17','14',' 2','13','12',' 5',' 8',' 1','10',' 4','16',' 9',' 7','18',' 3','  ' ;17
        db '15',' 8',' 7','13','19','17',' 2',' 3','12','11','18','10','14',' 4',' 1',' 5',' 9','16',' 6','  ' ;18
        db '10',' 7','11','19','12','17',' 1','14','13',' 6','15',' 4',' 8',' 5',' 9','16','18',' 3',' 2','  ' ;19
        db '12','10',' 1',' 4','19','15','14',' 8','17','11',' 3',' 9',' 6',' 2',' 5','16','13',' 7','18','  ' ;20
        db '14',' 9',' 2',' 6',' 1','16',' 8','11','10','15','17','18','12',' 3',' 4',' 5',' 7','13','19','  ' ;21
        db ' 6','15',' 9','13',' 5','12','14',' 7','19',' 8',' 1',' 4','17',' 2','11','10',' 3','16','18','  ' ;22
        db '18',' 5','14',' 9',' 8',' 4','13',' 2','16','10',' 3','17','19','15','11',' 6',' 7',' 1','12','  ' ;23
        db '17','11','13',' 3',' 8',' 9',' 1',' 7','10',' 5',' 4','16','14',' 6','15','18',' 2','19','12','  ' ;24
        db '15',' 9',' 6','13',' 8','14','12','10',' 3',' 4',' 2','19',' 7',' 1','17','16',' 5','18','11','  ' ;25
        db ' 7','10',' 1','15','18','12',' 2','19',' 5','17','11',' 8',' 4','14','16',' 9',' 6','13',' 3','  ' ;26
        db '14',' 4',' 5','13',' 1','17',' 7',' 8',' 3','19','11','18',' 6','12',' 2','10','15',' 9','16','  ' ;27
        db '17','10','12',' 2','18','19','13','11','14',' 5',' 1',' 6',' 3','16',' 9',' 7',' 8',' 4','15','  ' ;28
        db '14','10',' 8',' 4',' 3','13','16',' 5','12','19',' 2','17',' 6',' 1',' 7',' 9','18','15','11','  ' ;29
        db ' 6','16',' 3','10','17',' 8',' 2','11','19','13','12','15',' 1',' 4',' 7',' 9',' 5','18','14','  ' ;30
Solution db ' 1',' 2',' 3',' 4',' 5',' 6',' 7',' 8',' 9','10','11','12','13','14','15','16','17','18','19'     ; VALUE TO COMPARE TO TO CHECK IF GAME IS COMPLETE
Columns db 2,5,8,11; COLUMNS WHERE NUMBERS EXIST ON GRID
Rows db 1,3,5,7,9	;ROWS WHERE NUMBERS EXIST ON GRID
Grid db 40 dup('0');VALUES THAT ARE DRAWN TO THE BOARD AFTER GENERATED
Next_Move db 8 dup('0'); ARRAY OF VALUES ABOVE, LEFT, RIGHT AND BELOW OF CURSOR POSITION
Current_Grid db 40 dup('0')
Randomizer dw 5765
Randomization_Seed dw 1765
Random_Value dw 0  
Congratulations db "You Won Game of 19 By Jeter Gutierrez Press Enter For a New Game or Q to Quit:"    
Introduction db "Welcome to Game of 19's by Jeter GutierrezInstructions:--Q: To QuitUp, Down, Left, Right: Arrow Keys to MoveEnter:To play, or to Generate a New Grid:"
Continue:    
    end Start