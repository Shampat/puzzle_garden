import json, random

symbols_list = [["🌸","🌷"],["🐦","🪺"],["🦋","🌼"],["🍄","🌿"],["🐝","🌻"]]
names = ["Flower","Bird","Butterfly","Mushroom","Bee"]
world_names = ["Meadow","Hill","Peak"]

# Valid base solutions that satisfy all 3 Takuzu rules
base_4 = [
  [["A","A","B","B"],["B","B","A","A"],["A","B","A","B"],["B","A","B","A"]],
  [["A","B","A","B"],["B","A","B","A"],["A","A","B","B"],["B","B","A","A"]],
]
base_6 = [
  [
    ["A","A","B","A","B","B"],
    ["A","B","A","B","A","B"],
    ["B","A","B","A","B","A"],
    ["B","B","A","B","A","A"],
    ["A","B","B","A","A","B"],
    ["B","A","A","B","B","A"],
  ],
  [
    ["A","B","A","A","B","B"],
    ["B","A","B","B","A","A"],
    ["A","A","B","B","A","B"],
    ["B","B","A","A","B","A"],
    ["A","B","B","A","B","A"],
    ["B","A","A","B","A","B"],
  ]
]
base_5 = [
  [
    ["A","A","B","B","A"],
    ["B","B","A","A","B"],
    ["A","B","A","B","A"],
    ["B","A","B","A","B"],
    ["A","B","B","A","B"],
  ]
]

def shuffle_board(board):
  # shuffle rows and cols and optionally swap A/B
  b = [r[:] for r in board]
  random.shuffle(b)
  # transpose, shuffle, transpose
  b = [list(x) for x in zip(*b)]
  random.shuffle(b)
  b = [list(x) for x in zip(*b)]
  if random.random()>0.5:
    b = [["B" if c=="A" else "A" for c in r] for r in b]
  return b

def make_puzzle(size, symbols, blanks):
  s1,s2 = symbols
  if size==4: base = random.choice(base_4)
  elif size==5: base = random.choice(base_5)
  else: base = random.choice(base_6)
  sol = shuffle_board(base)
  real_sol = [[s1 if c=="A" else s2 for c in r] for r in sol]
  board = [r[:] for r in real_sol]
  cells = [(r,c) for r in range(size) for c in range(size)]
  random.shuffle(cells)
  blanked=0
  for r,c in cells:
    if blanked>=blanks: break
    board[r][c]=""
    blanked+=1
  return board, real_sol

puzzles=[]
pid=1
for garden_idx, symbols in enumerate(symbols_list):
  # Meadow 4x4: 7 levels, blanks 3->5
  for i in range(7):
    blanks = [3,3,4,4,4,5,5][i]
    board,sol = make_puzzle(4, symbols, blanks)
    puzzles.append({"id": pid, "garden": garden_idx, "garden_name": names[garden_idx], "world":0, "world_name":"Meadow", "size":4, "symbols":symbols, "difficulty":"easy", "level_in_world":i+1, "level_global":i+1, "blanks":blanks, "board":board, "solution":sol})
    pid+=1
  # Hill 5x5: blanks 6->9
  for i in range(7):
    blanks = [6,6,7,7,8,8,9][i]
    board,sol = make_puzzle(5, symbols, blanks)
    puzzles.append({"id": pid, "garden": garden_idx, "garden_name": names[garden_idx], "world":1, "world_name":"Hill", "size":5, "symbols":symbols, "difficulty":"medium", "level_in_world":i+1, "level_global":8+i, "blanks":blanks, "board":board, "solution":sol})
    pid+=1
  # Peak 6x6: blanks 10->14
  for i in range(7):
    blanks = [10,11,12,12,13,13,14][i]
    board,sol = make_puzzle(6, symbols, blanks)
    puzzles.append({"id": pid, "garden": garden_idx, "garden_name": names[garden_idx], "world":2, "world_name":"Peak", "size":6, "symbols":symbols, "difficulty":"hard", "level_in_world":i+1, "level_global":15+i, "blanks":blanks, "board":board, "solution":sol})
    pid+=1

with open("assets/puzzles.json","w",encoding="utf-8") as f:
  json.dump(puzzles,f,ensure_ascii=False,indent=2)
print(f"Generated {len(puzzles)} puzzles: 4x4 Meadow, 5x5 Hill, 6x6 Peak")
