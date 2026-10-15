import json, random
symbols_list = [["🌸","🌷"],["🐦","🪺"],["🦋","🌼"],["🍄","🌿"],["🐝","🌻"]]
names = ["Flower","Bird","Butterfly","Mushroom","Bee"]
world_names = ["Meadow", "Hill", "Peak"] # World 1,2,3 visual change
base_solutions = [
  [["A","A","B","B"],["A","B","A","B"],["B","A","B","A"],["B","B","A","A"]],
  [["A","B","B","A"],["B","A","A","B"],["A","B","A","B"],["B","A","B","A"]],
  [["A","B","A","B"],["B","A","B","A"],["A","A","B","B"],["B","B","A","A"]],
]
puzzles=[]
pid=1
for garden_idx, symbols in enumerate(symbols_list):
  s1,s2 = symbols
  for world in range(3): # 0=Meadow, 1=Hill, 2=Peak
    blanks_for_world = [ [3,3,4,4,4,5,5], [5,5,6,6,6,7,7], [7,7,8,8,8,8,8] ][world]
    diff_label = ["easy","medium","hard"][world]
    for i in range(7):
      base = random.choice(base_solutions)
      sol = [r[:] for r in base]
      random.shuffle(sol)
      real_sol = [[s1 if c=="A" else s2 for c in r] for r in sol]
      board = [r[:] for r in real_sol]
      cells = [(r,c) for r in range(4) for c in range(4)]
      random.shuffle(cells)
      target_blank = blanks_for_world[i]
      blanked=0
      for r,c in cells:
        if blanked>=target_blank: break
        if world==0 and sum(1 for x in board[r] if x!="")<=2: continue
        if world==1 and sum(1 for x in board[r] if x!="")<=1: continue
        board[r][c]=""
        blanked+=1
      puzzles.append({
        "id": pid, "garden": garden_idx, "garden_name": names[garden_idx],
        "world": world, "world_name": world_names[world],
        "symbols": symbols, "difficulty": diff_label,
        "level_in_world": i+1, "level_global": world*7 + i+1,
        "blanks": target_blank,
        "board": board, "solution": real_sol
      })
      pid+=1

with open("assets/puzzles.json","w",encoding="utf-8") as f:
  json.dump(puzzles,f,ensure_ascii=False,indent=2)

print(f"Generated {len(puzzles)} = 5 gardens x 3 worlds x 7 levels")
for w in range(3):
  print(f"World {w+1} {world_names[w]}: blanks { [ [3,3,4,4,4,5,5], [5,5,6,6,6,7,7], [7,7,8,8,8,8,8] ][w]}")
