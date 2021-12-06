(require '[clojure.string :as str])
(require '[clojure.edn :as edn])
(require '[clojure.math.numeric-tower :as math])

(defn nCr [n k]
  (let [a (inc n)]
    (loop [b 1
           c 1]
      (if (> b k)
        c
        (recur (inc b) (* (/ (- a b) b) c))))))

(declare f)
(defn part [t i q] (long (* (nCr q i) (f -1 (- t (* 7 q) (* 2 i))))))

(defn expand [t q] (long (reduce + (map (fn [i] (part t i q)) (range (+ q 1))))))

(defn f [n t] 
  (if (< t 0)
    (long 0)
    (if (>= n 0)
      (long (f -1 (- t n 1)))
      (if (>= t 18)
        (long (+
          (long (- (long (math/expt 2 (long (quot t 9)))) 1))
          (long (expand t (long (quot t 9))))
        ))
        (long (+ 
          (long 1)
          (long (f -1 (- t 7)))
          (long (f -1 (- t 9)))
        ))
      )
    )
  )
)

(defn r [n t] (long (+ (f n t) (long 1))))

(defn c [s] (long (r (long (edn/read-string s)) (long 256))))

(println (reduce + (map (fn [x] (long (c x))) (str/split (read-line) (re-pattern ",")))))