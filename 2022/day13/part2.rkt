#lang racket

(require srfi/1)

(define (digit? chr) (and (char>=? chr #\0) (char<=? chr #\9)))
(define (comma? chr) (char=? chr #\,))
(define (skip-comma line) (drop-while comma? line))

(define (read-packet line) (car (parse-packet (string->list line))))
(define (parse-packet line) (if (char=? (car line) #\[)
  (match (parse-packet-list (cdr line))
    [(cons ls rl) (cons ls rl)]
  )
  (cons
    (string->number (list->string (take-while digit? line)))
    (skip-comma (drop-while digit? line))
  )
))
(define (parse-packet-list line) (if (char=? (car line) #\])
  (cons null (skip-comma (cdr line)))
  (match (parse-packet line)
    [(cons hd rl) (match (parse-packet-list rl)
      [(cons tl rll) (cons (cons hd tl) rll)]
    )]
  )
))
(define (read-nonempty) (match (read-line) ["" (read-nonempty)] [line line]))

(define (read-pkgs) (match (read-nonempty) [fl (if (equal? fl eof)
  null
  (cons (read-packet fl) (read-pkgs))
)]))

(define (then first second) (if (equal? first 0) second first))
(define (pk-cmp pa pb) (match (cons pa pb)
  [(cons '() '()) 0]
  [(cons '() (cons hb tb)) -1]
  [(cons (cons ha ta) '()) 1]
  [(cons (cons ha ta) (cons hb tb)) (then (pk-cmp ha hb) (pk-cmp ta tb))]
  [(cons (cons ha ta) nb) (pk-cmp pa (cons nb null))]
  [(cons '() nb) (pk-cmp pa (cons nb null))]
  [(cons na (cons hb tb)) (pk-cmp (cons na null) pb)]
  [(cons na '()) (pk-cmp (cons na null) pb)]
  [(cons na nb) (- na nb)]
))
(define (pk-lower pa pb) (< (pk-cmp pa pb) 0))

(define (all-pkgs) (cons (read-packet "[[2]]") (cons (read-packet "[[6]]") (read-pkgs))))
(define (sorted-pkgs) (sort (all-pkgs) pk-lower))

(write (match (sorted-pkgs) [s 
  (*
    (+ 1(list-index (curry equal? (read-packet "[[2]]")) s))
    (+ 1(list-index (curry equal? (read-packet "[[6]]")) s))
  )
]))
