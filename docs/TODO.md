# Psychic Love 2D — To-Do List

Items are grouped by system and roughly ordered by dependency (earlier items tend to unblock later ones). Items marked with `[suggestion]` are recommendations based on reviewing the design and codebase — not from the original notes.

---

## Code Cleanup (do first — prevents bugs from accumulating)

- [ ] Remove debug `print` from `helpers/animations.lua:13`
- [ ] Remove debug `print` from `helpers/env.lua:15`
- [ ] Fix duplicate collision box definition in `classes/player.lua` — define offsets once in `config.lua` and reference them in both `init` and `update` (`player.lua:99` has a TODO for this)
- [ ] Make grid line rendering in `classes/map.lua` toggleable via a config flag instead of always-on
- [ ] `[suggestion]` Centralize asset paths — avoid magic strings like `"assets/sprites/player/walk_S.png"` scattered across files; a single `assets.lua` lookup table makes renames painless

---

## Game State Machine

- [ ] Define all top-level game states: `shop_floor`, `encounter`, `spread_reading`, `end_of_day`, `shop_upgrade`
- [ ] Build a simple state manager (a table of `{ enter, update, draw, keypressed }` per state, with a switch function)
- [ ] Wire `main.lua` to delegate `update`, `draw`, and `keypressed` to the active state
- [ ] `[suggestion]` Start with just two states (`shop_floor` and `encounter`) and stub the rest — this gives you a runnable loop to test against immediately rather than building all states up front

---

## Card System

- [ ] Define `Card` module with the agreed data schema (name, description, stats, ambiguity, modifiers)
- [ ] Implement modifier resolution logic — iterate modifiers in placement order, apply conditions (`adjacent`, `onPlacement`, `spreadType`)
- [ ] Implement spread resolution — aggregate raw stats from all cards, then apply modifiers, return a final fortune state
- [ ] Write Lua table definitions for all 15 starter cards from the brainstorm
- [ ] `[suggestion]` Keep Clarity as a separate internal stat (not a customer desire) — it should scale how precisely the fortune communicates whatever stats it has, rather than being something customers "want." This distinction makes the ambiguity tolerance system more interesting
- [ ] `[suggestion]` Consider adding a `cost` field to cards now even if you don't use it yet — retrofitting a cost system onto existing cards later is annoying

---

## Deck System

- [ ] Define `Deck` module: a list of card tables with shuffle, draw, and discard functions
- [ ] Implement draw mechanic: draw N cards from shuffled deck into a hand table
- [ ] Handle deck exhaustion (reshuffle discard, or just stop — decide which)
- [ ] `[suggestion]` Start with a hand size of 5 and 3 spread slots — it gives enough choice without overwhelming the player, and you can tune it without touching core logic

---

## Spread / Reading UI

- [ ] Design the layout: hand display at the bottom, 3 spread slots in the center (on the table)
- [ ] Implement card selection and slot placement (keyboard-first is easier to start; mouse/click can come later)
- [ ] Render placed cards in spread slots with stat summaries visible
- [ ] Trigger spread resolution on player confirmation (dedicated key or "Read" button)
- [ ] Display resolved fortune state (total stats) to player after resolution
- [ ] `[suggestion]` Show a simple "reading quality" indicator (e.g., a match score against the customer's known desire signals) rather than hiding all feedback until the customer reacts — gives the player something to respond to and makes the system feel legible

---

## Customer / Dialogue System

- [ ] Define `Customer` module with the agreed schema (name, relationship level, per-day encounter data)
- [ ] Write "Lady" encounter data — she has a portrait and sprite already, so she should be first
- [ ] Build dialogue display system: portrait render + text box with keypress advance
- [ ] Implement pre-reading dialogue (delivers clues about desires and tone)
- [ ] Implement post-reading dialogue (branches on positive/neutral/negative outcome)
- [ ] Implement outcome calculation: compare fortune state stats to customer's primary and secondary desires + ambiguity tolerance
- [ ] Implement relationship score tracking
- [ ] Implement relationship threshold detection and unlock trigger (even if unlocks are just placeholder text for now)
- [ ] `[suggestion]` Give each customer a visible "mood indicator" during the spread phase (not a desire spoiler, just a feeling — "She seems hopeful" or "He looks nervous") — reinforces the reading-as-performance fantasy without giving away the answer

---

## Day Loop

- [ ] Implement a day structure: customer queue is assembled at day start, encounters run in sequence, end-of-day triggers after last encounter
- [ ] **Decide: pre-determined vs. random vs. hybrid customer scheduling.** Recommendation: pre-determined per-day schedule for the first playable build (fully controllable for testing, no randomness to debug), add hybrid scheduling once the encounter loop is stable
- [ ] Build end-of-day summary screen: relationships changed, rewards earned, deck state
- [ ] **Decide: end game condition.** Options to consider:
  - Fixed number of days (simplest, finite arc)
  - Reach max relationship with all main characters
  - Accumulate enough reputation/wealth
  - A hybrid: fixed days with a "true ending" unlocked by relationship thresholds
- [ ] `[suggestion]` Even if the end game is TBD, wire a placeholder "Game Over / Thanks for playing" screen now — it prevents the day loop from being structurally open-ended during development

---

## Shop / Progression

- [ ] Define shop upgrade categories (gameplay effects, card access, cosmetic)
- [ ] Build shop screen UI (end-of-day purchase menu)
- [ ] Implement currency system (earned from encounters based on outcome quality)
- [ ] Implement card acquisition flow (reward selection or direct purchase)
- [ ] Implement card removal (let the player prune their deck between days)
- [ ] `[suggestion]` Design 3–4 shop upgrades before implementing the shop screen — having real content makes it much easier to design the UI than designing the UI in the abstract first

---

## Content

- [ ] Design 3–5 additional character archetypes beyond Lady (different desires, tones, and relationship arcs)
- [ ] Write encounter dialogue for each character (minimum: 1 pre-reading intro + 3 post-reading reactions per encounter)
- [ ] Expand card pool beyond the 15 starters (target 30–40 cards for meaningful deckbuilding)
- [ ] `[suggestion]` Consider designing a few "spread types" (e.g., a 2-card spread gives +Clarity bonus, a 3-card spread gives more raw stats) — this adds strategic variety without requiring new card mechanics
- [ ] `[suggestion]` Give Lady a primary desire and write at least 2 of her encounters now, as a vertical slice. Completing one full customer's arc (portrait → encounter → reading → reaction → relationship change) validates the whole system before you scale up

---

## Rendering & Polish

- [ ] Choose fonts — at minimum one display font (card titles, UI headers) and one readable body font (dialogue text)
- [ ] Implement scene transitions between game states (even a simple fade is enough)
- [ ] Card visual design: render a card object with name, stat icons, and a visual frame — even placeholder art
- [ ] Customer satisfaction feedback: a visual or audio cue after the reading resolves (before dialogue)
- [ ] `[suggestion]` Add a screen shake or brief flash on a high-success reading — it makes the resolution moment feel rewarding without needing complex animation

---

## Audio

- [ ] Choose ambient music direction (cozy medieval, mystical, quiet)
- [ ] Source or create SFX for key moments: card placed in spread, reading resolved, customer reaction (positive/negative)
- [ ] Integrate Love2D `love.audio` — at minimum ambient music loop + 2–3 SFX

---

## Technical / Infrastructure

- [ ] Add a simple save/load system (at minimum, save day number, deck state, and relationship levels)
- [ ] `[suggestion]` Even if save/load is post-MVP, structure your data as serializable tables from the start — retrofitting this after game state is deeply embedded in object references is painful in Lua
- [ ] Consider a debug/cheat mode toggle (force specific cards, skip to end of day, inspect customer attributes) — massively accelerates content testing
