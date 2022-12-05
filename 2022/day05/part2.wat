(module
    (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))
    (import "wasi_unstable" "fd_read" (func $fd_read (param i32 i32 i32 i32) (result i32)))

    (memory 1)
    (export "memory" (memory 0))

    (func $main (export "_start")
        (local $idx i32)
    
        (call $fls)
        (loop $rl
            (call $prc) (br_if $rl)
        )
        
        (i32.const 0) (local.set $idx)
        (loop $pl
            (local.get $idx) (call $pop) (call $write)
            (local.get $idx) (i32.const 1) (i32.add) (local.tee $idx) (i32.const 9) (i32.lt_u) (br_if $pl)
        )
        (i32.const 10) (call $write)
    )
    
    ;; Fill stacks
    (func $fls
        (local $br i32) (local $stix i32) (local $fc i32)
        
        (i32.const 1) (local.set $br)
        (loop $stf
            (call $readln) (drop)
            (i32.const 1) (i32.load8_u) (i32.const 49) (i32.eq) (if
                (then (i32.const 0) (local.set $br))
                (else
                    (i32.const 0) (local.set $stix)
                    (loop $sl
                        (i32.const 4) (local.get $stix) (i32.mul) (i32.const 1) (i32.add) (i32.load8_u) (local.tee $fc)
                        (i32.const 32) (i32.eq) (if
                            (then nop)
                            (else
                                (local.get $stix) (local.get $fc) (call $pushbt)
                            )
                        )
                        (local.get $stix) (i32.const 1) (i32.add) (local.tee $stix) (i32.const 9) (i32.lt_u) (br_if $sl)
                    )
                )
            )
            (local.get $br) (br_if $stf)
        )
    )
    
    ;; Process rule, return whether to continue
    (func $prc (result i32)
        (local $amount i32) (local $from i32) (local $to i32) (local $idx i32)
        
        (call $readnum) (local.tee $amount)
        (i32.const 65536) (i32.eq) (if
            (then (i32.const 0) (return))
            (else nop)
        )
        
        (call $readnum) (i32.const 1) (i32.sub) (local.set $from)
        (call $readnum) (i32.const 1) (i32.sub) (local.set $to)
        
        (i32.const 0) (local.set $idx)
        (loop $mvl
            (local.get $idx) (local.get $from) (call $pop) (i32.store8)
            (local.get $idx) (i32.const 1) (i32.add) (local.tee $idx) (local.get $amount) (i32.lt_u) (br_if $mvl)
        )
        
        (i32.const 0) (local.set $idx)
        (loop $mvl
            (local.get $to) (local.get $amount) (local.get $idx) (i32.sub) (i32.const 1) (i32.sub) (i32.load8_u) (call $push)
            (local.get $idx) (i32.const 1) (i32.add) (local.tee $idx) (local.get $amount) (i32.lt_u) (br_if $mvl)
        )
        
        (i32.const 1) (return)
    )
    
    (func $push (param $stack i32) (param $val i32)
        (local $addr i32) (local $idx i32)
        (local.get $stack) (i32.const 128) (i32.mul) (i32.const 512) (i32.add) (local.tee $addr)
        (i32.load8_u) (i32.const 1) (i32.add) (local.set $idx)
        (local.get $addr) (local.get $idx) (i32.store8)
        (local.get $addr) (local.get $idx) (i32.add) (local.get $val) (i32.store8)
    )
    
    (func $pushbt (param $stack i32) (param $val i32)
        (local $addr i32) (local $idx i32) (local $ctr i32)
        (local.get $stack) (i32.const 128) (i32.mul) (i32.const 512) (i32.add) (local.tee $addr)
        (i32.load8_u) (i32.const 1) (i32.add) (local.set $idx)
        (local.get $addr) (local.get $idx) (i32.store8)
        
        (local.get $idx) (local.set $ctr)
        (loop $movl
            (local.get $addr) (local.get $ctr) (i32.add)
            (local.get $addr) (local.get $ctr) (i32.add) (i32.const 1) (i32.sub) (i32.load8_u)
            (i32.store8)
            
            (local.get $ctr) (i32.const 1) (i32.sub) (local.tee $ctr) (i32.const 1) (i32.gt_u) (br_if $movl)
        )
        (local.get $addr) (i32.const 1) (i32.add) (local.get $val) (i32.store8)
    )
    
    (func $pop (param $stack i32) (result i32)
        (local $addr i32) (local $idx i32)
        (local.get $stack) (i32.const 128) (i32.mul) (i32.const 512) (i32.add) (local.tee $addr)
        (i32.load8_u) (local.set $idx)
        (local.get $addr) (local.get $idx) (i32.const 1) (i32.sub) (i32.store8)
        (local.get $addr) (local.get $idx) (i32.add) (i32.load8_u)
    )
    
    ;; Returns len
    (func $readln (result i32)
        (local $idx i32) (local $chr i32)
        
        (i32.const 0) (local.set $idx)
        (loop $readl
            (call $read) (local.tee $chr)
            (i32.const 10) (i32.eq) (if
                (then
                    (local.get $idx) (return)
                )
                (else
                    (local.get $idx) (local.get $chr) (i32.store8)
                    (local.get $idx) (i32.const 1) (i32.add) (local.set $idx)
                )
            )
            (br $readl)
        )
        (unreachable)
    )
    
    (func $readnum (result i32)
        (local $num i32) (local $chr i32) (local $scp i32)
        
        (i32.const 0) (local.set $num)
        (i32.const 1) (local.set $scp)

        (loop $readl
            (call $read) (local.tee $chr)
            (i32.const 264) (i32.load) (i32.const 0) (i32.eq) (if
                (then (i32.const 65536) (return))
                (else nop)
            )
            (i32.const 48) (i32.lt_u)
            (local.get $chr) (i32.const 57) (i32.gt_u)
            (i32.or) (if
                (then
                    (local.get $scp) (if
                        (then)
                        (else
                            (local.get $num) (return)
                        )
                    )
                )
                (else
                    (i32.const 0) (local.set $scp)
                    (local.get $num) (i32.const 10) (i32.mul)
                    (local.get $chr) (i32.const 48) (i32.sub) (i32.add)
                    (local.set $num)
                )
            )
            (br $readl)
        )
        (unreachable)
    )

    (func $read (result i32)
        ;; Creating io vector (store to location outside of io buffer, so readln works)
        (i32.const 256) (i32.const 268) (i32.store)
        (i32.const 260) (i32.const 1) (i32.store)
        
        (i32.const 0)   ;; stdin
        (i32.const 256) ;; IO vector
        (i32.const 1)   ;; IO vector len
        (i32.const 264) ;; Somewhere to store read bytes
        
        (call $fd_read) (drop)
        
        (i32.const 268) (i32.load8_u)
    )
    
    (func $write (param $chr i32)
        (i32.const 0) (local.get $chr) (i32.store8)
        
        ;; Creating io vector
        (i32.const 256) (i32.const 0) (i32.store)
        (i32.const 260) (i32.const 1) (i32.store)
        
        (i32.const 1)   ;; stdout
        (i32.const 256) ;; IO vector
        (i32.const 1)   ;; IO vector len
        (i32.const 264) ;; Somewhere to store written bytes
        
        (call $fd_write) (drop)
    )
    
    (func $writenum (param $num i32)
        (local $len i32) (local $digit i32) (local $grow i32)

        (i32.const 0) (local.set $len)
        (i32.const 0) (local.set $digit)
        (i32.const 1) (local.set $grow)
        
        (loop $count
            (local.get $len) (i32.const 1) (i32.add) (local.set $len)
            (local.get $grow) (i32.const 10) (i32.mul) (local.tee $grow)
            (local.get $num) (i32.lt_u) (br_if $count)
        )
        
        (local.get $num) (local.set $grow)
        (i32.const 0) (local.set $digit)
        
        (loop $chars
            (local.get $len) (local.get $digit) (i32.sub) (i32.const 1) (i32.sub)
            (local.get $grow) (i32.const 10) (i32.rem_u) (i32.const 48) (i32.add)
            (i32.store8)
            
            (local.get $grow) (i32.const 10) (i32.div_u) (local.set $grow)
            
            (local.get $digit) (i32.const 1) (i32.add) (local.tee $digit)
            (local.get $len) (i32.lt_u) (br_if $chars)
        )
        
        (local.get $len) (i32.const 10) (i32.store8)
        
        ;; Creating io vector
        (i32.const 256) (i32.const 0) (i32.store)
        (i32.const 260) (local.get $len) (i32.const 1) (i32.add) (i32.store)
        
        (i32.const 1)   ;; stdout
        (i32.const 256) ;; IO vector
        (i32.const 1)   ;; IO vector len
        (i32.const 264) ;; Somewhere to store written bytes
        
        (call $fd_write) (drop)
    )
)

