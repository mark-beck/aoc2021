#lang racket

(define (parse-file filepath)
    (let* ([contents (file->string filepath)]
           [contents (string-trim contents)]
           [contents (string-split contents ",")])
    (map (lambda (e) (string->number e)) contents)))

(define (compute-fuel list target)
    (foldl (lambda (e acc) (+ acc (abs (- target e)))) 0 list))

(define (compute-fuel2 list target)
    (foldl (lambda (e acc) (+ acc (for/sum ([x (in-inclusive-range 0 (abs (- target e)))]) x))) 0 list))

(define (create-range list)
    (let ([mi (apply min list)]
        [ma (apply max list)])
        (in-inclusive-range mi ma)))

(define (tran range list)
    (map (lambda (e) (cons (compute-fuel list e) e)) (sequence->list range)))

(define (tran2 range list)
    (map (lambda (e) (cons (compute-fuel2 list e) e)) (sequence->list range)))

(define (pick-min list)
    (foldl (lambda (e acc) (if (< (car e) (car acc)) e acc )) (cons +inf.0 0) list))

(define (solve-file file-path)
  (printf "Input file: ~a\n" file-path)
  (let*([list (parse-file file-path)])
  (printf "part1: ~v~n" (pick-min (tran (create-range list) list)))
  (printf "part2: ~v~n" (pick-min (tran2 (create-range list) list)))))

(for ([arg (current-command-line-arguments)])
  (solve-file arg))
