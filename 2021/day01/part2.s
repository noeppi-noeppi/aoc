; For lin64
; nasm -felf64 -o part2.o part2.s
; ld -o part2 part2.o
; ./part2

          global    _start
          default   rel
          
          section   .text
          
_iint:
          xor       r8, r8
_iint_read_char:
          sub       rsp, 1
          xor       rax, rax
          xor       rdi, rdi
          lea       rsi, [rsp]
          mov       rdx, 1
          syscall
          xor       rbx, rbx
          mov       bl, [rsp]
          add       rsp, 1
          test      rax, rax
          jz        _iint_end
          sub       rbx, 10
          test      rbx, rbx
          jz        _iint_end
          sub       rbx, 38
          mov       rax, r8
          mov       rcx, 10
          mul       rcx
          add       rax, rbx
          mov       r8, rax
          jmp       _iint_read_char
_iint_end:
          ret
          
_oint:
          xor       rcx, rcx
          mov       rax, 1
          mov       rbx, 10
_oint_check_has_more_digits:
          add       rcx, 1
          mul       rbx
          cmp       r8, rax
          jl        _oint_counted_digits
          jmp       _oint_check_has_more_digits
_oint_counted_digits:
_oint_print_digit:
          sub       rcx, 1
          mov       rax, 1
          mov       rbx, 10
          push      rbp
          mov       rbp, 0
_oint_mul_base:
          cmp       rbp, rcx
          jge       _oint_do_print
          add       rbp, 1
          mul       rbx
          jmp       _oint_mul_base
_oint_do_print:
          pop       rbp
          mov       rbx, rax
          mov       rax, r8
          xor       rdx, rdx
          div       rbx
          mov       rbx, 10
          xor       rdx, rdx
          div       rbx
          add       rdx, 48
          
          push      rcx
          sub       rsp, 1
          mov       [rsp], dl
          mov       rax, 1
          mov       rdi, 1
          lea       rsi, [rsp]
          mov       rdx, 1
          syscall
          add       rsp, 1
          pop       rcx
          
          test      rcx, rcx
          jnz       _oint_print_digit
          
          mov       rdx, 10
          sub       rsp, 1
          mov       [rsp], dl
          mov       rax, 1
          mov       rdi, 1
          lea       rsi, [rsp]
          mov       rdx, 1
          syscall
          add       rsp, 1
          
          ret
          

_start:
          xor       r12, r12
          call      _iint
          mov       r10, r8
          call      _iint
          mov       r9, r8
          call      _iint
_start_next_int:
          mov       r11, r10
          mov       r10, r9
          mov       r9, r8
          push      r11
          call      _iint
          pop       r11
          test      r8, r8
          jz        _start_end
          cmp       r8, r11
          jle       _start_next_int
          add       r12, 1
          jmp       _start_next_int
_start_end:
          mov       r8, r12
          call      _oint
          
          mov       rax, 60
          xor       rdi, rdi
          syscall
