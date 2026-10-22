import json,os
R=os.path.expanduser('~/Projects/wildlore/.claude/worktrees/w45-m-borders/')
WALK=set('.,#=:sfwD|+_&gkca')
ids=["la_linea","la_linea_levante","pyla","nicosia_south","nicosia_north","gibraltar","dhekelia"]
import glob
targets=set(ids)
for i in ids:
    for w in json.load(open(R+'data/zones/%s.json'%i))['warps']: targets.add(w['to'])
for t in sorted(targets):
    d=json.load(open(R+'data/zones/%s.json'%t))
    rows=d['rows']; leg=d.get('legend_extra',{})
    def walk(x,y):
        if not(0<=y<len(rows) and 0<=x<len(rows[0])): return False
        c=rows[y][x]
        if c in leg: return leg[c]['tile'] in ('grass','tall_grass','path','road','cobbles','sand','flowers','shallow')
        return c in '.,#=:sfwD|+_&'
    blocked=set()
    for p in d['props']:
        if p['type']!='building' and not p.get('walk'): blocked.add((p['x'],p['y']))
    occ={}
    for n in d['npcs']:
        k=(n['x'],n['y'])
        if not walk(*k): print(d['id'],'npc not walkable',n['id'],k)
        if k in blocked: print(d['id'],'npc on prop',n['id'],k)
        if k in occ: print(d['id'],'npc overlap',n['id'],occ[k])
        occ[k]=n['id']
    for s in d['signs']:
        k=(s['x'],s['y'])
        if k in occ: print(d['id'],'sign on npc',k)
        if k in blocked: print(d['id'],'sign on prop',k)
    for w in d['warps']:
        k=(w['x'],w['y'])
        if rows[w['y']][w['x']]!='D': print(d['id'],'warp not on door',k)
        if k in occ: print(d['id'],'npc on door')
    sp=tuple(d['spawn'])
    if not walk(*sp) or sp in occ or sp in blocked: print(d['id'],'bad spawn',sp)
    for p in d['props']:
        if p['type']!='building':
            k=(p['x'],p['y'])
            if rows[k[1]][k[0]]=='B' : print(d['id'],'prop in building',p)
print('ok')
