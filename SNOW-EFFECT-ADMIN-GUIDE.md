# ❄️ Snow Accumulation Effect - Admin Guide

## Overview
The Snow Accumulation Engine is a canvas-based visual effect that shows snowflakes falling and accumulating on the student's name. It only runs when the **Admin Christmas Theme** is enabled.

## Features
- **Personalized**: Displays "Merry Christmas, [Student Name]" with falling snow
- **Performance-Optimized**: Uses canvas rendering with DPR scaling
- **Interactive**: Snow accumulates realistically on the student's name
- **Great Vibes Font**: Elegant cursive typography
- **Admin-Controlled**: Only visible when enabled via localStorage

## Admin Controls

### Enable Christmas Theme
Open browser console (F12) and run:
```javascript
enableChristmasTheme()
```
Then reload the page.

### Disable Christmas Theme
Open browser console (F12) and run:
```javascript
disableChristmasTheme()
```
Then reload the page.

### Toggle Theme
Open browser console (F12) and run:
```javascript
toggleChristmasTheme()
```
Then reload the page.

### Check Current Status
```javascript
localStorage.getItem('arnoma:christmas-theme')
// Returns: 'true' (enabled) or 'false'/'null' (disabled)
```

## Technical Details

### Canvas Specs
- **Full-screen overlay**: `position: fixed; inset: 0; z-index: 9999`
- **Pointer-events**: `none` (doesn't block interactions)
- **Resolution**: Auto-scaled with `devicePixelRatio` (max 2x)

### Snow Physics
- **Max Flakes**: 260 simultaneous particles
- **Spawn Rate**: 70% chance per frame when under max
- **Fall Speed**: 70-170 pixels/second (random)
- **Accumulation Rate**: 1.4 pixels per collision
- **Buckets**: 320 collision detection zones

### Performance
- **Optimized Loop**: Delta time capped at 33ms (30 FPS minimum)
- **Smart Culling**: Removes flakes below viewport
- **Memory Efficient**: Reuses particle objects

### Student Name Extraction
The engine automatically extracts the student's name from the DOM:
1. Waits 1 second for portal to load
2. Reads from `#welcomeMessage` element
3. Parses "Welcome back, [Name]!" format
4. Updates snow effect with real name

Default fallback: `"{Student Name}"`

## Integration Points

### HTML
```html
<!-- Added to <head> -->
<link href="https://fonts.googleapis.com/css2?family=Great+Vibes&display=swap" rel="stylesheet">

<!-- Added after Christmas tree container -->
<canvas id="snowCanvas"></canvas>
```

### CSS
```css
#snowCanvas {
  position: fixed;
  inset: 0;
  pointer-events: none;
  z-index: 9999;
  display: none; /* Hidden by default */
}

#snowCanvas.active {
  display: block;
}
```

### JavaScript
- **Class**: `SnowAccumulationEngine` (lines ~10450-10650)
- **Initialization**: Checks `localStorage.getItem('arnoma:christmas-theme')`
- **Global Instance**: `window.snowEngine` (accessible for debugging)

## Troubleshooting

### Snow not appearing?
1. Check localStorage: `localStorage.getItem('arnoma:christmas-theme')`
2. Enable theme: `enableChristmasTheme()`
3. Hard reload: `Cmd+Shift+R` (macOS) or `Ctrl+Shift+R` (Windows)
4. Check console for errors

### Student name showing as "{Student Name}"?
- Portal may not have loaded yet
- Manually update: `window.snowEngine.setStudentName("Actual Name")`

### Performance issues?
- Reduce max flakes: `window.snowEngine.MAX_FLAKES = 150`
- Reduce buckets: `window.snowEngine.BUCKETS = 200`
- Stop engine: `window.snowEngine.stop()`
- Start engine: `window.snowEngine.start()`

## Future Enhancements (Optional)
- [ ] UI toggle in account dropdown (requires new UI component)
- [ ] Admin-only settings panel
- [ ] Multiple theme presets (Halloween, Valentine's, etc.)
- [ ] Customizable subtitle text
- [ ] Adjustable snow intensity slider

## Compatibility
- **Modern Browsers**: Chrome 90+, Firefox 88+, Safari 14+, Edge 90+
- **Canvas API**: Full support required
- **requestAnimationFrame**: Essential for smooth animation
- **localStorage**: Used for theme persistence

## Removal Instructions
If you need to remove the snow effect entirely:

1. Remove Google Fonts link (line ~36):
   ```html
   <link href="https://fonts.googleapis.com/css2?family=Great+Vibes&display=swap" rel="stylesheet">
   ```

2. Remove CSS block (lines ~3440-3458):
   ```css
   #snowCanvas { ... }
   #snowCanvas.active { ... }
   ```

3. Remove canvas element (line ~3448):
   ```html
   <canvas id="snowCanvas"></canvas>
   ```

4. Remove entire script block (lines ~10443-10703):
   ```html
   <!-- SNOW ACCUMULATION ENGINE script -->
   ```

---

**Last Updated**: December 12, 2025  
**Tested On**: student-portal.html (10703 lines)  
**Architecture**: Mega-page pattern (no build system)
