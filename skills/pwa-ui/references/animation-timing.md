# Animation Timing Reference

## Spring Configuration Guide

### Understanding Spring Parameters

```
tension (stiffness): How quickly spring moves to target
  - Higher = faster, snappier
  - Lower = slower, more relaxed

friction (damping): How quickly oscillation settles
  - Higher = less bounce, settles faster
  - Lower = more bounce, longer settle
```

### Preset Configurations

| Name | Tension | Friction | Use Case |
|------|---------|----------|----------|
| Snappy | 400 | 30 | Buttons, toggles, micro-interactions |
| Gentle | 200 | 20 | Modals, sheets, page transitions |
| Bouncy | 300 | 10 | Playful UI, celebrations, badges |
| Stiff | 600 | 40 | Quick snaps, immediate feedback |
| iOS Default | 300 | 26 | General purpose, balanced feel |

### react-spring Implementation

```typescript
import { config } from '@react-spring/web';

// Built-in configs
config.default    // { tension: 170, friction: 26 }
config.gentle     // { tension: 120, friction: 14 }
config.wobbly     // { tension: 180, friction: 12 }
config.stiff      // { tension: 210, friction: 20 }
config.slow       // { tension: 280, friction: 60 }
config.molasses   // { tension: 280, friction: 120 }

// Custom iOS-like config
const iosSpring = { tension: 300, friction: 26 };
```

### Framer Motion Implementation

```typescript
// Spring configurations
const snappy = { type: 'spring', stiffness: 400, damping: 30 };
const gentle = { type: 'spring', stiffness: 200, damping: 20 };
const bouncy = { type: 'spring', stiffness: 300, damping: 10 };

// Usage
<motion.div
  animate={{ scale: 1 }}
  transition={snappy}
/>
```

## Duration Guidelines

When springs aren't appropriate (rare cases):

| Interaction | Duration | Easing |
|-------------|----------|--------|
| Fade in | 200ms | ease-out |
| Fade out | 150ms | ease-in |
| Color change | 100ms | ease |
| Opacity toggle | 150ms | ease |

**Note**: Prefer springs for all transform-based animations.

## Animation Categories

### Immediate Feedback (< 100ms)

```typescript
// Button press
const pressAnimation = {
  scale: 0.97,
  config: { tension: 600, friction: 40 },
};
```

### Short Interactions (100-300ms)

```typescript
// Toggle, checkbox
const toggleAnimation = {
  config: { tension: 400, friction: 30 },
};
```

### Medium Transitions (300-500ms)

```typescript
// Sheet open/close
const sheetAnimation = {
  config: { tension: 300, friction: 26 },
};
```

### Long Transitions (500ms+)

```typescript
// Page transitions with content settling
const pageAnimation = {
  config: { tension: 200, friction: 20 },
};
```

## Performance Rules

1. **Only animate transform and opacity**
   ```css
   /* Good */
   transform: translateX(100px);
   opacity: 0.5;

   /* Avoid */
   left: 100px;
   width: 200px;
   ```

2. **Use will-change sparingly**
   ```css
   .animating {
     will-change: transform;
   }
   ```

3. **Avoid layout thrashing**
   ```typescript
   // Bad - causes reflow
   element.style.width = element.offsetWidth + 10 + 'px';

   // Good - batch reads and writes
   const width = element.offsetWidth;
   requestAnimationFrame(() => {
     element.style.transform = `scaleX(${(width + 10) / width})`;
   });
   ```

4. **Use passive event listeners**
   ```typescript
   element.addEventListener('scroll', handler, { passive: true });
   ```
