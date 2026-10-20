class_name FieldbookGoals
extends RefCounted
## Fieldbook milestones (Professor Garside's rewards at 25, 50, 100, 150 and 200 caught, each once, flag
## fieldbook_<n>) and region stamps (every species found in a region caught). The rewards themselves are in
## her dialogue (data/dialogue/macc_fieldstation.json); this says what is due. No autoload names here.

const MILESTONES := [25, 50, 100, 150, 200]
const NEWS_PREFIX := "region_news_"   # Garside has heard that this region is complete

## Friendly names for the zone regions.
const REGION_NAMES := {
	"cheshire": "Cheshire", "peak": "The Peak", "manchester": "Manchester", "merseyside": "Merseyside",
	"north_wales": "North Wales", "mid_wales": "Mid Wales", "south_wales": "South Wales",
	"south_england": "The West Country", "cornwall": "Cornwall", "midlands": "Midlands and London",
	"yorkshire": "Yorkshire", "cumbria": "Cumbria and Lancashire", "lancashire": "The Lancashire Coast", "north_east": "The North East",
	"scotland": "Scotland", "man": "Isle of Man", "ireland": "Ireland", "ireland_west": "The West of Ireland",
	"ireland_east": "The Boyne Valley",
	"east_anglia": "East Anglia",
	"south_east": "The South East",
	"overseas_bermuda": "Bermuda", "overseas_cayman": "The Cayman Islands", "overseas_turks_caicos": "Turks and Caicos",
	"overseas_bvi": "The British Virgin Islands", "overseas_anguilla": "Anguilla", "overseas_montserrat": "Montserrat",
}

static func region_name(r: String) -> String:
	return str(REGION_NAMES.get(r, r.capitalize()))

static func milestone_flag(n: int) -> String:
	return "fieldbook_%d" % n

## The 200 reward is the diploma, given by the older "Show Garside the Fieldbook" dialogue under its own flag.
static func collected(data: GameStateData, n: int) -> bool:
	if data.flag(milestone_flag(n)) == true:
		return true
	return n == 200 and data.flag("fieldbook_diploma_given") == true

## Catches that count towards the milestones: the Fieldbook proper, not the appendix (see Dex.in_appendix).
static func caught_count(data: GameStateData) -> int:
	return Dex.core_count(data.caught)

## The lowest milestone reached but not yet collected from Garside, or 0.
static func pending(data: GameStateData) -> int:
	for n in MILESTONES:
		if caught_count(data) >= n and not collected(data, n):
			return n
	return 0

## The next milestone not yet reached, or 0 when they all are.
static func next_goal(data: GameStateData) -> int:
	for n in MILESTONES:
		if caught_count(data) < n:
			return n
	return 0

## A line for "Where next?": a reward waiting, or how far to the next one; "" when there's nothing left.
static func hint(data: GameStateData) -> String:
	var p := pending(data)
	if p == 200:
		return "You've caught all 200! Show Professor Garside the Fieldbook."
	if p > 0:
		return "Professor Garside has something for you at the Field Station: you've caught %d." % p
	var n := next_goal(data)
	if n > 0:
		return "Catch %d more for Professor Garside's next Fieldbook reward, at %d caught (%d so far)." % [n - caught_count(data), n, caught_count(data)]
	return ""

## [{region, name, caught, total, complete}] for every region with wild creatures, in a stable order
## (REGION_NAMES order, then any others alphabetically).
static func region_progress(data: GameStateData, idx: Dictionary) -> Array:
	var regs: Array = idx.get("region_species", {}).keys()
	var order := REGION_NAMES.keys()
	regs.sort_custom(func(a, b):
		var ia := order.find(a)
		var ib := order.find(b)
		if ia == -1 and ib == -1:
			return a < b
		if ia == -1 or ib == -1:
			return ia != -1
		return ia < ib)
	var out := []
	for r in regs:
		var sp: Array = idx.region_species[r].filter(func(s): return not Dex.in_appendix(s))  # bonus species don't hold a stamp back
		var got := sp.filter(func(s): return data.caught.has(s)).size()
		out.append({"region": r, "name": region_name(r), "caught": got, "total": sp.size(), "complete": sp.size() > 0 and got >= sp.size()})
	return out

static func complete_regions(data: GameStateData, idx: Dictionary) -> Array:
	return region_progress(data, idx).filter(func(p): return p.complete).map(func(p): return p.region)

## Regions complete that Garside hasn't heard about yet.
static func untold_regions(data: GameStateData, idx: Dictionary) -> Array:
	return complete_regions(data, idx).filter(func(r): return data.flag(NEWS_PREFIX + r) != true)
