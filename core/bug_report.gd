class_name BugReport
extends RefCounted
## Builds the pre-filled GitHub issue link for Settings > Report a bug. Pure: the screen opens it with OS.shell_open.

const REPO := "orchardroot/wildlore-these-isles"
const MAX_TEXT := 300

static func url(version: String, zone: String, platform: String, text: String) -> String:
	var said := text.strip_edges().replace("\n", " ").left(MAX_TEXT)
	var body := "**What happened**\n%s\n\n**Version:** %s\n**Where:** %s\n**Platform:** %s\n" % [said, version, zone, platform]
	return "https://github.com/%s/issues/new?labels=bug&title=%s&body=%s" % [REPO, "Bug report".uri_encode(), body.uri_encode()]
