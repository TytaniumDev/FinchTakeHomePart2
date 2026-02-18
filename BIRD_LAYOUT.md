# Bird Layout System

How the bird, speech bubble, draggable sheet, and app bar interact to keep layout stable regardless of bird size or sheet position.

---

## Screen Layout: Three-Layer Stack

`VibeSelectionScreen` returns a `Stack` with three layers (back to front):

```mermaid
graph TB
    subgraph Stack["Stack (full screen)"]
        direction TB
        L1["Layer 1: BirdViewArea<br/><i>Positioned.fill</i><br/>Background + bird + speech bubble"]
        L2["Layer 2: VibePickerSheet<br/>Draggable bottom sheet + vibe grid"]
        L3["Layer 3: App Bar<br/><i>Positioned(top:0)</i><br/>Close button + baby/adult toggle"]
    end

    style L1 fill:#e8f4e8,stroke:#4a9
    style L2 fill:#e8e8f4,stroke:#49a
    style L3 fill:#f4e8e8,stroke:#a49
```

The layers are connected by a single `ValueNotifier<double>` holding the current sheet extent (0.0-1.0). The sheet writes to it on drag; the bird area and app bar read from it via `ValueListenableBuilder`. This means **only the bird and app bar rebuild during drag** -- no full-screen `setState`.

```mermaid
flowchart LR
    Sheet["VibePickerSheet<br/><i>onExtentChanged</i>"]
    Notifier(["ValueNotifier&lt;double&gt;<br/>sheetExtent"])
    Bird["BirdViewArea<br/><i>ValueListenableBuilder</i>"]
    AppBar["App Bar<br/><i>ValueListenableBuilder</i>"]

    Sheet -- "writes" --> Notifier
    Notifier -- "rebuilds" --> Bird
    Notifier -- "rebuilds" --> AppBar
```

---

## Bird + Speech Bubble: The Bottom-Anchored Column

In `bird_view_area.dart`, the bird and speech bubble form a single `Column(mainAxisSize: MainAxisSize.min)` with a **constant total height of 234px** (`kBirdColumnHeight`):

```mermaid
block-beta
    columns 1
    block:col["Column (mainAxisSize: min)"]
        A["SpeechBubble<br/>~80px"]
        B["SizedBox(height: 4)"]
        block:container["SizedBox(height: 150) — FIXED container"]
            columns 1
            C["Align(bottomCenter)"]
            D["Bird SVG"]
        end
    end

    style A fill:#fff,stroke:#888
    style B fill:#eee,stroke:#888
    style container fill:#e8f0ff,stroke:#49a
    style D fill:#ffe8e8,stroke:#a49
```

This column is positioned with:

```dart
Positioned(
  left: 16,
  right: 16,
  bottom: bottomOffset,  // = availableHeight * sheetExtent + gap
  child: column,
)
```

Since `bottom` is used, the column's **bottom edge** (the bird's feet) is pinned at exactly `sheetHeight + gap` pixels from the screen bottom.

---

## How Baby/Adult Size Changes Don't Shift the Speech Bubble

The bird SVG sits inside a **fixed 150px `SizedBox`** with `Align(alignment: Alignment.bottomCenter)`:

```mermaid
block-beta
    columns 2

    block:adult["Adult Bird"]
        columns 1
        A1["SpeechBubble ~80px"]
        A2["Gap 4px"]
        block:a3["SizedBox(h:150)"]
            columns 1
            A4["Bird SVG 150px<br/>(fills container)"]
        end
    end

    block:baby["Baby Bird"]
        columns 1
        B1["SpeechBubble ~80px"]
        B2["Gap 4px"]
        block:b3["SizedBox(h:150)"]
            columns 1
            B5["Empty 37.5px"]
            B4["Bird SVG 112.5px<br/>(bottom-aligned)"]
        end
    end

    style A4 fill:#ffe8e8,stroke:#a49
    style B4 fill:#ffe8e8,stroke:#a49
    style B5 fill:#f8f8f8,stroke:#ccc,stroke-dasharray: 5 5
    style a3 fill:#e8f0ff,stroke:#49a
    style b3 fill:#e8f0ff,stroke:#49a
```

- **Adult (150px):** Fills the entire 150px container. Feet touch the bottom edge.
- **Baby (112.5px):** Leaves 37.5px of empty space *above*. Feet still touch the same bottom edge.

The column height stays at 234px in both cases. The speech bubble's position never changes.

---

## The Parallax Gap

The `gap` between the sheet's top edge and the bird's feet compresses as the sheet drags up:

```mermaid
graph LR
    subgraph MinExtent["Sheet at Min Extent (t=0)"]
        direction TB
        M1["gap = restGap<br/>(~50-100px)<br/>Bird centered in<br/>available space"]
    end
    subgraph MidDrag["Mid-Drag (t=0.5)"]
        direction TB
        M2["gap shrinking<br/>Bird rising with sheet<br/>but slower"]
    end
    subgraph MaxExtent["Sheet at Max Extent (t=1)"]
        direction TB
        M3["gap = 4px<br/>Bird nearly touching<br/>sheet top"]
    end

    MinExtent --> MidDrag --> MaxExtent

    style MinExtent fill:#e8f4e8,stroke:#4a9
    style MidDrag fill:#f4f4e8,stroke:#aa4
    style MaxExtent fill:#f4e8e8,stroke:#a49
```

The computation:

```dart
final t = ((sheetExtent - minExtent) / (maxExtent - minExtent)).clamp(0.0, 1.0);
final gap = restGap + (4.0 - restGap) * t;
final bottomOffset = availableHeight * sheetExtent + gap;
```

As the user drags the sheet up, the bird rises with it but the gap compresses, creating a subtle parallax where the bird moves slightly slower than the sheet.

---

## Full Positioning Diagram

A vertical slice of the screen showing how everything stacks from bottom to top:

```mermaid
block-beta
    columns 1
    A["App Bar + Safe Area (top)"]
    B["← kFadeRange (40px) → app bar fades when bird approaches"]
    C["↕ gap (restGap → 4px, compresses during drag)"]
    block:birdcol["Bird Column (234px constant)"]
        columns 1
        D["SpeechBubble (~80px)"]
        E["SizedBox(4px)"]
        F["Bird Container (150px, bottom-aligned SVG)"]
    end
    G["↕ gap above sheet top"]
    block:sheet["VibePickerSheet"]
        columns 1
        H["Drag Handle (24px)"]
        I["Vibe Grid (scrollable)"]
        J["Footer + Safe Area (bottom)"]
    end

    style birdcol fill:#e8f0ff,stroke:#49a
    style sheet fill:#e8e8f4,stroke:#49a
    style A fill:#f4e8e8,stroke:#a49
    style B fill:#f8f8f8,stroke:#ccc,stroke-dasharray: 5 5
    style C fill:#f8f8f8,stroke:#ccc,stroke-dasharray: 5 5
    style G fill:#f8f8f8,stroke:#ccc,stroke-dasharray: 5 5
```

---

## Dynamic Extent Computation

Both min and max extents are computed in `didChangeDependencies()` based on screen size:

```mermaid
flowchart TD
    Screen["Screen Height + Safe Areas"]
    Screen --> Min["computeMinExtent<br/>Show 1 full row + 40% peek row<br/>Clamped to [0.30, 0.45]"]
    Screen --> Max["computeMaxExtent<br/>Reserve 250px above for bird column<br/>1.0 - (safeAreaTop + 250) / height<br/>Clamped to [min+0.05, 0.70]"]

    Min --> Sheet["VibePickerSheet"]
    Max --> Sheet
    Min --> Bird["BirdViewArea"]
    Max --> Bird

    style Min fill:#e8f4e8,stroke:#4a9
    style Max fill:#f4e8e8,stroke:#a49
```

The 250px reservation for max extent breaks down as:
- Top margin: 12px
- Speech bubble: 80px
- Bubble-to-bird gap: 4px
- Bird container: 150px
- Min gap to sheet: 4px

---

## Speech Bubble Text Stability

Two mechanisms prevent text changes from jittering the bird:

```mermaid
flowchart TD
    subgraph AnimatedTypedText["AnimatedTypedText (typing animation)"]
        Stack["Stack"]
        Invisible["Visibility(visible: false, maintainSize: true)<br/>Full text — reserves final dimensions"]
        Visible["Text(substring 0..charCount)<br/>Types in character by character"]
        Stack --> Invisible
        Stack --> Visible
    end

    subgraph SpeechBubble["SpeechBubble (theme change)"]
        AS["AnimatedSize(alignment: topCenter)<br/>Grows/shrinks downward in column<br/>Visually expands upward since column is bottom-anchored"]
    end

    AnimatedTypedText -- "no layout shift<br/>during typing" --> Stable["Bird feet stay put"]
    SpeechBubble -- "smooth transition<br/>on text change" --> Stable

    style Stable fill:#e8f4e8,stroke:#4a9
```

1. **During typing:** The invisible full text immediately reserves the final size. No incremental layout shifts.
2. **On theme change:** `AnimatedSize(alignment: topCenter)` grows the bubble downward within the column. Since the column is bottom-anchored, visually the bubble expands upward while the bird's feet remain stationary.

---

## The Draggable Sheet

The sheet accepts two independent drag inputs:

```mermaid
flowchart TD
    Handle["Drag Handle (GestureDetector)<br/>Converts pixel delta → fractional extent<br/>Calls controller.jumpTo()"]
    Scroll["Scroll Controller (built-in)<br/>Scroll up → expand sheet first, then scroll grid<br/>Scroll down → collapse sheet first, then stop"]

    Handle --> Controller["DraggableScrollableController"]
    Scroll --> Controller

    Controller -- "onExtentChanged" --> Callback["widget.onExtentChanged"]
    Callback --> Notifier["_sheetExtentNotifier<br/>(ValueNotifier)"]
    Notifier --> BirdReposition["Bird repositions"]
    Notifier --> AppBarFade["App bar fades"]
```

---

## App Bar Fade

The app bar replicates the same gap logic from `BirdViewArea` to compute the bird column's top edge, then fades based on proximity:

```dart
birdColumnTop = screenHeight * (1 - sheetExtent) - gap - kBirdColumnHeight
distance = birdColumnTop - appBarBottom
opacity = (distance / kFadeRange).clamp(0.0, 1.0)  // kFadeRange = 40px
```

Below 0.1 opacity, `IgnorePointer(ignoring: true)` disables hit testing so taps pass through to the bird area behind.

---

## Key Insight

The approach **decouples the bird's visual size from its layout footprint**. The fixed 150px `SizedBox` + `Align(bottomCenter)` means the column always occupies exactly 234px regardless of which bird asset is rendered. The speech bubble sits above a constant-height container, and the whole column is bottom-anchored to track the sheet. You could swap in any bird asset of any size (up to 150px) and the speech bubble, feet position, and sheet relationship all remain perfectly stable.
