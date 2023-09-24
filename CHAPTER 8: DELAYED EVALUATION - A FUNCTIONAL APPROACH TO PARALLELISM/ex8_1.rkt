#lang racket

(define (sumints n)
  (sum (integersbetween 1 n)))
(define (integersbetween m n)
  (if (> m n)
      '()
      (cons m (delay (integersbetween (+ m 1) n)))))
(define (sum x)
  (if (null? x)
      0
      (+ (car x) (sum (force (cdr x))))))
(define (adjust a b)
  (if (< (force a) 0)
      (force a)
      (+ (force a) (force b))))
(define (first k x)
  (if (= k 0)
      '()
      (cons (car (force x)) (first (- k 1) (force (cdr x))))))
(define (firstsum k)
  (first k (sums 0 (integersfrom 1))))
(define (sums a x)
  (cons (+ a (car x)) (delay (sums (+ a (car x)) (force (cdr x))))))
(define (integersfrom m)
  (delay (cons m (lambda () (integersfrom (+ m 1))))))