---
name: pwa-ui
description: Create Apple-inspired PWA UI/UX with production-ready animations, typography, design tokens, and mobile-first patterns for React and Next.js. Use when user needs "mobile app feel", "PWA design", "Apple-style animations", "iOS-like interface", "smooth transitions", "native app experience", or "mobile-first dashboard". Triggers on requests for gesture handling, spring animations, haptic feedback patterns, or platform-adaptive UI.
---

# PWA UI/UX Skill (Apple Best Practices)

Create production-ready progressive web applications with native app feel using Apple's Human Interface Guidelines adapted for React/Next.js.

## When to Use

- Building mobile-first web applications
- Creating PWA with native app experience
- Implementing iOS-style animations and transitions
- Designing gesture-based interactions
- Building platform-adaptive interfaces (iOS/Android/Web)

## Workflow

### Phase 1: Foundation Setup

**Goal**: Establish design tokens, viewport handling, and base configuration

**Actions**:
1. Configure viewport meta and PWA manifest
2. Set up design tokens (colors, spacing, typography)
3. Implement safe area handling for notched devices
4. Configure touch handling and gesture system

**Output**: `tokens.ts`, `manifest.json`, viewport configuration

### Phase 2: Component Architecture

**Goal**: Build reusable UI primitives with Apple-style interactions

**Actions**:
1. Create base components with spring animations
2. Implement gesture handlers (swipe, press, drag)
3. Add haptic feedback integration
4. Build navigation patterns (sheets, modals, tabs)

**Output**: Component library with native feel

### Phase 3: Polish & Platform Adaptation

**Goal**: Refine animations and adapt for different platforms

**Actions**:
1. Fine-tune spring physics for 60fps animations
2. Add reduced motion support
3. Implement platform-specific adaptations
4. Test touch responsiveness

**Output**: Production-ready PWA interface

## Design Tokens

### Typography Scale (SF Pro Inspired)

```typescript
// tokens/typography.ts
export const typography = {
  // Large Title - Hero sections
  largeTitle: {
    fontSize: '34px',
    lineHeight: '41px',
    fontWeight: 700,
    letterSpacing: '0.37px',
  },
  // Title 1 - Page headers
  title1: {
    fontSize: '28px',
    lineHeight: '34px',
    fontWeight: 700,
    letterSpacing: '0.36px',
  },
  // Title 2 - Section headers
  title2: {
    fontSize: '22px',
    lineHeight: '28px',
    fontWeight: 700,
    letterSpacing: '0.35px',
  },
  // Title 3 - Card headers
  title3: {
    fontSize: '20px',
    lineHeight: '25px',
    fontWeight: 600,
    letterSpacing: '0.38px',
  },
  // Headline - List items
  headline: {
    fontSize: '17px',
    lineHeight: '22px',
    fontWeight: 600,
    letterSpacing: '-0.41px',
  },
  // Body - Primary content
  body: {
    fontSize: '17px',
    lineHeight: '22px',
    fontWeight: 400,
    letterSpacing: '-0.41px',
  },
  // Callout - Secondary content
  callout: {
    fontSize: '16px',
    lineHeight: '21px',
    fontWeight: 400,
    letterSpacing: '-0.32px',
  },
  // Subheadline - Metadata
  subheadline: {
    fontSize: '15px',
    lineHeight: '20px',
    fontWeight: 400,
    letterSpacing: '-0.24px',
  },
  // Footnote - Captions
  footnote: {
    fontSize: '13px',
    lineHeight: '18px',
    fontWeight: 400,
    letterSpacing: '-0.08px',
  },
  // Caption 1 - Labels
  caption1: {
    fontSize: '12px',
    lineHeight: '16px',
    fontWeight: 400,
    letterSpacing: '0px',
  },
  // Caption 2 - Small labels
  caption2: {
    fontSize: '11px',
    lineHeight: '13px',
    fontWeight: 400,
    letterSpacing: '0.07px',
  },
} as const;

// Font stack with system fallbacks
export const fontFamily = {
  sans: '-apple-system, BlinkMacSystemFont, "SF Pro Text", "SF Pro Display", system-ui, sans-serif',
  mono: '"SF Mono", "Menlo", "Monaco", "Courier New", monospace',
};
```

### Color System

```typescript
// tokens/colors.ts
export const colors = {
  // Semantic colors
  label: {
    primary: 'rgba(0, 0, 0, 1)',
    secondary: 'rgba(60, 60, 67, 0.6)',
    tertiary: 'rgba(60, 60, 67, 0.3)',
    quaternary: 'rgba(60, 60, 67, 0.18)',
  },
  // System backgrounds
  background: {
    primary: '#FFFFFF',
    secondary: '#F2F2F7',
    tertiary: '#FFFFFF',
    grouped: '#F2F2F7',
    groupedSecondary: '#FFFFFF',
  },
  // Accent colors
  accent: {
    blue: '#007AFF',
    green: '#34C759',
    indigo: '#5856D6',
    orange: '#FF9500',
    pink: '#FF2D55',
    purple: '#AF52DE',
    red: '#FF3B30',
    teal: '#5AC8FA',
    yellow: '#FFCC00',
  },
  // Fills
  fill: {
    primary: 'rgba(120, 120, 128, 0.2)',
    secondary: 'rgba(120, 120, 128, 0.16)',
    tertiary: 'rgba(118, 118, 128, 0.12)',
    quaternary: 'rgba(116, 116, 128, 0.08)',
  },
  // Separators
  separator: 'rgba(60, 60, 67, 0.29)',
  separatorOpaque: '#C6C6C8',
} as const;

// Dark mode variants
export const colorsDark = {
  label: {
    primary: 'rgba(255, 255, 255, 1)',
    secondary: 'rgba(235, 235, 245, 0.6)',
    tertiary: 'rgba(235, 235, 245, 0.3)',
    quaternary: 'rgba(235, 235, 245, 0.18)',
  },
  background: {
    primary: '#000000',
    secondary: '#1C1C1E',
    tertiary: '#2C2C2E',
    grouped: '#000000',
    groupedSecondary: '#1C1C1E',
  },
  separator: 'rgba(84, 84, 88, 0.6)',
  separatorOpaque: '#38383A',
} as const;
```

### Spacing & Layout

```typescript
// tokens/spacing.ts
export const spacing = {
  // Base unit: 4px
  0: '0px',
  1: '4px',
  2: '8px',
  3: '12px',
  4: '16px',
  5: '20px',
  6: '24px',
  8: '32px',
  10: '40px',
  12: '48px',
  16: '64px',
} as const;

// Safe areas for notched devices
export const safeArea = {
  top: 'env(safe-area-inset-top, 0px)',
  right: 'env(safe-area-inset-right, 0px)',
  bottom: 'env(safe-area-inset-bottom, 0px)',
  left: 'env(safe-area-inset-left, 0px)',
};

// Standard iOS margins
export const margins = {
  content: '16px',      // Standard content margin
  grouped: '20px',      // Grouped table margin
  compact: '8px',       // Compact layouts
};

// Corner radius
export const radius = {
  none: '0px',
  sm: '6px',
  md: '10px',
  lg: '14px',
  xl: '20px',
  full: '9999px',
  // iOS-specific
  card: '12px',
  button: '12px',
  input: '10px',
  sheet: '12px',
};
```

## Animation Patterns

### Spring Physics

```typescript
// animations/springs.ts
import { useSpring, animated, config } from '@react-spring/web';

// Apple-style spring configurations
export const springs = {
  // Snappy - buttons, toggles (stiffness: 400, damping: 30)
  snappy: { tension: 400, friction: 30 },

  // Gentle - modals, sheets (stiffness: 200, damping: 20)
  gentle: { tension: 200, friction: 20 },

  // Bouncy - playful elements (stiffness: 300, damping: 10)
  bouncy: { tension: 300, friction: 10 },

  // Stiff - micro-interactions (stiffness: 600, damping: 40)
  stiff: { tension: 600, friction: 40 },

  // iOS default - general purpose
  ios: { tension: 300, friction: 26 },
} as const;

// Example: Pressable button with scale
export function PressableButton({ children, onPress }) {
  const [springs, api] = useSpring(() => ({
    scale: 1,
    config: springs.snappy,
  }));

  return (
    <animated.button
      style={{ transform: springs.scale.to(s => `scale(${s})`) }}
      onPointerDown={() => api.start({ scale: 0.97 })}
      onPointerUp={() => api.start({ scale: 1 })}
      onPointerLeave={() => api.start({ scale: 1 })}
      onClick={onPress}
    >
      {children}
    </animated.button>
  );
}
```

### Page Transitions

```typescript
// animations/transitions.ts
import { useTransition, animated } from '@react-spring/web';

// iOS-style push/pop navigation
export function NavigationStack({ pages, currentIndex }) {
  const transitions = useTransition(currentIndex, {
    from: { transform: 'translateX(100%)', opacity: 0 },
    enter: { transform: 'translateX(0%)', opacity: 1 },
    leave: { transform: 'translateX(-30%)', opacity: 0.5 },
    config: { tension: 300, friction: 26 },
  });

  return transitions((style, index) => (
    <animated.div style={{ ...style, position: 'absolute', inset: 0 }}>
      {pages[index]}
    </animated.div>
  ));
}

// Bottom sheet with gesture
export function BottomSheet({ isOpen, onClose, children }) {
  const [{ y }, api] = useSpring(() => ({ y: 100 }));

  useEffect(() => {
    api.start({ y: isOpen ? 0 : 100 });
  }, [isOpen]);

  const bind = useDrag(({ movement: [, my], velocity: [, vy], direction: [, dy] }) => {
    if (dy > 0 && vy > 0.5) {
      onClose();
    } else {
      api.start({ y: Math.max(0, my) });
    }
  });

  return (
    <animated.div
      {...bind()}
      style={{
        transform: y.to(v => `translateY(${v}%)`),
        touchAction: 'none',
      }}
    >
      <div className="sheet-handle" />
      {children}
    </animated.div>
  );
}
```

### Gesture Handling

```typescript
// gestures/handlers.ts
import { useDrag, useGesture } from '@use-gesture/react';

// Swipe to delete pattern
export function SwipeToDelete({ onDelete, children }) {
  const [{ x }, api] = useSpring(() => ({ x: 0 }));
  const threshold = -80;

  const bind = useDrag(({ movement: [mx], last, velocity: [vx] }) => {
    if (last) {
      if (mx < threshold || (vx < -0.5 && mx < 0)) {
        api.start({ x: -200 });
        onDelete();
      } else {
        api.start({ x: 0 });
      }
    } else {
      api.start({ x: Math.min(0, mx), immediate: true });
    }
  }, { axis: 'x' });

  return (
    <div style={{ position: 'relative', overflow: 'hidden' }}>
      <div style={{ position: 'absolute', right: 0, background: 'red' }}>
        Delete
      </div>
      <animated.div {...bind()} style={{ x, touchAction: 'pan-y' }}>
        {children}
      </animated.div>
    </div>
  );
}

// Pull to refresh
export function PullToRefresh({ onRefresh, children }) {
  const [refreshing, setRefreshing] = useState(false);
  const [{ y, rotate }, api] = useSpring(() => ({ y: 0, rotate: 0 }));

  const bind = useDrag(({ movement: [, my], last }) => {
    if (last && my > 80) {
      setRefreshing(true);
      onRefresh().finally(() => setRefreshing(false));
    }
    api.start({
      y: last ? 0 : Math.max(0, my * 0.5),
      rotate: my * 2,
    });
  }, { axis: 'y', bounds: { top: 0 } });

  return (
    <div {...bind()} style={{ touchAction: 'pan-x' }}>
      <animated.div style={{ y, rotate }}>
        <RefreshIndicator spinning={refreshing} />
      </animated.div>
      {children}
    </div>
  );
}
```

## Component Patterns

### Navigation Bar

```typescript
// components/NavigationBar.tsx
interface NavigationBarProps {
  title: string;
  largeTitle?: boolean;
  leftAction?: React.ReactNode;
  rightAction?: React.ReactNode;
}

export function NavigationBar({
  title,
  largeTitle = false,
  leftAction,
  rightAction,
}: NavigationBarProps) {
  const [collapsed, setCollapsed] = useState(false);

  useEffect(() => {
    const handleScroll = () => setCollapsed(window.scrollY > 44);
    window.addEventListener('scroll', handleScroll, { passive: true });
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  return (
    <>
      {/* Inline nav bar */}
      <header className={cn(
        'fixed top-0 inset-x-0 z-50',
        'h-[44px] pt-[env(safe-area-inset-top)]',
        'backdrop-blur-xl bg-white/80 dark:bg-black/80',
        'border-b border-separator',
        collapsed ? 'opacity-100' : 'opacity-0'
      )}>
        <div className="flex items-center justify-between h-full px-4">
          {leftAction}
          <span className="font-semibold text-[17px]">{title}</span>
          {rightAction}
        </div>
      </header>

      {/* Large title */}
      {largeTitle && (
        <div className={cn(
          'pt-[calc(44px+env(safe-area-inset-top))] px-4 pb-2',
          collapsed && 'opacity-0'
        )}>
          <h1 className="text-[34px] font-bold tracking-[0.37px]">
            {title}
          </h1>
        </div>
      )}
    </>
  );
}
```

### List/Table View

```typescript
// components/TableView.tsx
interface TableSectionProps {
  header?: string;
  footer?: string;
  children: React.ReactNode;
}

export function TableSection({ header, footer, children }: TableSectionProps) {
  return (
    <section className="mb-8">
      {header && (
        <h3 className="text-[13px] text-label-secondary uppercase tracking-wide px-4 mb-2">
          {header}
        </h3>
      )}
      <div className="bg-background-groupedSecondary rounded-[10px] mx-4 overflow-hidden">
        {children}
      </div>
      {footer && (
        <p className="text-[13px] text-label-secondary px-4 mt-2">
          {footer}
        </p>
      )}
    </section>
  );
}

interface TableRowProps {
  title: string;
  subtitle?: string;
  leading?: React.ReactNode;
  trailing?: React.ReactNode;
  chevron?: boolean;
  onPress?: () => void;
}

export function TableRow({
  title,
  subtitle,
  leading,
  trailing,
  chevron = true,
  onPress,
}: TableRowProps) {
  return (
    <button
      onClick={onPress}
      className={cn(
        'w-full flex items-center gap-3 px-4 py-3',
        'active:bg-fill-tertiary transition-colors',
        'border-b border-separator last:border-b-0'
      )}
    >
      {leading}
      <div className="flex-1 text-left">
        <span className="text-[17px]">{title}</span>
        {subtitle && (
          <span className="block text-[15px] text-label-secondary">
            {subtitle}
          </span>
        )}
      </div>
      {trailing}
      {chevron && onPress && (
        <ChevronRight className="w-4 h-4 text-label-quaternary" />
      )}
    </button>
  );
}
```

### Action Sheet

```typescript
// components/ActionSheet.tsx
interface ActionSheetProps {
  isOpen: boolean;
  onClose: () => void;
  title?: string;
  message?: string;
  actions: Array<{
    label: string;
    destructive?: boolean;
    onPress: () => void;
  }>;
}

export function ActionSheet({
  isOpen,
  onClose,
  title,
  message,
  actions,
}: ActionSheetProps) {
  const [{ y }, api] = useSpring(() => ({ y: 100 }));

  useEffect(() => {
    api.start({ y: isOpen ? 0 : 100 });
  }, [isOpen]);

  return (
    <Portal>
      {/* Backdrop */}
      <animated.div
        className="fixed inset-0 bg-black/40 z-50"
        style={{ opacity: y.to(v => 1 - v / 100) }}
        onClick={onClose}
      />

      {/* Sheet */}
      <animated.div
        className="fixed bottom-0 inset-x-0 z-50 pb-[env(safe-area-inset-bottom)]"
        style={{ transform: y.to(v => `translateY(${v}%)`) }}
      >
        <div className="mx-2 mb-2">
          {/* Action group */}
          <div className="bg-background-groupedSecondary rounded-[14px] overflow-hidden">
            {(title || message) && (
              <div className="px-4 py-3 text-center border-b border-separator">
                {title && <p className="font-semibold">{title}</p>}
                {message && <p className="text-[13px] text-label-secondary">{message}</p>}
              </div>
            )}
            {actions.map((action, i) => (
              <button
                key={i}
                onClick={() => { action.onPress(); onClose(); }}
                className={cn(
                  'w-full py-4 text-[20px] text-center',
                  'active:bg-fill-tertiary',
                  'border-b border-separator last:border-b-0',
                  action.destructive ? 'text-accent-red' : 'text-accent-blue'
                )}
              >
                {action.label}
              </button>
            ))}
          </div>

          {/* Cancel button */}
          <button
            onClick={onClose}
            className="w-full mt-2 py-4 bg-background-groupedSecondary rounded-[14px] text-[20px] font-semibold text-accent-blue active:bg-fill-tertiary"
          >
            Cancel
          </button>
        </div>
      </animated.div>
    </Portal>
  );
}
```

## PWA Configuration

### Manifest

```json
// public/manifest.json
{
  "name": "App Name",
  "short_name": "App",
  "description": "App description",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#007AFF",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "/icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png",
      "purpose": "any maskable"
    },
    {
      "src": "/icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "any maskable"
    }
  ],
  "screenshots": [
    {
      "src": "/screenshots/mobile.png",
      "sizes": "390x844",
      "type": "image/png",
      "form_factor": "narrow"
    }
  ]
}
```

### Viewport & Meta Tags

```typescript
// app/layout.tsx (Next.js)
export const metadata = {
  viewport: {
    width: 'device-width',
    initialScale: 1,
    maximumScale: 1,
    userScalable: false,
    viewportFit: 'cover',
  },
  appleWebApp: {
    capable: true,
    statusBarStyle: 'default',
    title: 'App Name',
  },
  formatDetection: {
    telephone: false,
  },
};
```

## Accessibility

### Reduced Motion Support

```typescript
// hooks/useReducedMotion.ts
export function useReducedMotion() {
  const [reduced, setReduced] = useState(false);

  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)');
    setReduced(mq.matches);
    const handler = (e: MediaQueryListEvent) => setReduced(e.matches);
    mq.addEventListener('change', handler);
    return () => mq.removeEventListener('change', handler);
  }, []);

  return reduced;
}

// Usage in animations
const prefersReduced = useReducedMotion();
const spring = useSpring({
  transform: isOpen ? 'translateY(0)' : 'translateY(100%)',
  config: prefersReduced ? { duration: 0 } : springs.gentle,
});
```

## Key Principles

1. **60fps or nothing**: All animations must maintain 60fps. Use `transform` and `opacity` only.
2. **Touch-first**: Design for touch targets minimum 44x44px.
3. **Safe areas**: Always account for notches, home indicators, and status bars.
4. **Spring physics**: Never use linear/ease animations - use springs for natural feel.
5. **Immediate feedback**: Respond to touches within 100ms with visual feedback.
6. **Gesture continuity**: Allow gestures to interrupt animations naturally.

## References

- `references/hig-patterns.md` - Apple HIG pattern deep dives
- `references/animation-timing.md` - Spring configuration reference
- `references/platform-adaptation.md` - iOS vs Android adaptations
