#lang racket

; Converted into Racket
(define (map f)
  (define g
    (lambda (x)
      (if (eq? x '())
          '()
          (cons (f (car x)) (g (cdr x))))))
  g)
(define (aplist fl)
  (lambda (x)
    (if (eq? x '())
        '()
        (cons ((car fl) x) ((aplist (cdr fl)) x)))))
(define increments
  (cons (lambda (v) (+ v 1))
        (cons (lambda (v) (+ v 2))
              (cons (lambda (v) (+ v 3))
                    '()))))
(define (dot f g)
  (lambda (x) (f (g x))))
(define (B f)
  (lambda (g)
    (lambda (x) (f (g x)))))
(define (twice f)
  ((B f) f))
(define (fac n)
  (if (= n 0)
      1
      (* n (fac (- n 1)))))
(define (facc n c)
  (if (< n 0)
      (cons 'NEGATIVE (c 1))
      (if (= n 0)
          (c 1)
          (facc (- n 1) (lambda (z) (c (* n z)))))))
(define p (lambda (x) (= x 1)))
(define q (lambda (x) (= x 2)))
(define (orp p q)
  (lambda (x)
    (if (p x)
        #t
        (q x))))
(define (seq p q)
  (lambda (x)
    (if (null? x)
        (p '())
        (if (and (p '()) (q x))
            #t
            ((seq (lambda (y) (p (cons (car x) y))) q) (cdr x))))))
(define (consonant x)
  (define consonants "bcdfghjklmnpqrstvwxyzBCDFGHJKLMNPQRSTVWXYZ")
  (member x (string->list consonants)))
(define (vowel x)
  (define vowels "aeiouAEIOU")
  (member x (string->list vowels)))
(define (csequence x)
  ((orp consonant (seq consonant csequence)) x))
(define (vsequence x)
  ((orp vowel (seq vowel vsequence)) x))
(define (syllable x)
  ((orp (seq csequence vsequence)
        (orp (seq vsequence csequence)
             (seq csequence (seq vsequence csequence)))) x))
(define (line a b)
  `(line ,a ,b))
(define (picture . p)
  `(picture ,@p))
(define (ladder n a b)
  (if (= n 1)
      (line a b)
      (picture (line (* n a) b) (ladder (- n 1) a b))))
(define (xproj a x)
  (vector (* a (vector-ref x 0)) 0))
(define (yproj a y)
  (vector 0 (* a (vector-ref y 1))))
(define (box a b)
  (let ((xproj-b (xproj a b))
        (yproj-b (yproj a b)))
    (list (list (line a xproj-b) (line a yproj-b))
          (list (line (+ a b) (vector (- (vector-ref xproj-b 0)) 0))
                (line (+ a b) (vector 0 (- (vector-ref yproj-b 1))))))))
(define (both p q)
  (lambda (a b)
    (list (p a b) (q a b))))
(define (xdisp k p)
  (lambda (a b)
    (p (+ a (* k (vector-ref b 0))) b)))
(define (ydisp k p)
  (lambda (a b)
    (p a (+ b (* k (vector-ref b 1))))))

(define (ddisp k p)
  (lambda (a b)
    (p (+ a (* k (vector-ref b 0))) (+ b (* k (vector-ref b 1))))))
(define (row n p)
  (if (= n 1)
      p
      (both p (xdisp 1 (row (- n 1) p)))))
(define (col n p)
  (if (= n 1)
      p
      (both p (ydisp 1 (col (- n 1) p)))))
(define (xfrac k p)
  (lambda (a b)
    (p a (+ b (* k (vector-ref b 0))))))
(define (altcol n p q)
  (if (= n 1)
      p
      (both p (ydisp 1 (altcol (- n 1) q p)))))
(define (cascade n p)
  (if (= n 1)
      p
      (both p (ydisp 1 (xfrac 2 (cascade (- n 1) p))))))
(define (xdimin n s p)
  (if (= n 1)
      (s 1 p)
      (both (s n p) (xdimin (- n 1) s (xdisp p)))))