;;;; dtype.scm - procedure types and disjoint user-defined types
;
; syntax.scm
; error


;; procedure wrapper

(define *procedure-tag* (list '*procedure*))

(define (%procedure proc name argc)
  (vector 
   *procedure-tag* proc 
   (cond ((string? name) name)
	 ((symbol? name) (symbol->string name))
	 ((not name) #f)
	 (else (%error "internal - bad procedure name" name)))
   argc))

(define (%procedure? x)
  (and (vector? x) 
       (= (vector-length x) 4)
       (eq? (vector-ref x 0) *procedure-tag*)))

(define (%procedure-code x) (vector-ref x 1))
(define (%procedure-name x) (vector-ref x 2))
(define (%procedure-arity x) (vector-ref x 3))


;; disjoint types

(define disjoint-type-tag (list 'object))

(define (%disjoint-type-instance? x)
  (and (vector? x)
       (= (vector-length x) 4)
       (eq? disjoint-type-tag (vector-ref x 0))))

(define (disjoint-type-instance->string x)
  (let ((name (vector-ref x 2)))
    (if name
	(string-append "#<" (symbol->string name) ">")
	"#<object>")))

(define make-disjoint-type
  (let ((id-counter 0))
    (define (dt-type-id x) (vector-ref x 1))
    (define (dt-type-name x) (vector-ref x 2))
    (define (dt-data x) (vector-ref x 3))
    (lambda name
      (let ((type-id id-counter)
	    (name (optional name #f)))
	(set! name
	  (cond ((not name) #f)
		((symbol? name) name)
		((string? name) (string->symbol name))
		(else (error "invalid type name" name))))
	(set! id-counter (+ id-counter 1))
	(let ((pred (lambda (x) 
		      (and (%disjoint-type-instance? x)
			   (eq? (dt-type-id x) type-id)))))
	  (values
	   (lambda data
	     (vector disjoint-type-tag type-id name (optional data #f)))
	   pred
	   (lambda (x)
	     (if (pred x)
		 (dt-data x)
		 (apply error "not an object of the correct type" x 
			(if name (list name) '()))))))))))


;; environment type

(define %%make-environment #f)
(define %environment? #f)
(define %environment-data #f)

(receive (make pred data) (make-disjoint-type 'environment)
  (set! %%make-environment make)
  (set! %environment? pred)
  (set! %environment-data data))

(define (%make-environment name oblist mstore mutable?)
  (%%make-environment (vector name oblist mstore mutable?)))

(define %environment-data-name (cut vector-ref <> 0))
(define %environment-data-oblist (cut vector-ref <> 1))
(define %environment-data-oblist-set! (cut vector-set! <> 1 <>))
(define %environment-data-mstore (cut vector-ref <> 2))
(define %environment-data-mstore-set! (cut vector-set! <> 2 <>))
(define %environment-data-mutable? (cut vector-ref <> 3))


;; port wrapping

(define %input-port #f)
(define %output-port #f)
(define %error-port #f)

(define (%initialize-ports in out err)
  (set! %input-port in)
  (set! %output-port out)
  (set! %error-port err))

(define (%call-with-input-file file proc)
  (let ((in (%open-input-file file)))
    (begin0 (proc in) (close-input-port in))))

(define (%call-with-output-file file proc)
  (let ((out (%open-output-file file)))
    (begin0 (proc out) (close-output-port out))))

(define (%with-input-from-file file thunk)
  (let ((in (%open-input-file file)))
    (fluid-let ((%input-port in))
      (begin0 (thunk) (close-input-port in)))))

(define (%with-output-to-file file thunk)
  (let ((out (%open-output-file file)))
    (fluid-let ((%output-port out))
      (begin0 (thunk) (close-output-port out)))))

(define (%with-ports i o e thunk)
  (fluid-let ((%input-port i)
	      (%output-port o)
	      (%error-port e))
    (thunk)))

(define (%read-char . port)
  (read-char (optional port %input-port)))

(define (%peek-char . port)
  (peek-char (optional port %input-port)))

(define (%write-char c . port)
  (write-char c (optional port %output-port)))

(define (%newline . port)
  (newline (optional port %output-port)))