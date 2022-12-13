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

(define (read-pairs) (match (read-nonempty) [fl (if (equal? fl eof)
  null
  (cons (match (read-nonempty) [sl (cons (read-packet fl) (read-packet sl))]) (read-pairs))
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
(define (pk-lower both) (< (pk-cmp (car both) (cdr both)) 0))
(define (map-index f xs) (map f xs (range (length xs))))
(define (pk-smd both idx) (if (pk-lower both) (+ 1 idx) 0))

(write (apply + (map-index pk-smd (read-pairs))))
