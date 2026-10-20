from lib import write_json, say


def nurse(hello, heal, healed, ark, bye):
    return {"nurse": [
        say("Nurse", hello),
        {"do": "choice", "text": "What can we do for you?", "options": ["Heal my team", "Open the Ark", "Just looking"], "set": "_nurse_choice"},
        {"do": "if", "flag": "_nurse_choice", "eq": 0,
         "then": [say("Nurse", heal), {"do": "heal"}, say("Nurse", healed)],
         "else": [{"do": "if", "flag": "_nurse_choice", "eq": 1,
                   "then": [say("Nurse", ark), {"do": "ark"}],
                   "else": [say("Nurse", bye)]}]},
    ]}


write_json("data/dialogue/leeds_sanctuary.json", nurse(
    "Ey up, love! Welcome to Leeds Sanctuary. Pop your team on the counter. They look like they've walked over from Saddleworth.",
    "Sit yourself down. There's a brew in the pot and a curd tart on the side. Hands off the last slice, that's mine.",
    "There, champion. All patched up. Mind the buses on the Headrow, they don't stop for anyone, us included.",
    "The Ark's in the corner. Somebody's left a scarf on it. Leeds colours. Leave it, it's lucky.",
    "No bother. Off you go, and say hello to the lions for me."))
write_json("data/dialogue/haworth_sanctuary.json", nurse(
    "Now then, love! Welcome to Haworth Sanctuary. Up Main Street with a team in tow? Pop them on the counter, they've earned it.",
    "Have a sit by the fire. Tea's on, havercakes are warm, and the wind's doing its best impression of Emily's moor.",
    "There we are. Right as rain, which round here is most days. Hold the rail going down the setts.",
    "The Ark's by the window. Mind, if it makes a moaning noise, that's the draught. Probably.",
    "No bother, love. Mind how you go. And if you see a grey lady on Main Street, she's harmless."))
