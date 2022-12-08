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

∇ l←sc c ; x ; y ; h ; fxn ; fxp ; fyn ; fyp
  x ← 1⌷∊c
  y ← 2⌷∊c
  h ← ac(x y)
  fxn ← {{h>ac(⍵ y)}¨⌽1+⍳x-2}⍳0
  fxp ← {{h>ac(⍵ y)}¨x+⍳{rl y}-x+1}⍳0
  fyn ← {{h>ac(x ⍵)}¨⌽1+⍳y-2}⍳0
  fyp ← {{h>ac(x ⍵)}¨y+⍳{≢M}-y+1}⍳0
  l←×/(fxn fxp fyn fyp)
∇

I ← ,{1+⍳{rl 1}-2}∘.,{1+⍳{≢M}-2}

⌈/sc¨I
