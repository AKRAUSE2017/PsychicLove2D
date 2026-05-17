# Psychic Love 2D — Project Overview

## What It Is

A medieval fantasy **deck-builder shop sim** built in Love2D (Lua). The player is a psychic who reads fortunes for customers using a tarot-inspired card spread system. Gameplay revolves around understanding each customer's hidden desires and constructing a reading that satisfies them — balancing strategic card play with narrative interpretation.

**Development direction (decided):** Shop-management driven (Papa's Pizzeria model) rather than story-driven. More gameplay-focused, easier to POC, and easier to expand. Story emerges through repeated encounters rather than branching dialogue trees.

---

## Vision & Tone

- Mystical, cozy, slightly surreal
- Medieval fantasy setting with fantastical creatures (humanoids, half-dragons, goblins, etc.)
- Visual motifs: tarot, cosmic imagery, soft candlelight
- Writing tone: whimsical and melancholy in equal measure

---

## Core Gameplay Loop

1. A queue of customers visits the shop each day
2. Customer enters with dialogue — implicit clues about their desires, mood, and expectations
3. Player draws from their deck and places cards into a spread (up to 3 slots)
4. The spread resolves into a **fortune state** (aggregated stats + modifier effects)
5. Customer reacts based on how well the fortune state matches their hidden attributes
6. Outcome: relationship score change + rewards (currency (tips), cards, items)
7. End of day: player spends rewards on shop upgrades, new cards, and deck management

---

## Systems

### Card System

The core mechanic. Each card has:

- **Stats**: Success, Love, Wealth, Stability — the four desire categories customers care about. Values can be negative (shadow cards).
- **Ambiguity**: A number (0–5) representing how uncertain or vague the card makes the reading. Adds to the spread's total ambiguity. High-power cards tend to carry more ambiguity — they're riskier to play. Cards can also carry *negative* ambiguity (they reduce the spread's total), which is valuable when playing against cautious customers or pairing with risky cards.
- **Tag**: The card's primary identity — what kind of fortune energy it represents. Drives adjacency modifier conditions and gives the player an at-a-glance read on what the card is for.
- **Modifiers**: Conditional effects that fire at resolution based on placement context. Every card can have zero or more modifiers.

**Card data schema:**
```lua
{
    name      = string,
    flavor    = string,   -- one-line flavor text
    tag       = "love" | "success" | "wealth" | "stability" | "neutral",
    stats = {
        success   = number,   -- can be negative
        love      = number,
        wealth    = number,
        stability = number,
    },
    hasNegativeStat = boolean,  -- ☽ = shadow card (contains at least one negative stat; relevant to customer Negativity Tolerance)
    ambiguity       = number,   -- 0 to 5; negative values reduce spread total
    modifiers = {
        {
            stat      = "success" | "love" | "wealth" | "stability",
            operation = "+" | "-" | "*",
            value     = number,
            condition = {
                type  = "adjacent_tag" | "position_first" | "position_last",
                value = string | number
            }
        }
    }
}
```

**The four modifier conditions (closed set — nothing else for POC):**

| Condition | `value` type | Fires when... |
|---|---|---|
| `adjacent_tag` | string (tag name) | A card with the given tag occupies a neighboring slot |
| `position_first` | — | This card is in slot 1 |
| `position_last` | — | This card is in the final filled slot |

**Starter card list (15 cards — locked for POC):**

☽ = shadow card (contains at least one negative stat; relevant to customer Negativity Tolerance)

| Card | Tag | Stats | Ambiguity | Modifier |
|---|---|---|---|---|
| Fortunate Misprint | wealth | +3 Wealth | +1 | — |
| Third Eye Twitch | neutral | none | -2 | — (pure ambiguity reducer; creates room for risky cards) |
| Lingering Perfume | love | +2 Love | +1 | +1 Love if `adjacent_tag: love` |
| Empty Coin Purse ☽ | success | +3 Success, -2 Wealth | 0 | — |
| Overheard Omen | neutral | +1 all stats | +3 | — (wildcard; high ceiling, high ambiguity cost) |
| Cracked Mirror ☽ | stability | +2 Stability, -1 Love | 0 | +2 Stability if `position_first` |
| Borrowed Luck | success | +4 Success | +1 | -2 Success if `position_last` (punishes placing it last) |
| Unsent Letter | love | +1 Love, +1 Stability | 0 | +3 Love if `position_last` |
| Fleeting Windfall | wealth | +4 Wealth | +3 | — (high power, pushes ambiguity hard) |
| Quiet Grave | stability | +2 Stability | -1 | — (safe, reliable; reduces ambiguity as a bonus) |
| Jealous Star ☽ | love | +3 Love, -1 Success | +1 | — |
| Familiar's Advice | neutral | +1 Love, +1 Success | 0 | +1 all stats if `spread_size: 3` |
| Hopeless Necromantic ☽ | love | +2 Love, -2 Stability | +1 | +1 Love to all other `love`-tagged cards in the spread if `adjacent_tag: love` |
| Weeping Knight ☽ | success | +3 Success, -1 Love | 0 | — |
| The Silent Child ☽ | neutral | none | 0 | Copies the highest stat of an adjacent card; -2 all stats if no neighbors |

---

### Customer / Character System

Each customer has hidden attributes the player must infer from dialogue. They are never displayed directly.

**Locked attributes (POC):**

| Attribute | Type | Notes |
|---|---|---|
| Primary Desire | `"success" \| "love" \| "wealth" \| "stability"` | What they most want the reading to reflect |
| Secondary Desire | same, or `nil` | At half weight in scoring; creates dual-optimization tension |
| Ambiguity Tolerance | number (0–10) | Max spread ambiguity they can handle before a penalty applies |
| Negativity Tolerance | `"low" \| "medium" \| "high"` | How they react to shadow cards in the spread |

Characters persist across days and accumulate a **relationship level**. At defined thresholds, story details unlock.

**Character data schema:**
```lua
{
    name              = string,
    portrait          = string,   -- sprite path
    relationshipLevel = number,
    encounters = {
        {
            day = number,
            desire = {
                primary   = "success" | "love" | "wealth" | "stability",
                secondary = "success" | "love" | "wealth" | "stability",  -- or nil
            },
            ambiguityTolerance  = number,   -- 0 to 10
            negativityTolerance = "low" | "medium" | "high",
            dialogue            = { string },
            outcome = {
                positive = { minScore = number, relationshipDelta = number, dialogue = string, tip = number },
                neutral  = { minScore = number, relationshipDelta = number, dialogue = string },
                negative = {                    relationshipDelta = number, dialogue = string },
            }
        }
    }
}
```

---

### Spread / Reading System

- Player draws a hand of **5 cards** (TBD) from their shuffled deck
- Player places **1–3 cards** (TBD for more slots) into spread slots on the table (variable spread size is intentional — it's a decision)
- Placement order matters: modifiers key off slot position and neighbor tags
- Spread resolves after all cards are placed: stats are summed, then modifiers fire in left-to-right slot order
- Final fortune state is compared to the customer's attributes via the outcome formula → outcome determined

**Outcome calculation (locked):**

```
primaryScore   = fortuneState[desire.primary]
secondaryScore = fortuneState[desire.secondary] or 0

combinedScore  = primaryScore + floor(secondaryScore / 2)

-- Ambiguity penalty: each point over tolerance costs 2
ambiguityPenalty = 0
if totalAmbiguity > ambiguityTolerance then
    ambiguityPenalty = (totalAmbiguity - ambiguityTolerance) * 2
end

-- Negativity penalty: any shadow card in the spread
negativityPenalty = 0
if spread contains any shadow card then
    if negativityTolerance == "low"    then negativityPenalty = 4
    if negativityTolerance == "medium" then negativityPenalty = 2
    -- high: no penalty
end

finalScore = combinedScore - ambiguityPenalty - negativityPenalty

-- Thresholds live on the encounter (tunable per customer)
if finalScore >= outcome.positive.minScore → positive
if finalScore >= outcome.neutral.minScore  → neutral
else                                       → negative
```

Thresholds are set per-encounter rather than globally, so individual customers can be more or less generous without touching the formula.

**What makes spreads challenging:**

- **Information gap** — customer attributes are never shown; dialogue implies them. The player is reading the customer the same way they read the cards.
- **Ambiguity risk** — the highest-stat cards carry the most ambiguity. Against a cautious customer they're traps; against a high-tolerance customer they're the correct play. Every draw forces a read on the customer.
- **Placement puzzle** — the same 3 cards score differently depending on order. The player is solving a small positional puzzle on some encounters.
- **Draw variance** — utility cards exist to compensate for bad draws and make risky cards playable. The player should always have a line with a weak hand, even if the ceiling is lower.

---

### Deckbuilding

- Player starts with a fixed starter deck
- New cards earned as rewards from encounters or purchased from shop
- Between days, player can remove or upgrade cards
- Deck should stay constrained enough that every reading feels like a meaningful decision

---

### Shop / Day Progression

- Day structure: customer queue → encounters → end-of-day summary
- End-of-day: review relationships and rewards, purchase upgrades, manage deck
- Shop upgrades: gameplay effects, new card options, cosmetic customization
- Customer scheduling: pre-determined, random, or hybrid — **currently undecided**
- **End game condition: TBD**

---

## Current Code State

### Tech Stack

- **Engine**: Love2D 11.x (Lua 5.1)
- **Virtual resolution**: 640×360 (scaled to 1290×960 window via `push` library)
- **OOP**: Matthias Richter's `class.lua` (lightweight, permissive license)

### What's Built

| System | Status | Notes |
|---|---|---|
| Player movement | Done | 4-directional WASD/arrows, normalized diagonal movement |
| Player sprites | Done | Idle + walk in all 4 directions from sprite sheets |
| Tilemap | Done | Wood floor + rug quad rendering |
| Structure system | Done | Depth-sorted rendering (front/behind player), AABB collision |
| Character portrait | Done | Idle/blink/smile animations, toggled with `k` |
| Resolution scaling | Done | `push` module, resize-safe |
| Config system | Done | Centralized constants in `config.lua` |
| Card system | Not started | Data model designed |
| Customer system | Not started | Data model designed |
| Spread/reading UI | Not started | — |
| Deck management | Not started | — |
| Dialogue system | Not started | — |
| Day loop | Not started | — |
| Shop/upgrade screen | Not started | — |
| Game state machine | Not started | — |

---

## File Structure

```
PsychicLove2D/
├── main.lua              # Entry point — setup, draw, update, input
├── conf.lua              # Love2D config (console enabled)
├── config.lua            # All game constants (resolution, player speed, map data)
├── classes/
│   ├── player.lua        # Movement, animation, collision
│   ├── map.lua           # Tilemap renderer (wood + rug)
│   ├── portrait.lua      # NPC portrait with animation states
│   └── structure.lua     # Depth-sorted environment objects
├── helpers/
│   ├── animations.lua    # Sprite sheet → quad animation builder
│   ├── env.lua           # Scene object setup (table placement)
│   └── utils.lua         # AABB collision detection + side resolution
├── modules/
│   ├── class.lua         # OOP library (Matthias Richter)
│   └── push.lua          # Virtual resolution scaling
└── assets/
    └── sprites/
        ├── environment/  # wood, rug, table, background (+ Aseprite sources)
        ├── player/       # directional idle/walk sheets (+ Aseprite sources)
        └── portraits/    # lady.png
```
