#lang racket

(define (isvar e)
  (eq? (car e) 'VAR))
(define (name e)
  (cadr e))
(define (isconst e)
  (eq? (car e) 'QUOTE))
(define (number e)
  (cadr e))
(define (isnull S)
  (eq? (car S) 'SKIP))
(define (isassignment S)
  (eq? (car S) 'ASSIGN))
(define (lhs S)
  (cadr S))
(define (rhs S)
  (caddr S))
(define (assoc e omega)
  (omega e))
(define (update omega x y)
  (lambda (z)
    (if (eq? z x)
        y
        (omega z))))
(define (issum e)
  (eq? (car e) '+))
(define (operand1 e)
  (cadr e))
(define (operand2 e)
  (caddr e))
(define (simplevalue e)
  (cond
    ((isconst e) (number e))
    ((issum e) (+ (simplevalue (operand1 e)) (simplevalue (operand2 e))))
    (else 'ERROR)))
(define (iseq e)
  (eq? (car e) 'eq))
(define (first lst)
  (car lst))
(define (second lst)
  (cadr lst))
(define (issequence S)
  (eq? (car S) 'SEQUENCE))
(define (isconditional S)
  (eq? (car S) 'IF))
(define (iftest S)
  (cadr S))
(define (then S)
  (cadr S))
(define (else S)
  (caddr S))
(define (isloop S)
  (eq? (car S) 'LOOP))
(define (wtest S)
  (cadr S))
(define (wbody S)
  (caddr S))
(define (fourlist a b c d)
  (list a b c d))
(define (q x)
  (if (> x 100)
      x
      (q (* 2 x))))
(define (w y x q r)
  (if (>= r x)
      (w y x (+ q 1) (- r x))
      (fourlist y x q r)))
(define (fact n)
  (f n 1))
(define (f n m)
  (if (= n 0)
      m
      (f (- n 1) (* m n))))
(define (prev-val e n v)
  (if (eq? (caar n) (name e))
      (cdar v)
      (prev-val e (cdr n) (cdr v))))
(define (get-address x name-address-list)
  (if (eq? (caar name-address-list) x)
      (cdar name-address-list)
      (get-address x (cdr name-address-list))))
(define (get-value addr address-value-list)
  (if (eq? (caar address-value-list) addr)
      (cdar address-value-list)
      (get-value addr (cdr address-value-list))))
(define (update-value addr new-value address-value-list)
  (if (eq? (caar address-value-list) addr)
      (cons (cons addr new-value) (cdr address-value-list))
      (cons (car address-value-list) (update-value addr new-value (cdr address-value-list)))))
(define (add-variable x addr name-address-list)
  (cons (cons x addr) name-address-list))
(define (isdo-while S)
  (eq? (car S) 'DO-WHILE))
(define (dobody1 S)
  (cadr S))
(define (dotest S)
  (caddr S))
(define (dobody2 S)
  (cadddr S))
(define (is-recbegin S)
  (eq? (car S) 'RECBEGIN))
(define (rec-body S)
  (cadr S))
(define (is-recur S)
  (eq? (car S) 'RECUR))
(define (make-stack)
  (let ((lst '()))
    (lambda (op . args)
      (cond
        ((eq? op 'push) (set! lst (cons (car args) lst)))
        ((eq? op 'pop) (let ((r (car lst)))
                        (set! lst (cdr lst))
                        r))
        ((eq? op 'empty?) (null? lst))))))
(define (push! s x)
  (s 'push x))
(define (pop! s)
  (s 'pop))
(define (stack-empty? s)
  (s 'empty?))
(define rec-stack (make-stack))
(define (while-test S)
  (cadr S))
(define (while-body S)
  (caddr S))

(define (val e name-address-list address-value-list)
  (cond
    ((isvar e)
     (get-value (get-address (name e) name-address-list) address-value-list))
    ((isconst e) (number e))
    ((issum e) 
     (+ (val (operand1 e) name-address-list address-value-list) (val (operand2 e) name-address-list address-value-list)))
    ((iseq e) 
     (eq? (val (operand1 e) name-address-list address-value-list) (val (operand2 e) name-address-list address-value-list)))
    (else 'ERROR)))

(define (effect S name-address-list address-value-list)
  (cond
    ((isnull S) address-value-list)
    ((isassignment S) 
     (let ((addr (get-address (lhs S) name-address-list)))
       (update-value addr (val (rhs S) name-address-list address-value-list) address-value-list)))
    ((eq? (car S) '-) ; x: -y
     (let ((y-addr (get-address (cadr S) name-address-list)))
       (add-variable (caddr S) y-addr name-address-list)))
    ((issequence S) 
     (effect (second S) name-address-list (effect (first S) name-address-list address-value-list)))
    ((isconditional S)
     (effect (if (val (iftest S) name-address-list address-value-list)
                 (then S)
                 (else S))
             name-address-list
             address-value-list))
    ((isloop S)
     (letrec ((w (lambda (address-value-list)
                  (if (val (wtest S) name-address-list address-value-list)
                      (w (effect (wbody S) name-address-list address-value-list))
                      address-value-list))))
       (w address-value-list)))
    ; ex 5.13
    ((eq? (car S) 'WHILE)
     (letrec ((while-loop (lambda (address-value-list results)
                         (if (val (while-test S) name-address-list address-value-list)
                             (while-loop 
                               (effect (while-body S) name-address-list address-value-list results) 
                               (append results (list 'some-result)))
                             address-value-list))))
       (while-loop address-value-list '())))
    ((isdo-while S)
     (letrec ((dowhile-loop (lambda (address-value-list)
                              (let ([new-address-value-list (effect (dobody1 S) name-address-list address-value-list)])
                                (if (val (dotest S) name-address-list new-address-value-list)
                                    (dowhile-loop (effect (dobody2 S) name-address-list new-address-value-list))
                                    new-address-value-list)))))
       (dowhile-loop address-value-list)))
    ((is-recbegin S)
     (push! rec-stack (rec-body S))
     (effect (rec-body S) name-address-list address-value-list))
    ((is-recur S)
     (let ((saved-block (pop! rec-stack)))
       (push! rec-stack saved-block)  
       (effect saved-block name-address-list address-value-list)))
    (else 'ERROR)))