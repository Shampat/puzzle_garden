import json, random
symbols_list = [["🌸","🌷"],["🐦","🪺"],["🦋","🌼"],["🍄","🌿"],["🐝","🌻"]]
names = ["Flower","Bird","Butterfly","Mushroom","Bee"]
puzzles=[]
pid=1
for garden_idx, symbols in enumerate(symbols_list):
  s1,s2=symbols
  for diff in ["easy","medium","hard"]:
    for _ in range(7):
      base=[[s1,s2,s2,s1],[s2,s1,s1,s2],[s1,s2,s1,s2],[s2,s1,s2,s1]]
      random.shuffle(base)
      for r in base:
        if random.random()>0.5: r.reverse()
      puzzle=[row[:] for row in base]
      cells=[(r,c) for r in range(4) for c in range(4)]
      random.shuffle(cells)
      blank={"easy":6,"medium":8,"hard":10}[diff]
      for i in range(blank):
        r,c=cells[i]; puzzle[r][c]=""
      puzzles.append({"id":pid,"garden":garden_idx,"garden_name":names[garden_idx],"symbols":symbols,"difficulty":diff,"board":puzzle,"solution":base})
      pid+=1

with open("assets/puzzles.json","w",encoding="utf-8") as f:
  json.dump(puzzles,f,ensure_ascii=False,indent=2)
print(f"Generated {len(puzzles)}")
