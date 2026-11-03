#!/usr/bin/env bash
# List the follow-up items under plans/follow-ups/, highest priority score
# first. The score, from 0 to 10, adds the points of the grades of an item.
# "The priority score" in references/follow-up-items.md gives the points.
# Items with the same score list High severity first, then by path. A "?"
# after a score marks a missing grade. The last line gives the number of
# open items. Under each item, list dependencies, reverse links, the whole
# do-with group, and names with no open item. Read links from the first list
# after the title. Links do not change the order.
# Usage: follow-ups.sh [plans-dir]   (default: ./plans)
set -euo pipefail
dir="${1:-plans}"
dir="${dir%/}"
if [[ ! -d "$dir" ]]; then
  echo "no plans directory at $dir" >&2
  exit 1
fi
shopt -s nullglob
items=("$dir"/follow-ups/*.md)
if (( ${#items[@]} == 0 )); then
  echo "no follow-up items"
  exit 0
fi

# score_item <file>: print the score, severity rank, path, missing-grade
# mark, depends-on names, do-with names, and listing line, separated by tabs.
score_item() {
  LC_ALL=C awk '
    # grade(label): the first word after the label, as "High" in
    # "**Severity:** High (estimate). **Effort:** Small."
    function grade(label,   t) {
      t = text[label]
      sub(/^ +/, "", t)
      return match(t, /^[A-Za-z]+/) ? substr(t, 1, RLENGTH) : ""
    }
    # points(label, scale, fallback): the points of the grade on a scale such
    # as "Yes 2 No 0". A missing grade gets the fallback and marks the item.
    function points(label, scale, fallback,   part, i) {
      split(scale, part, " ")
      for (i = 1; i in part; i += 2) if (part[i] == grade(label)) return part[i + 1]
      marked = 1
      return fallback
    }
    # names(t): read bare file names from paths, Markdown links, or prose.
    # A name can end a sentence, as in "a.md.", so drop the trailing dots.
    function names(t,   part, j, result, before, target) {
      while (match(t, /\[[^]]*\]\([[:space:]]*[^[:space:])]+([[:space:]]+"[^"]*")?[[:space:]]*\)/)) {
        before = substr(t, 1, RSTART - 1)
        target = substr(t, RSTART, RLENGTH)
        t = substr(t, RSTART + RLENGTH)
        sub(/^\[[^]]*\]\([[:space:]]*/, "", target)
        sub(/[[:space:])].*$/, "", target)
        t = before " " target " " t
      }
      gsub(/[^A-Za-z0-9._-]+/, " ", t)
      split(t, part, " ")
      for (j = 1; j in part; j++) {
        sub(/[.]+$/, "", part[j])
        if (part[j] ~ /[.]md$/) result = result (result == "" ? "" : " ") part[j]
      }
      return result
    }
    # Bold labels divide the text. Only link fields keep their text.
    function link_fields(t,   label) {
      while (match(t, /\*\*[^*]+:\*\*/)) {
        if (field != "") text[field] = text[field] " " substr(t, 1, RSTART - 1)
        label = substr(t, RSTART + 2, RLENGTH - 5)
        t = substr(t, RSTART + RLENGTH)
        field = (label == "Depends on" || label == "Do with") ? label : ""
      }
      if (field != "") text[field] = text[field] " " t
    }
    BEGIN { split("Severity|Likelihood|Effort|Confidence|Harder later|Kind", labels, "|") }
    !has_title && sub(/^# /, "") { title = $0; has_title = 1; next }
    {
      if (has_title && !list_done) {
        if ($0 ~ /^- /) {
          in_list = 1
          field = ""
          link_fields($0)
        } else if (in_list && $0 ~ /^[[:space:]]*$/) list_done = 1
        else if (in_list && field != "" && $0 ~ /^[ \t]/) link_fields($0)
        else field = ""
      }
      # Keep the first match in the file for each grade label and Kind.
      for (i in labels) {
        at = index($0, "**" labels[i] ":** ")
        if (at && !(labels[i] in text)) text[labels[i]] = substr($0, at + length(labels[i]) + 6)
      }
    }
    END {
      severity = grade("Severity")
      rank = severity == "High" ? 1 : severity == "Medium" ? 2 : severity == "Low" ? 3 : 4
      if (rank == 4) severity = "Unknown"
      score = points("Severity", "High 4 Medium 2 Low 0", 2)
      if (grade("Likelihood") == "Rare") score /= 2
      score += points("Effort", "Small 2 Medium 1 Large 0", 1)
      score += points("Confidence", "High 2 Medium 1 Low 0", 1)
      score += points("Harder later", "Yes 2 No 0", 0)
      kind = text["Kind"]
      sub(/\..*/, "", kind)
      printf "%d\t%d\t%s\t%d\t%s\t%s\t%2d/10%-2s%-8s%s  %s  [%s]\n", score, rank, FILENAME, marked,
        names(text["Depends on"]), names(text["Do with"]),
        score, (marked ? "?" : ""), severity, FILENAME, (title == "" ? "No title" : title),
        (kind == "" ? "No kind" : kind)
    }
  ' "$1"
}

tab="$(printf '\t')"
listing="$(for item in "${items[@]}"; do score_item "$item"; done \
  | LC_ALL=C sort -t "$tab" -k1,1nr -k2,2n -k3,3)"
printf '%s\n' "$listing" | LC_ALL=C awk -F "$tab" '
  # Each open item starts its own do-with group. Join only open items.
  function root(name) {
    while (parent[name] != name) name = parent[name]
    return name
  }
  function read_links(item, text, kind,   part, i, other) {
    split(text, part, " ")
    for (i in part) {
      other = part[i]
      if (other == item) continue
      names[other] = 1
      if (!(other in parent)) link["no such item", item, other] = 1
      else if (kind == "depends on") {
        link[kind, item, other] = 1
        link["needed by", other, item] = 1
      } else parent[root(other)] = root(item)
    }
  }
  function print_links(kind, item,   i, other, result) {
    for (i = 1; i <= total; i++) {
      other = ordered[i]
      if (kind == "do with" ? (other in parent && other != item && root(other) == root(item)) \
          : ((kind, item, other) in link))
        result = result (result == "" ? "" : ", ") other
    }
    if (result != "") printf "%15s%s: %s\n", "", kind, result
  }
  {
    name = part[split($3, part, "/")]
    item[++count] = name
    parent[name] = name
    names[name] = 1
    depends[name] = $5
    together[name] = $6
    line[count] = $0
    for (i = 1; i <= 6; i++) sub(/^[^\t]*\t/, "", line[count])
  }
  END {
    for (name in parent) {
      read_links(name, depends[name], "depends on")
      read_links(name, together[name], "do with")
    }
    # POSIX awk has no array sort. Insert names in C-locale order.
    for (name in names) {
      i = ++total
      while (i > 1 && ordered[i - 1] > name) {
        ordered[i] = ordered[i - 1]
        i--
      }
      ordered[i] = name
    }
    for (i = 1; i <= count; i++) {
      print line[i]
      print_links("depends on", item[i])
      print_links("needed by", item[i])
      print_links("do with", item[i])
      print_links("no such item", item[i])
    }
  }
'
if [[ "$(printf '%s\n' "$listing" | cut -f4)" == *1* ]]; then
  echo "? marks a score that uses a default for a missing grade."
fi
echo "open follow-up items: ${#items[@]}"
