; turtle agents
breed [trees tree]
breed [seeds seed]

; agent attributes
trees-own [tree-age resources root-depth ]
seeds-own [germinate]
patches-own [soil-age soil-depth depth-max elevation]

; global variables not set within gui
globals [
  tree-growth-a
  tree-growth-b
]

; setup world function
to setup
  clear-all
  setup-patches
  setup-trees
  setup-constants
  reset-ticks
end

; setup patches function
to setup-patches
  resize-world 0 79 0 79
  set-patch-size 5
  ;ask patches [ set pcolor 32 set soil-depth 0 set depth-max 0 set soil-age 0 set elevation ((2 / 37) * (37 - sqrt( (37 - pycor) ^ 2)))]
  ask patches [ set pcolor 32 set soil-depth 0 set depth-max 0 set soil-age 0 set elevation (79 - pycor) * 5 * 0.75 ]
end

; setup initial tree population function
to setup-trees
  create-trees initial-number-trees
  ask trees [ setxy random-xcor random-ycor set size 4 set shape "tree" set color lime set tree-age 1 set resources 1 set root-depth 0.0001]
end

; setup constants for tree growth function
to setup-constants
  set tree-growth-a  ( (-1) * tree-root-max ) / ( tree-age-max ^ 2)
  set tree-growth-b  (-2) * tree-growth-a * tree-age-max
end

; iterate procedure through time
to go
  if not any? trees [ stop ]
  if ticks > 5000 [stop]
  track-growth
  resource-availability
  trees-grow
  trees-seed
  seeds-spread
  seeds-germ
  trees-die
  patches-weather
  tick
end

; randomly pick a tree to track over the course of its life
to track-growth
  if not any? trees with [ color = red ][
    if any? trees with [ tree-age = 1][
      ask one-of trees with [ tree-age = 1 ] [set color red]
    ]
  ]
end

; calculate resource availability for each tree
to resource-availability
  ask trees[
    ifelse any? trees in-radius 5
      [set resources (root-depth / (sum [root-depth] of trees in-radius 5))]
      [set resources resources]
  ]
end

; tree growth function
to trees-grow
  ask trees[
    set tree-age tree-age + 1

    ; derivative of parabola with max tree-age = maximum and centered in time-step
    set root-depth root-depth + (resources * (( 2 * tree-growth-a * ( tree-age - 0.5 )) + tree-growth-b))

    ; reproductive age is 5% of lifespan
    if tree-age >= tree-age-max / 20 [
      if color = green [
        set color 53
      ]
    ]
  ]
end

; seed number function
to trees-seed
  ask trees[
    if tree-age >= tree-age-max / 20 [

      ; linear seed production with resource limitation
      hatch-seeds (seed-max * resources) [ set size 2 set shape "dot" set color white ]
    ]
  ]
end

; seed dispersal function
to seeds-spread
  ask seeds[
    right random 360
    forward random seed-disperse
    show seeds
  ]
end

; germination and sapling survivorship function
to seeds-germ
  ask seeds[
    set germinate random-float 1
    if germinate >= seed-fecundity [
      hatch-trees 1 [ set size 5 set shape "tree" set color green set tree-age 1 set resources 1 set root-depth 0.0001]
      die
    ]
    if germinate < seed-fecundity[
      die
    ]
  ]
end

; tree death function
to trees-die
  ask trees[
    if tree-age >= tree-age-max [
      die
    ]
  ]
end

; soil production function
to patches-weather
  ask patches[
    if soil-age >= 1[
      set soil-age soil-age + 1
    ]
  ]

  ask trees[
    if root-depth > soil-depth[
      if soil-depth = 0[
        set soil-age 1
      ]
      set soil-depth root-depth
      set depth-max soil-depth
      set pcolor yellow
    ]
  ]
end

; report all soil patches in grid
to-report soil
  report patches with [pcolor = yellow]
end

; report attibutes of randomly tracked tree for plotting
to-report single-tree
  report trees with [color = red]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
618
419
-1
-1
5.0
1
10
1
1
1
0
1
1
1
0
79
0
79
1
1
1
ticks
30.0

BUTTON
22
12
108
45
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
116
12
203
45
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
23
127
202
160
tree-age-max
tree-age-max
1
500
40.0
1
1
NIL
HORIZONTAL

SLIDER
23
88
202
121
tree-root-max
tree-root-max
0.1
3
3.0
0.1
1
NIL
HORIZONTAL

PLOT
629
299
903
419
Root Depth (m)
time (yrs)
depth (m)
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"mean" 1.0 0 -13840069 true "" "if any? trees [ plot mean [root-depth] of trees ]"
"max" 1.0 0 -8053223 true "" "if any? trees [ plot max [root-depth] of trees ]"

SLIDER
22
167
202
200
seed-disperse
seed-disperse
1
40
20.0
1
1
NIL
HORIZONTAL

PLOT
629
170
903
290
Density
time (yrs)
fraction
0.0
10.0
0.0
0.05
true
true
"" ""
PENS
"trees" 1.0 0 -13840069 true "" "plot count trees / (80 * 80)"
"soil" 1.0 0 -1184463 true "" "plot count soil / (80 * 80)"

PLOT
630
10
1184
158
Resource Availability (%)
time (yrs)
resources
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"mean" 1.0 0 -16777216 true "" "if any? trees [ plot mean [resources] of trees ]"

PLOT
913
169
1186
290
Soil Depth (m)
time (yrs)
depth (m)
0.0
10.0
0.0
0.2
true
true
"" ""
PENS
"all     " 1.0 0 -16777216 true "" "plot mean [soil-depth] of patches"
"soil" 1.0 0 -1184463 true "" "if any? soil [plot mean [soil-depth] of soil]"

SLIDER
22
210
202
243
seed-fecundity
seed-fecundity
0.970
0.999
0.985
0.001
1
NIL
HORIZONTAL

SLIDER
22
250
202
283
seed-max
seed-max
1
15
5.0
1
1
NIL
HORIZONTAL

PLOT
913
300
1186
421
The Red Tree
time (yrs)
depth (m)
0.0
3.0
0.0
0.002
true
true
"" ""
PENS
"Root depth" 1.0 0 -6459832 true "" "if any? single-tree [plot max[root-depth] of single-tree]"

SLIDER
23
50
202
83
initial-number-trees
initial-number-trees
1
20
4.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model explores how an individual-based model of forest dynamics can be linked to soil production. Rules for seed production and root growth are based on resource competition between neighbors. Soil is produced wherever tree roots reach the soil-bedrock interface. 

## HOW IT WORKS

This is simpler version of the model tree_soil_pro.

This model of forest dynamics is based on the notion that individual trees compete with their neighbors for resources (e.g., light, water, nutrients). Seeds are produced, saplings are  probabilistically recruited, roots grow, and individual trees die. If production and recruitment are too slow, then the population will go extinct. Unlike tree_soil_pro, all individuals live to their maximum lifespan. This means that forest density will grow until the recruitment rate is balanced by the death rate. The key attribute driving model dynamics is that each individual tree onl has fractional resources available (from 0 to 1) due to competition among neighbors. This RESOURCES term assumes size-symmetric resource allocation within a 5-patch radius. In general, individual trees grow fastest when they are young and slow down as the age. This model uses a parabolic growth function that is scales by resource availability. Reseource availability is also used to modulate the number of seed produced by individuals of reproductive age (5% of lifespan). To directly increase the probability of seed germination and sapling recruitment, the user can vary two terms that represent the maximum number of seed produced and a probability of survival. Because most seeds to not germinate and survive, and there is a cost to generating large numbers of agents that are destined to die, these numbers should not be directly compared to actual seed production rates. 

## HOW TO USE IT

To run the model using default parameters, first press SETUP to initialize the model and press GO to start the simulation. Each model tick is intended to represent 1 year. 

There are six parameters the user can explore using the sliders:
INITIAL-NUMBER-TREES randomly places trees of age 1 into the model domain.

TREE-ROOT-MAX sets the maximum rooting depth an individual tree can obtain if it grows its entire life with a resource availability of 1.

TREE-AGE-MAX sets the lifespan of each individual tree in years. Note that, in alternative versions of this model, trees can die before they reach this age.

SEED-DISPERSE sets the radius of seed dispersal in units of patches.   

SEED-FECUNDITY sets the probability of seed germination and sapling recruitment and varies from 0 to 1. The actual probability of recruitment is the complement of this value. In other words, lower values lead to higher recruitment rates.

SEED-MAX set the number of 'seeds' produced by a tree of reproductive age when full resources are available. When resource vailability is less than 1, the actual number of seeds will be probabilistically set to an integer value less than this parameter.  

Each of these parameters is set using the sliders in the interface tab.


## QUESTIONS TO ASK

Does the forest achieve any sort of equilibrium? If so, how fast does it achieve this state? If not, why not?

Does the soil achieve any sort of equilibrium? If so, how fast does it achieve this state? If not, why not?

Which parameters values favor higher average resource availability? How is this related to forest and soil properties

What dynamics is this model missing?


## CREDITS AND REFERENCES

https://github.com/mwrossi/Netlogo-Landlab-clinic
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
