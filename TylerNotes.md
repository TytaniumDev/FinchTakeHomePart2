# Tyler's Notes

I went a bit beyond these requirements in some areas, like adding animations to
the chat bubble, the text inside, and the color transitions. I used the Finch
app as reference for some things, and added things I felt added some fun for
others.

> **Important:** Click the **Done** button for a different take on text bubble
> positioning, and click the **X** in the top left to see how I iterated quickly
> on some of the more complicated parts of the layout.

The drawer is also fully draggable, and matches how the real Finch app works
(including a bug fix for when you scroll all the way to the bottom of the vibes
sheet and keep scrolling on iOS. The real app has the drag handle bounce down a
bit due to the iOS scroll behavior).

---

## Bird Positioning

The bird positioning is solved by using a `Stack` for the whole page, and using
`Positioned` for a Bird+Text+Background that moves up the page based on the
`DraggableScrollableSheet`'s extent. To keep the bird's feet in a constant spot,
the bird widget is put inside a `SizedBox` that is the size of the largest bird
SVG, and then the SVG is bottom aligned. The text bubble sits on top of that
`SizedBox`. The background SVG is anchored roughly the same way.

Ideally all of the bird assets would be the same size, we'd be able to do more
interesting things and compute less on the client side that way.

### Fun Stuff

For example, if you click the "Done" button the text bubble positioning changes
to be based on the bird's mouth, something which is hand edited using the debug
screen I added that you can get to by clicking the X button.

This is something that could be done at the time of asset creation, and sent as
JSON to the client or baked in to the app when the assets are delivered.

This could allow even more realistic looking text bubbles, by reusing some of
the anchoring tech behind `MenuAnchor` to display a text bubble close by the
bird's mouth but also making sure to not have it run into the edge of the
screen.

---

## Drawer Layout

The drawer was solved by some complex math that Claude helped significantly
with.

The peek comes from the constant `_kRowPeekFraction = 0.4` and flows through two
stages:

1. **`computeMinExtent`** — Determines sheet size at rest. It loops N from 1
   upward, computing grid height as:

   ```
   gridHeight = (N + 0.4) * maxTileHeight + N * spacing
   ```

   It picks the largest N where the total sheet extent stays under
   `kMinExtentCeiling` (0.45). The returned `targetRows` is `bestN + 0.4` (e.g.
   2.4).

2. **`SliverGridDelegateWithAdaptiveHeight`** — Receives that `targetRows` value
   and sizes each tile so exactly `targetRows` rows fit in the available grid
   height. Since `targetRows` is fractional (e.g. 2.4), two full rows render and
   the third row's top 40% peeks above the bottom edge, visually cueing that the
   grid is scrollable.

So the peek isn't clipping or overflow — it's baked into the tile sizing math.
The grid delegate scales tiles so the fractional row naturally lands at the
fold.

Because this was primarily agenticly coded, I had Claude also build a debug
testing page (also in the X button) that let me verify the behavior quickly on
any number of screen sizes. In a production app, I'd also have it create golden
screenshot diff tests of key phone dimensions to make sure everything works.

I'm pretty confident in this implementation, it even works well on tablets and
extremely long phones!

---

## Other Considerations

The SVG background for the main screen does not scale to large devices like
tablets currently, so if you try it on a tablet the bird isn't standing
_precisely_ where it should, but it's pretty close. In a real scenario I'd
request the SVG be made larger than our expected screen size so we could scale
the bird and background at the same rate and not have to worry about the SVG
being too small.

I ended up breaking out the code like I would in a real app, file wise.
Everything is relatively isolated into smaller chunks in individual files that
are easy to understand.
