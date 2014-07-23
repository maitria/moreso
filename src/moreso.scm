;; Utilities

(define (map proc list)
  (let loop ((remaining list)
	     (result '()))
    (if (null? remaining)
      (reverse result)
      (loop (cdr remaining) (cons (proc (car remaining)) result)))))

(define (reduce proc initial-value list)
  (let loop ((remaining list)
	     (accumulator initial-value))
    (if (null? remaining)
      accumulator
      (loop (cdr remaining) (proc accumulator (car remaining))))))

;; Miscellaneous

(define moreso:unspecified '#(moreso:unspecified))

;; Procedures

(define moreso:procedure-tag '#(moreso:procedure))

(define (moreso:lambda arg-list body lexical-environment)
  `#(,moreso:procedure-tag ,arg-list ,body ,lexical-environment))

(define (moreso:procedure? p)
  (and (vector? p)
       (eq? moreso:procedure-tag (vector-ref p 0))))

(define (moreso:procedure-arg-list p)
  (vector-ref p 1))

(define (moreso:procedure-body p)
  (vector-ref p 2))

(define (moreso:procedure-lexical-environment p)
  (vector-ref p 3))

;; Macros

(define moreso:macro-tag '#(moreso:macro))

(define (moreso:make-macro procedure)
  (vector moreso:macro-tag procedure))

(define (moreso:macro? macro)
  (and (vector? macro)
       (eq? (vector-ref macro 0) moreso:macro-tag)))

(define (moreso:macro-procedure macro)
  (vector-ref macro 1))

;; Eval

(define (moreso:bind-args env args-passed args-specified)
  (cond
    ((and (null? args-passed)
	  (null? args-specified))
     env)

    ((symbol? args-specified)
     (cons (cons args-specified args-passed) env))

    ((null? args-specified)
     (raise "Too many parameters"))

    ((null? args-passed)
     (raise "Too few parameters"))

    (else
      (moreso:bind-args
	(cons (cons (car args-specified)
		    (car args-passed))
	      env)
	(cdr args-passed)
	(cdr args-specified)))))

(define (moreso:apply p args)
  (if (moreso:procedure? p)
    (let ((environment (moreso:bind-args
			 (moreso:procedure-lexical-environment p)
			 args
			 (moreso:procedure-arg-list p))))
      (let body-loop ((body (moreso:procedure-body p))
		      (value (if #f #f)))
	(if (null? body)
	  value
	  (body-loop
	    (cdr body)
	    (moreso:eval (car body) environment)))))
    (apply p args)))

(define (moreso:eval expr env)
  (cond
    ((symbol? expr)
     (let ((cell (assq expr env)))
       (if cell
	 (cdr cell)
	 (raise (string-append "Unbound symbol `"
			       (symbol->string expr)
			       "'")))))

    ((list? expr)
     (case (car expr)
       ;; Special forms
       ((begin)
	(if (= 1 (length expr))
	  moreso:unspecified
	  (let subexpression-loop ((subexpressions (cdr expr)))
	    (if (null? (cdr subexpressions))
	      (moreso:eval (car subexpressions) env)
	      (begin
		(moreso:eval (car subexpressions) env)
		(subexpression-loop (cdr subexpressions)))))))
       
       ((if)
	(if (moreso:eval (cadr expr) env)
	  (moreso:eval (caddr expr) env)
          (if (= 4 (length expr))
	    (moreso:eval (cadddr expr) env)
            moreso:unspecified)))

       ((lambda)
	(moreso:lambda (cadr expr) (cddr expr) env))

       ((quote)
	(if (= 2 (length expr))
	  (cadr expr)
	  (raise "`quote' expects a single form")))

       ((set!)
	(if (not (= 3 (length expr)))
	  (raise "`set!' expects two forms")
	  (let ((cell (assq (cadr expr) env)))
	    (if cell
	      (set-cdr! cell (moreso:eval (caddr expr) env))
	      (raise (string-append "Unbound symbol `"
				    (symbol->string (cadr expr))
				    "'"))))))

       (else
	 (let ((first-form (moreso:eval (car expr) env))
	       (unevaluated-args (cdr expr)))
	   (if (moreso:macro? first-form)
	     (moreso:eval (moreso:apply (moreso:macro-procedure first-form)
					(cdr expr))
			  env)
	     (let ((evaluated-args (let loop ((evaluated '())
					      (remaining unevaluated-args))
				     (if (null? remaining)
				       (reverse evaluated)
				       (loop
					 (cons (moreso:eval (car remaining) env)
					       evaluated)
					 (cdr remaining))))))
	       (moreso:apply first-form evaluated-args)))))))

    (else
     expr)))

;; Default environment

(define moreso:cond
  (moreso:make-macro
    (lambda args
      (let* ((reversed-conditions (reverse args))
	     (else-cond? (and (not (null? reversed-conditions))
			      (eq? 'else (caar reversed-conditions))))
	     (else-expr (if else-cond?
			  (cadar reversed-conditions)
			  moreso:unspecified))
	     (conds-left (if else-cond?
			   (cdr reversed-conditions)
			   reversed-conditions)))
	(reduce
	  (lambda (exprs a-cond)
	    `(if ,(car a-cond)
	       (begin ,@(cdr a-cond))
	       ,exprs))
	  else-expr
	  conds-left)))))

(define moreso:let
  (moreso:make-macro
    (lambda (bindings . body)
      (let* ((loop-label (if (symbol? bindings)
			   bindings
			   #f))
	     (bindings (if loop-label
			 (car body)
			 bindings))
	     (body (if loop-label
		     (cdr body)
		     body))
	     (binding-names (map car bindings))
	     (binding-exprs (map cadr bindings))
	     (binding-lambda `(lambda ,binding-names ,@body)))
	(if loop-label
	  `((lambda (,loop-label)
	      (set! ,loop-label ,binding-lambda)
	      (,loop-label ,@binding-exprs)) #f)
	  `(,binding-lambda ,@binding-exprs))))))

(define moreso:r5rs
  `((+ . ,+)
    (/ . ,/)
    (= . ,=)
    (car . ,car)
    (cdr . ,cdr)
    (cond . ,moreso:cond)
    (let . ,moreso:let)
    (null? . ,null?)))
