# Screenshots

Use these rules for an item whose problem shows on a screen. Examples are
a product screen, a mockup page, a rendered doc, and a terminal UI. A
marked picture shows the reader what the words describe. Then the reader
does not have to open the app to find the problem.

## When to give one

- A problem shows on a screen when a person who opens the screen in one
  state can see it. Examples are a layout, a colour, an overlap, a wrong
  text on a screen, and a missing state.
- Give the **Screenshot** field for each item whose problem shows on a
  screen. Give the picture also when the words describe the problem well.
- Leave the field out only when the problem does not show on a screen. A
  problem in code, a test, a log, or a doc source has a **Location**.
- A problem in the text of a doc, such as a wrong word or a wrong rule,
  has a **Location** only. A doc problem shows on a screen only when the
  rendered page shows it and the source does not. Examples are a broken
  list, table, link, or image.
- When the problem shows on a screen and you cannot take a picture, write
  `**Screenshot:** None, because <the reason>.` The reason names the
  blocker, such as no browser in the session or a screen that needs data
  that the session does not have. Then name the item under **Checks** in
  the final report, as the "Final report" section of the skill says.

## Who takes it

- The agent that sends the message takes the picture.
- A reviewer and a finding check are read-only. They do not take
  pictures. The reviewer gives a **Screenshot** line that names the
  screen, the state, and what to mark. The working agent takes the
  picture after the finding checks, for each confirmed finding whose
  problem shows on a screen. It does this also when the reviewer gave no
  line, and before it shows the findings to the user. Then it replaces
  the line in the findings file, or adds the field when the reviewer gave
  no line, as "Saved files" below says.

## Capture

1. Open the screen in the state that shows the problem. Use the branch as
   it is now.
2. Use only test or seed data. Do not capture a secret, a token, or
   personal data. Crop or cover it when the screen shows it.
3. Capture a PNG file. Use a screenshot tool of your session that writes a
   file, or headless Chrome:

   ```sh
   google-chrome --headless=new --window-size=1280,800 \
     --screenshot="$PWD/<folder>/raw-<number>.png" "<url>"
   ```

4. Use the mobile width of the screen when the problem shows only there.

## Mark

Mark only the problem. Use a box around the problem and a short label
next to it, such as `1: buttons overlap`. Do not change a source file,
a mockup, or the page to add a mark.

Draw the marks with ImageMagick. Use `magick` in place of `convert` when
only ImageMagick 7 is installed:

```sh
convert raw-<number>.png \
  -fill none -stroke red -strokewidth 3 -draw "rectangle <x1>,<y1> <x2>,<y2>" \
  -stroke none -fill red -pointsize 16 -annotate +<x>+<y> "<number>: <label>" \
  -crop <width>x<height>+<left>+<top> +repage <number>.png
```

- Read the coordinates from the PNG, not from the page. A screen with a
  pixel ratio of 2 gives a PNG at twice the size of the page.
- Crop the picture to the problem and enough of the screen around it to
  find the place.
- Keep the raw PNG. A new mark then needs no new capture.

## Check

Open the marked PNG and look at it before you send it. The box must
surround the problem, the label must be readable, and the picture must
show no secret. Fix and look again when one of these fails.

## Store

- For a review finding, save the picture as
  `screenshots/<number>.png` in the review folder of the branch. The
  `implementation-review` skill gives the review folder. Use the finding
  number.
- For another item, save it as
  `.context/<topic>/screenshots/<number>-<short name>.png`. Item numbers
  start again in each message, so the short name keeps an earlier picture.
- Do not commit a picture. The `.context/` folder is git-ignored.

## Link in a message

In a message to the user, give the picture in the **Screenshot** field in
three parts: one sentence that says what the picture shows and what the
box marks, the inline image, and a link to the file. Use the path from
the repository root in both links:

```markdown
- **Screenshot:** The Save and Cancel buttons overlap on the invoice form. The red box marks them.

  ![Item 1: the Save and Cancel buttons overlap](.context/reviews/<branch>/screenshots/1.png)

  [Open 1.png](.context/reviews/<branch>/screenshots/1.png)
```

The sentence must explain the problem without the picture.

## Saved files

A saved file gives the sentence and the path as text, with no image and
no link. Saved files are the findings file and the other notes under
`.context/`. A Markdown link in a saved file resolves from the folder of
that file, so a path from the repository root breaks there.

```markdown
- **Screenshot:** The Save and Cancel buttons overlap on the invoice form. The red box marks them. Picture: `.context/reviews/<branch>/screenshots/1.png`.
```

A plan, a follow-up item, a commit message, and a pull request
description give the sentence only. Git tracks them or GitHub shows them,
and neither can reach a file under `.context/`.

## Again

When you give an item again in a message, build the inline image and the
file link from the recorded path. Take a new picture when a commit changed
the screen or the code at the item's location since the last picture.

When an item whose problem shows on a screen has no picture, take the
picture now. This applies when the record has no **Screenshot** field,
and when it has `None, because` with a blocker that is gone. Record the
new path in the saved file of the item.
