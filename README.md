# Exercise: The Website Log Report

Exercise code for the lesson **Exercise: The Website Log Report** in Bash in Depth on [ask-codey.com](https://www.ask-codey.com).

Bluebird Bakery's phone number has changed, and the owner wants a report on last week's website visits. Change the number on every page with `sed`, keeping a backup of each, save the five most visited pages with a pipeline, and answer five questions about the website's log and orders with `awk`, `sort` and `uniq`. A check script tells you what's done.

## Before you start

You need a terminal (the Terminal app on a Mac, Ubuntu on Linux or in WSL on Windows) and **bats**, the tool that runs the check. If `bats --version` doesn't print a version yet, install it:

```bash
sudo apt install bats       # Ubuntu, and Ubuntu in WSL
brew install bats-core      # a Mac, with Homebrew
```

## What's here

- `site/access.log`: a week of the bakery website's visits, one visit a line, in the usual web-server layout.
- `site/orders.csv`: the website's orders from September to November, with a header line.
- `site/pages/`: three of the website's pages, with the old phone number on them.
- `answers.txt`: five questions, each with a numbered line for your answer. For you to finish.
- `check.bats`: checks the pages, `top-pages.txt` and your answers. You don't need to change it.

## Run it

Open a terminal in this folder (the one with `answers.txt` in it), then look at the data's shape:

```bash
head -n 3 site/access.log
head -n 3 site/orders.csv
```

Then do the jobs:

1. **Change the phone number.** The bakery's number changed from `555-0142` to `555-0187`. Change it on every page in `site/pages/`, in place, keeping a `.bak` backup of each page.
2. **Save the top pages.** Write `top-pages.txt` in this folder: the five most visited pages in `site/access.log`, each with its count, biggest first, the way `uniq -c` and `sort -rn` print them.
3. **Answer the questions** in `answers.txt`, and save it (with nano, or any text editor).

## Check your work

From this folder:

```bash
bats check.bats
```

At first most checks fail: that is expected. Each job you finish turns its check into a ✓. A failing check's message says what to look at.

## The rules

- Change only the phone number on the pages, and keep one `.bak` file for each page.
- `top-pages.txt` holds exactly five lines, a count and a page on each.
- Write each answer on its numbered line, after the `)`, like the example: `0) 200`.

## Tips

- Run `sed` without `-i` first and read what it prints. Then run it again with `-i.bak`. If a page goes wrong, `mv` its `.bak` back over it.
- Without a `g` at the end, `s` changes only the first match on each line.
- Build every pipeline a stage at a time: start with `head -n 3`, add one stage, look, then add the next.
- In the log, the address is `$1`, the page `$7` and the status code `$9`. The orders need `awk -F,`, and their total is `$5`.
- `uniq -c` needs `sort` before it. `sort -rn` puts the biggest count first.

## Hand it in

When it works, push your solution to a public repo of your own on GitHub, then paste that repo's address into **Submit your exercise** on the lesson page at [ask-codey.com](https://www.ask-codey.com). That's what completes the lesson. The lesson page shows the Git commands, step by step.
