;;;; environments


(define %interaction-environment
  (%make-environment "interaction-environment" '() (%null-mstore) #t))

(define (%copy-environment env name mutable)
  (define (copy-alist lst)
    (let loop ((lst lst) (acc '()))
      (if (null? lst)
	  (reverse acc)
	  (loop (cdr lst) (cons (cons (caar lst) (cdar lst)) acc)))))
  (match (%environment-data env)
    (#(_ oblist mstore omutable)
     (%make-environment
      (cond ((string? name) name)
	    ((symbol? name) (symbol->string name))
	    (else (error "bad environment name" name)))
      (if (or omutable mutable)
	  (copy-alist oblist)
	  oblist)
      (if (or omutable mutable)
	  (cons (copy-alist (car mstore)) (cdr mstore))
	  mstore)
      mutable))))

(define %null-environment/5
  (%make-environment "null-environment" '() (%null-mstore) #f))

(let ()
  (define (def proc names argc)
    (for-each
     (lambda (name)
       (let ((p (%procedure proc name argc)))
	 (set-toplevel-variable! (string->symbol name) p %interaction-environment)))
     (if (list? names) names (list names))))
  (define (def* proc names argc)
    (for-each
     (lambda (name)
       (let ((p (%procedure proc name (- (+ argc 1)))))
	 (set-toplevel-variable! (string->symbol name) p %interaction-environment)))
     (if (list? names) names (list names))))
  (define (check x pred name loc)
    (if (pred x)
	x
	(%error
	 (string-append
	  "argument to `" loc "' is not of correct type (" name ")")
	 x)))
  (define (check-procedure x loc)
    (%procedure-code (check x %procedure? "procedure" loc)))
  (define (check-port x loc)
    (check x (lambda (x) (or (input-port? x) (output-port? x))) "port" loc))
  (define (check-string x loc)
    (check x (lambda (x) (string? x)) "string" loc))
  (define (check-environment x loc)
    (check x %environment? "environment" loc))
  (define (check-report r loc)
    (if (eqv? r 5)
	r
	(%error "unsupported Scheme report" r)))
  ;; this is not strictly necessary but avoids unprintable results
  ;; from primitives of the underlying implementation
  (define (undefd p) 
    (lambda args
      (apply p args)
      (%void)))
  (let-syntax ((defp
		 (syntax-rules ()
		   ((_ var check name)
		    (def* (lambda args
			    (let-optionals args ((val #f) (reset #f))
			      (if (null? args)
				  var
				  (set! var (if reset val (check val name))))))
		      name 0)))))
    (def not "not" 1)
    (def boolean? "boolean?" 1)
    (def eq? "eq?" 2)
    (def eqv? "eqv?" 2)
    (def equal? "equal?" 2)
    (def pair? "pair?" 1)
    (def cons '("cons" "%%cons") 2)
    (def car "car" 1)
    (def cdr "cdr" 1)
    (def caar "caar" 1)
    (def cadr "cadr" 1)
    (def cdar "cdar" 1)
    (def cddr "cddr" 1)
    (def caaar "caaar" 1)
    (def caadr "caadr" 1)
    (def cadar "cadar" 1)
    (def caddr "caddr" 1)
    (def cdaar "cdaar" 1)
    (def cdadr "cdadr" 1)
    (def cddar "cddar" 1)
    (def cdddr "cdddr" 1)
    (def caaaar "caaaar" 1)
    (def caaadr "caaadr" 1)
    (def caadar "caadar" 1)
    (def caaddr "caaddr" 1)
    (def cadaar "cadaar" 1)
    (def cadadr "cadadr" 1)
    (def caddar "caddar" 1)
    (def cadddr "cadddr" 1)
    (def cdaaar "cdaaar" 1)
    (def cdaadr "cdaadr" 1)
    (def cdadar "cdadar" 1)
    (def cdaddr "cdaddr" 1)
    (def cddaar "cddaar" 1)
    (def cddadr "cddadr" 1)
    (def cdddar "cdddar" 1)
    (def cddddr "cddddr" 1)
    (def (lambda (x y) (set-car! x y) (%void)) "set-car!" 2)
    (def (lambda (x y) (set-cdr! x y) (%void)) "set-cdr!" 2)
    (def null? "null?" 1)
    (def list? "list?" 1)
    (def* list '("list" "%%list") 0)
    (def length "length" 1)
    (def list-tail "list-tail" 2)
    (def list-ref "list-ref" 2)
    (def* append '("append" "%%append") 1)
    (def reverse "reverse" 1)
    (def memq "memq" 2)
    (def memv "memv" 2)
    (def member "member" 2)
    (def assq "assq" 2)
    (def assv "assv" 2)
    (def assoc "assoc" 2)
    (def symbol? "symbol?" 1)
    (def symbol->string "symbol->string" 1)
    (def string->symbol "string->symbol" 1)
    (def number? "number?" 1)
    (def integer? "integer?" 1)
    (def exact? "exact?" 1)
    (def real? "real?" 1)
    (def complex? "complex?" 1)
    (def inexact? "inexact?" 1)
    (def rational? "rational?" 1)
    (def zero? "zero?" 1)
    (def odd? "odd?" 1)
    (def even? "even?" 1)
    (def positive? "positive?" 1)
    (def negative? "negative?" 1)
    (def* max "max" 1)
    (def* min "min" 1)
    (def* + "+" 0)
    (def* - "-" 1)
    (def* * "*" 0)
    (def* / "/" 1)
    (def* = "=" 2)
    (def* > ">" 2)
    (def* < "<" 2)
    (def* >= ">=" 2)
    (def* <= "<=" 2)
    (def quotient "quotient" 2)
    (def remainder "remainder" 2)
    (def modulo "modulo" 2)
    (def gcd "gcd" 2)
    (def lcm "lcm" 2)
    (def abs "abs" 1)
    (def floor "floor" 1)
    (def ceiling "ceiling" 1)
    (def truncate "truncate" 1)
    (def round "round" 1)
    (def exact->inexact "exact->inexact" 1)
    (def inexact->exact "inexact->exact" 1)
    (def exp "exp" 1)
    (def log "log" 1)
    (def expt "expt" 2)
    (def sqrt "sqrt" 1)
    (def sin "sin" 1)
    (def cos "cos" 1)
    (def tan "tan" 1)
    (def asin "asin" 1)
    (def acos "acos" 1)
    (def* atan "atan" 1)
    (def numerator "numerator" 1)
    (def denominator "denominator" 1)
    (def magnitude "magnitude" 1)
    (def angle "angle" 1)
    (def make-rectangular "make-rectangular" 2)
    (def make-polar "make-polar" 2)
    (def real-part "real-part" 1)
    (def imag-part "imag-part" 1)
    (def rationalize "rationalize" 2)
    (def* number->string "number->string" 1)
    (def* string->number "string->number" 1)
    (def char? "char?" 1)
    (def char=? "char=?" 2)
    (def char>? "char>?" 2)
    (def char<? "char<?" 2)
    (def char>=? "char>=?" 2)
    (def char<=? "char<=?" 2)
    (def char-ci=? "char-ci=?" 1)
    (def char-ci<? "char-ci<?" 1)
    (def char-ci>? "char-ci>?" 1)
    (def char-ci>=? "char-ci>=?" 1) 
    (def char-ci<=? "char-ci<=?" 1)
    (def char-alphabetic? "char-alphabetic?" 1)
    (def char-whitespace? "char-whitespace?" 1)
    (def char-numeric? "char-numeric?" 1)
    (def char-upper-case? "char-upper-case?" 1)
    (def char-lower-case? "char-lower-case?" 1)
    (def char-upcase "char-upcase" 1)
    (def char-downcase "char-downcase" 1)
    (def char->integer "char->integer" 1)
    (def integer->char "integer->char" 1)
    (def string? "string?" 1)
    (def string=? "string=?" 2)
    (def string>? "string>?" 2)
    (def string<? "string<?" 2)
    (def string>=? "string>=?" 2)
    (def string<=? "string<=?" 2)
    (def string-ci=? "string-ci=?" 2)
    (def string-ci<? "string-ci<?" 2)
    (def string-ci>? "string-ci>?" 2)
    (def string-ci>=? "string-ci>=?" 2)
    (def string-ci<=? "string-ci<=?" 2)
    (def* make-string "make-string" 1)
    (def string-length "string-length" 1)
    (def string-ref "string-ref" 2)
    (def string-set! "string-set!" 3)
    (def* string-append "string-append" 1)
    (def string-copy "string-copy" 1)
    (def string->list "string->list" 1)
    (def list->string "list->string" 1)
    (def substring "substring" 3)
    (def (lambda (x y) (string-fill! x y) (%void)) "string-fill!" 2)
    (def (lambda (x)
	   (and (vector? x)
		(or (zero? (vector-length x))
		    (and (not (%procedure? x))
			 (not (%disjoint-type-instance? x))))))
	 "vector?" 1)
    (def* make-vector "make-vector" 1)
    (def vector-ref "vector-ref" 2)
    (def (lambda (x y z) (vector-set! x y z) (%void)) "vector-set!" 3)
    (def* string "string" 0)
    (def* vector '("vector" "%%vector") 0)
    (def vector-length "vector-length" 1)
    (def vector->list "vector->list" 1)
    (def list->vector '("list->vector" "%%list->vector") 1)
    (def (lambda (x y) (vector-fill! x y) (%void)) "vector-fill!" 2)
    (def %procedure? "procedure?" 1)
    (def* (lambda (proc . args)
	    (apply map (check-procedure proc "map") args))
      '("map" "%%map") 2)
    (def* (lambda (proc . args)
	    (apply for-each (check-procedure proc "for-each") args)
	    (%void))
      "for-each" 2)
    (def* (lambda (proc arg1 . args)
	    (apply apply (check-procedure proc "apply") (cons arg1 args)))
      "apply" 2)
    (def %force "force" 1)
    (def (lambda (proc)
	   (let ((proc (check-procedure proc "call-with-current-continuation")))
	     (call-with-current-continuation
	      (lambda (k) 
		(proc (%procedure k "[continuation]" -1))))))
	 "call-with-current-continuation" 1)
    (def (lambda (a b c)
	   (dynamic-wind
	       (check-procedure a "dynamic-wind")
	       (check-procedure b "dynamic-wind")
	       (check-procedure c "dynamic-wind")))
	 "dynamic-wind" 3)
    (def* values "values" 0)
    (def (lambda (a b)
	   (call-with-values
	       (check-procedure a "call-with-values")
	     (check-procedure b "call-with-values")))
	 "call-with-values" 2)
    (def input-port? "input-port?" 1)
    (def output-port? "output-port?" 1)
    (defp %input-port check-port "current-input-port")
    (defp %output-port check-port "current-output-port")
    (def (lambda (fname proc)
	   (%call-with-input-file 
	    fname
	    (check-procedure proc "call-with-input-file")))
	 "call-with-input-file" 2)
    (def (lambda (fname proc)
	   (%call-with-output-file 
	    fname
	    (check-procedure proc "call-with-output-file")))
	 "call-with-output-file" 2)
    (def %open-input-file "open-input-file" 1)
    (def %open-output-file "open-output-file" 1)
    (def close-input-port "close-input-port" 1)
    (def close-output-port "close-output-port" 1)
    (def* %read "read" 0)
    (def eof-object? "eof-object?" 1)
    (def* %read-char "read-char" 0)
    (def* %peek-char "peek-char" 0)
    (def* %write "write" 1)
    (def* %display "display" 1)
    (def* (undefd %write-char) "write-char" 1)
    (def* (undefd %newline) "newline" 0)
    (def (lambda (fname proc)
	   (%with-input-from-file
	    fname
	    (check-procedure proc "with-input-from-file")))
	 "with-input-from-file" 2)
    (def (lambda (fname proc)
	   (%with-output-to-file
	    fname
	    (check-procedure proc "with-output-to-file")))
	 "with-output-to-file" 2)
    (def* (lambda (expr . env)
	    (%eval expr (check-environment (optional env %interaction-environment) "eval")))
      "eval" 1)
    (def (lambda (r)
	   (check-report r "null-environment")
	   %null-environment/5)
	 "null-environment" 1)
    (def (lambda (r)
	   (check-report r "scheme-report-environment")
	   %scheme-report-environment/5)
	 "scheme-report-environment" 1)
    (defp %interaction-environment check-environment "interaction-environment")
    ;; internals
    (def %environment? "environment?" 1)
    (def* (lambda (env . args)
	    (let-optionals args ((name "UNNAMED") (mutable #t))
	      (%copy-environment (check-environment env "copy-environment") name mutable)))
      "copy-environment" 1)
    (def (lambda (thunk)
	   (%make-promise (check-procedure thunk "delay")))
	 "%make-promise" 1)
    (def %promise? "%%promise?" 1)
    (def (lambda (h thunk)
	   (%with-exception-handler
	    (check-procedure h "with-exception-handler")
	    (check-procedure thunk "with-exception-handler")))
	 "with-exception-handler" 2)
    (def %current-process-id "current-process-id" 0)
    ;; extensions
    (def (lambda (x) ;XXX not available in CHICKEN build (no "eval" unit)
	   (eval x (interaction-environment)))
	 "%%meta-eval" 1)
    (def* (lambda (fn . ev)
	    (apply
	     %load fn
	     (if (null? ev)
		 '()
		 (list (check-procedure (car ev) "load"))))
	    (%void))
      "load" 1)
    (def* %command-line-arguments "command-line-arguments" 0)
    (defp %error-port check-port "current-error-port")
    (def (lambda (x) (%delete-file x) (%void)) "delete-file" 1)
    (def %file-exists? "file-exists?" 1)
    (def* %current-directory "current-directory" 0)
    (def* %void "void" 0)
    (def* %exit "exit" 0)
    (def* (lambda evaluator
	    (let ((eval (if (pair? evaluator) (%procedure-code (car evaluator)) %eval))
		  (fs %features))
	      (dynamic-wind
       	  (lambda () (add-feature 'interactive))
		  (cut %repl eval)
		  (lambda () (remove-feature 'interactive)))))
      "repl" 0)
    (def* (lambda prompt
	    (if (null? prompt)
		(%procedure %repl-prompt "[repl prompt]" 1)
		(set! %repl-prompt (check-procedure (car prompt) "repl-prompt"))))
      "repl-prompt" 0)
    (def* (lambda args (apply %quit args)) "quit" 0)
    (def* (lambda port
	    (%flush-output (optional port %output-port)))
      "flush-output" 0)
    (def* (lambda (exp . env)
	    (%expand exp (check-environment (optional env %interaction-environment) "expand")))
      "expand" 1)
    (def %system "system" 1)
    (def %current-time "current-time" 0)
    (def %get-environment-variable "get-environment-variable" 1)
    (def* pp "pp" 1)
    (def* (lambda (fn . args)
	    (let ((eval (if (pair? args)
			    (%procedure-code (car args))
			    %eval)))
	      (load-program fn eval)))
      "load-program" 1)
    (defp *current-source-filename* check-string "current-source-filename")
    (def* (lambda env
	    (%oblist (check-environment (optional env %interaction-environment) "oblist")))
      "oblist" 0)
    (def* (lambda args
	    (call-with-values
		(lambda () (apply make-disjoint-type args))
	      (lambda (make pred data)
		(values 
		 (%procedure make "[constructor]" -1)
		 (%procedure pred "[predicate]" 1)
		 (%procedure data "[accessor]" 1)))))
      "make-disjoint-type" 0)
    (def* library-path "library-path" 0)
    (def %library "library" 1)
    (def* %case-sensitive "case-sensitive" 0)
    (def (lambda () *grass-version*) "grass-version" 0)
    (def* %error "error" 1)
    (def* (lambda arg 
	    (if (null? arg)
		%features
		(begin
		  (set! %features (car arg))
		  (regenerate-cond-expand %features))))
      "features" 0)))

(define %scheme-report-environment/5
  (%copy-environment %interaction-environment "scheme-report-environment/5" #f))

(define (add-feature f)
  (unless (memq f %features)
    (set! %features (cons f %features))
    (regenerate-cond-expand %features)))

(define (remove-feature f)
  (set! %features
    (let loop ((fs %features))
      (cond ((null? fs) '())
	    ((eq? f (car fs)) (cdr fs))
	    (else (cons (car fs) (loop (cdr fs)))))))
  (regenerate-cond-expand %features))

;; must be generated on the fly if features change
(define (regenerate-cond-expand features)
  (%expand
   `(define-syntax cond-expand
      (syntax-rules (and or not else ,@features)
	((cond-expand) (error "no matching \"cond-expand\" clause"))
	,@(map (lambda (f)
		 `((cond-expand (,f body ...) . more-clauses)
		   (begin body ...)))
	       features)
	((cond-expand (else body ...)) (begin body ...))
	((cond-expand ((and) body ...) more-clauses ...) (begin body ...))
	((cond-expand ((and req1 req2 ...) body ...) more-clauses ...)
	 (cond-expand
	   (req1 (cond-expand
		   ((and req2 ...) body ...)
		   more-clauses ...))
	   more-clauses ...))
	((cond-expand ((or) body ...) more-clauses ...) 
	 (cond-expand more-clauses ...))
	((cond-expand ((or req1 req2 ...) body ...) more-clauses ...)
	 (cond-expand
	   (req1 (begin body ...))
	   (else
	    (cond-expand
	      ((or req2 ...) body ...)
	      more-clauses ...))))
	((cond-expand ((not req) body ...) more-clauses ...)
	 (cond-expand
	   (req (cond-expand more-clauses ...))
	   (else body ...)))
	((cond-expand (feature-id body ...) more-clauses ...)
	 (cond-expand more-clauses ...))))))