#lang racket

(define (dot f g)
  (lambda (x) (f (g x))))

(define (map f)
  (lambda (x)
    (if (null? x)
        null
        (cons (f (car x)) ((map f) (cdr x))))))

#|
dot: (Y -> Z) x (X -> Y) -> (X -> Z)
map: (U -> V) -> (List(U) -> List(V))
dot(map, map): (U2 -> V2) -> (List(List(U2)) -> List(List(V2)))

X = U2 -> V2
Y = U1 -> V1
Z = List(U1) -> List(U2)

Y = List(U2) -> List(V2)
U1 = List(U2)
V1 = List(v2)
|#