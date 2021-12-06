(require '[clojure.string :as str])
(require '[clojure.edn :as edn])

(defn f [n t] (
  if (< t 0) 1 (
    if (>= n 0)
      (f (- n 1) (- t 1))
      (+
        (f 6 t)
        (f 8 t)
      )
  )
))

(defn c [s] (f (edn/read-string s) 80))

(println (reduce + (map c (str/split (read-line) (re-pattern ",")))))