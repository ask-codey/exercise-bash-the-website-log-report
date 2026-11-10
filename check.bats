#!/usr/bin/env bats
# Checks the website's pages, top-pages.txt and your answers in answers.txt.
# Answers are worked out from the site's own files, so this file never holds them.
# Run it from this folder with:  bats check.bats
# You don't need to change this file.

setup() {
  cd "$BATS_TEST_DIRNAME"
}

OLD='555-0142'
NEW='555-0187'

# The answer written after "N)" in answers.txt, without spaces or quotes at either end.
answer() {
  grep -E "^$1\)" answers.txt | head -n 1 | sed -E "s/^$1\)[[:space:]]*//; s/[[:space:]]+\$//; s/^[\"']//; s/[\"']\$//"
}

# Fails with a message when question N has no answer yet.
need() {
  if [[ -z "$(answer "$1")" ]]; then
    echo "Question $1 has no answer yet. Write it after \"$1)\" in answers.txt."
    return 1
  fi
}

# Every line with its spaces squeezed to one, and none at either end, so columns line up the same way.
squeeze() {
  awk '{ $1 = $1; print }'
}

@test "the site folder is still here" {
  for f in site/access.log site/orders.csv site/pages/home.html site/pages/menu.html site/pages/contact.html; do
    if [[ ! -s "$f" ]]; then
      echo "$f is missing or empty. Download the exercise again to get it back."
      return 1
    fi
  done
}

@test "every page has the new phone number, and none has the old one" {
  for page in site/pages/*.html; do
    if grep -q "$OLD" "$page" && grep -q "$NEW" "$page"; then
      echo "$page still has the old number, $OLD, on this line: $(grep -m 1 "$OLD" "$page"). Is there a g at the end of your s command? Without it, sed changes only the first match on each line."
      return 1
    fi
    if grep -q "$OLD" "$page"; then
      echo "$page still has the old number, $OLD. Change it to $NEW with sed's s command: try it without -i first and read what it prints, then run it with -i.bak."
      return 1
    fi
    if ! grep -q "$NEW" "$page"; then
      echo "$page doesn't have the new number, $NEW. Try sed 's/$OLD/$NEW/g' on the pages without -i first, and read what it prints."
      return 1
    fi
  done
}

@test "each page kept a .bak backup with the old number" {
  for page in site/pages/*.html; do
    if [[ ! -f "$page.bak" ]]; then
      echo "There's no $page.bak. Change the pages with sed -i.bak, so each page keeps its old version as a backup."
      return 1
    fi
    if ! grep -q "$OLD" "$page.bak"; then
      echo "$page.bak doesn't have the old number, $OLD, in it, so it isn't the page as it was. Download the exercise again to get the old pages back, then run sed -i.bak once."
      return 1
    fi
  done
}

@test "only the phone number changed on each page" {
  for page in site/pages/*.html; do
    if [[ ! -f "$page.bak" ]]; then
      echo "There's no $page.bak to compare $page with. Change the pages with sed -i.bak."
      return 1
    fi
    if [[ "$(sed "s/$OLD/$NEW/g" "$page.bak")" != "$(cat "$page")" ]]; then
      echo "$page has changed in more places than the phone number. Put the backup back with mv $page.bak $page, then change only the number."
      return 1
    fi
  done
}

@test "top-pages.txt holds the five most visited pages, biggest first" {
  if [[ ! -f top-pages.txt ]]; then
    echo "There's no top-pages.txt in this folder yet. Build the pipeline a stage at a time, then save its answer with > top-pages.txt at the end."
    return 1
  fi
  want="$(awk '{ print $7 }' site/access.log | sort | uniq -c | sort -rn | head -n 5 | squeeze)"
  got="$(squeeze < top-pages.txt)"
  if [[ "$got" != "$want" ]]; then
    lines="$(grep -c . top-pages.txt || true)"
    if [[ "$lines" != 5 ]]; then
      echo "top-pages.txt has $lines lines; it needs exactly 5: a count and a page on each. Is head -n 5 the last stage?"
    else
      echo "top-pages.txt has 5 lines, but not the five most visited pages, each with its count, biggest first. The page is the seventh field (\$7); uniq -c needs sort before it, and sort -rn after it puts the biggest count first."
    fi
    return 1
  fi
}

@test "1) how many visits got a 404" {
  need 1
  want="$(awk '$9 == 404' site/access.log | wc -l | tr -cd '0-9')"
  got="$(answer 1 | tr -cd '0-9')"
  if [[ "$got" != "$want" ]]; then
    echo "Question 1: \"$(answer 1)\" isn't it yet. The status code is the ninth field: awk '\$9 == 404' keeps those visits, and wc -l counts lines."
    return 1
  fi
}

@test "2) the page visited most" {
  need 2
  want="$(awk '{ print $7 }' site/access.log | sort | uniq -c | sort -rn | head -n 1 | awk '{ print $2 }')"
  got="$(answer 2)"
  if [[ "$got" != "$want" && "/$got" != "$want" ]]; then
    echo "Question 2: \"$got\" isn't it yet. Your top-pages.txt pipeline, with head -n 1 at the end, shows the page visited most."
    return 1
  fi
}

@test "3) the address that failed to log in most often" {
  need 3
  want="$(awk '$7 == "/login" && $9 == 401 { print $1 }' site/access.log | sort | uniq -c | sort -rn | head -n 1 | awk '{ print $2 }')"
  got="$(answer 3)"
  if [[ "$got" != "$want" ]]; then
    echo "Question 3: \"$got\" isn't it yet. Keep the lines where the page (\$7) is /login and the status (\$9) is 401, print the address (\$1), then count each address."
    return 1
  fi
}

@test "4) the day with the most visits" {
  need 4
  want="$(awk '{ print substr($4, 2, 11) }' site/access.log | sort | uniq -c | sort -rn | head -n 1 | awk '{ print $2 }')"
  got="$(answer 4)"
  if [[ "$got" != "$want" ]]; then
    echo "Question 4: \"$got\" isn't it yet. The date is inside the fourth field, after the [: cut -d'[' -f2 | cut -d: -f1, or awk's substr(\$4, 2, 11), gives it on its own. Then count each day."
    return 1
  fi
}

@test "5) the total sales in October" {
  need 5
  want="$(awk -F, '$1 ~ /^2026-10/ { total += $5 } END { printf "%.2f", total }' site/orders.csv)"
  got="$(answer 5 | tr -d '$ ')"
  if [[ "$got" != "$want" && "${got}0" != "$want" ]]; then
    echo "Question 5: \"$(answer 5)\" isn't it yet. The orders are a CSV, so awk needs -F, and the total is the fifth field. The sales-per-month line from Columns and Totals: awk prints every month's total; October is 2026-10."
    return 1
  fi
}
