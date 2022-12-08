∇ l←line r
  l←{⍎⍵}¨⍞
∇

M ← line¨⍳⍎⍞

∇ l←ac c ; x ; y
  x ← 1⌷c
  y ← 2⌷c
  l ← x⌷∊y⌷M
∇

rl ← {≢∊⍵⌷M}

∇ l←vs c ; x ; y ; h ; fxn ; fxp ; fyn ; fyp
  x ← 1⌷∊c
  y ← 2⌷∊c
  h ← ac(x y)
  fxn ← ∧/{h>ac(⍵ y)}¨⍳x-1
  fxp ← ∧/{h>ac(⍵ y)}¨x+⍳{rl y}-x
  fyn ← ∧/{h>ac(x ⍵)}¨⍳y-1
  fyp ← ∧/{h>ac(x ⍵)}¨y+⍳{≢M}-y
  l←∨/(fxn fxp fyn fyp)
∇

I ← ,{⍳ rl 1}∘.,{⍳≢M}

+/vs¨I
