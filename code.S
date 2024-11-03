.intel_syntax noprefix
.global _start

.section .data
sockaddr_in:  
    .word 2                # AF_INET (IPv4)
    .word 0x5000           # Port 80 in network byte order (0x5000)
    .long 0                # INADDR_ANY (bind to any address)

response_header:
    .ascii "HTTP/1.0 200 OK\r\n\r\n"  # HTTP header

buffer:                     
    .space 1024             # Buffer to store the incoming request

file_buffer:                
    .space 1024             # Buffer to store the file contents

file_path:
    .ascii "./flag"  # Path to the file

sockaddr_in_client: # for logging purposes
    .word 2                # sin_family: AF_INET (2 for IPv4)
    .word 0x0000           # sin_port: (0 initially, will be filled after accept)
    .long 0x00000000       # sin_addr: (0.0.0.0 initially, will be filled after accept)
    .space 8               # sin_zero: padding (8 bytes)
int_accept:
	.int 32  
Socket_FD:
    .space 8
Page_Space:
	.string "./"
ip_string:	
	.space 32	
	
.section .text
_start:
    # Create a socket
    mov rdi, 2              # AF_INET (IPv4)
    mov rsi, 1              # SOCK_STREAM (TCP)
    mov rdx, 0              # Protocol
    mov rax, 41             # socket()
    syscall
    mov rdi, rax            # Save socket file descriptor
    mov [rip+Socket_FD],rdi
    # Bind the socket
    lea rsi, [rip + sockaddr_in] 
    mov rdx, 16             # sockaddr_in size
    mov rax, 49             # bind()
    syscall

    # Listen for connections
    listen:
    mov rsi, 0              # Backlog of 0
    mov rax, 50             # listen()
    mov rdi,[rip+Socket_FD]
    syscall

    # Accept a connection
    connection:
    			#lea rsi, [rip + sockaddr_in_client]			#xor rsi, rsi            # NULL for client address
    xor rsi, rsi 
    			#lea rdx,[rip+int_accept]						#xor rdx, rdx            # NULL for addrlen
    xor rdx, rdx  
    mov rax, 43             # accept()
    syscall
    #mov rdi,0x1
    #mov rax,0x1
    #mov rdx,13 #13 noramly
    #mov rsi,0x0		#lea rsi,[sockaddr_in_client + 4] 
    #syscall
    #jmp exit
  
    fork_sys:
    xor rsi,rsi
    xor rdx,rdx
    xor rdi,rdi
    mov r8,rax    # Save client socket file descriptor
    mov rax,0x39
    syscall
    cmp rax,0x0
    je child
    mov rax,0x3
    mov rdi,r8
    syscall
    jmp listen
    
    child:
    # Read the HTTP request
    lea rsi, [rip + buffer]  
    mov rdi,r8
    mov rdx, 1024            
    mov rax, 0               # read()
    syscall
    push rax 
   call Parse_Get   				
   lea rdi, [rip + Page_Space]
   call File_Open_Read_Write_Subroutine
   jmp exit
    
exit:
mov rax,0x3c
mov rdi,0x0
syscall

GET:
	.string "\nGet_Request From :\n"
POST:
	.string "\nPost_Request\n"
method_405:
	.string "./405.html"

	
Get_Request:
	mov rdi,0x1
	mov rax,0x1
	mov rdx,13 #13 noramly
	lea rsi,[rip+GET] 
	syscall	

	ret
	
	
POST_REQUEST:
	mov rdi,0x1
	mov rax,0x1
	mov rdx,14
	lea rsi,[rip+POST]
	syscall
	ret

Page_Extract:
	mov cl,byte ptr [rsi+5]
	cmp cl,0x20
	je Get_Request
	mov [rdi+rbx],cl
	inc rbx
	inc rsi
	jmp Page_Extract
	

	
Parse_Post:
	lea rsi,[rip+buffer]
	cmp byte ptr [rsi],0x50
	jne Not_Get
	cmp byte ptr[rsi+1],0x4f
	jne Not_Get
	cmp byte ptr[rsi+2],0x53
	jne Not_Get #try except for POST instead
	cmp byte ptr[rsi+3],0x54
	jne Not_Get
	cmp byte ptr[rsi+4],0x20
	jne Not_Get # try to check for JUNK
	jmp POST_REQUEST
	ret
Parse_Get:
	lea rsi,[rip+buffer]
	cmp byte ptr [rsi],0x47
	jne Not_Get
	cmp byte ptr[rsi+1],0x45
	jne Not_Get
	cmp byte ptr[rsi+2],0x54
	jne Not_Get
	cmp byte ptr[rsi+3],0x20
	jne Not_Get # try to check for JUNK
	
	lea rdi,[rip+Page_Space]
	add rdi,2
	jmp Page_Extract	
	ret
	
Not_Get:
call POST_REQUEST
lea rdi,[rip+method_405]
call File_Open_Read_Write_Subroutine

#ret


File_Open_Read_Write_Subroutine: 


    open:   
      # make it dynamic at some point
    mov rsi, 0             # O_RDONLY
    mov rax, 2               # open()
    xor rdx,rdx
    syscall
    cmp rax,0xfffffffffffffffe
    je Not_Get
    
    mov r9, rax                 # Save file descriptor

    # Read the file contents
    lea rsi, [rip + file_buffer] 
    mov rdx, 4096                # Number of bytes to read
    mov rdi, r9                  # Use file descriptor 
    mov rax, 0                   # read()
    syscall	 
    push rax	
    # Send HTTP response header
    mov rdi,r8
    lea rsi, [rip + response_header] 
    mov rdx, 19                  # Length of HTTP header (19 bytes)
    mov rax, 1                   # write()
    syscall
    # Send file contents
    lea rsi, [rip + file_buffer] 
    pop rdx
    mov rax, 1                   # write()
    syscall
    mov rax,0x3
    syscall
    ret



