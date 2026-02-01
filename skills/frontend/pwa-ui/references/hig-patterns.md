# Apple HIG Patterns Reference

## Navigation Patterns

### Hierarchical Navigation

```
Root → Category → Detail → Sub-detail
```

- Use push/pop transitions
- Back button always visible
- Large titles collapse on scroll
- Swipe from left edge to go back

### Flat Navigation

```
Tab 1 | Tab 2 | Tab 3 | Tab 4 | Tab 5
```

- Maximum 5 tabs
- Each tab maintains its own navigation stack
- Tab bar always visible except during focused tasks
- Badge indicators for notifications

### Modal Navigation

```
Full screen modal (slide up)
├── Requires explicit dismiss
├── Used for focused tasks
└── Cancel/Done actions
```

## Content Patterns

### Grouped Content

```
SECTION HEADER
┌─────────────────────────────┐
│ Row 1                    ›  │
├─────────────────────────────┤
│ Row 2                    ›  │
├─────────────────────────────┤
│ Row 3                    ›  │
└─────────────────────────────┘
Section footer text explains the group.
```

### Card Pattern

```
┌─────────────────────────────┐
│ ┌─────┐                     │
│ │ IMG │  Title              │
│ └─────┘  Subtitle           │
│                             │
│ Body text description...    │
│                             │
│ [Action 1]    [Action 2]    │
└─────────────────────────────┘
```

## Feedback Patterns

### Loading States

| State | Pattern |
|-------|---------|
| Initial load | Skeleton screens |
| Action pending | Inline spinner |
| Background refresh | Pull-to-refresh spinner |
| Long operation | Progress bar with percentage |

### Empty States

```
┌─────────────────────────────┐
│                             │
│         [Icon]              │
│                             │
│      No Items Yet           │
│   Add your first item to    │
│      get started.           │
│                             │
│      [Primary Action]       │
│                             │
└─────────────────────────────┘
```

### Error States

- Inline errors below input fields
- Toast notifications for transient errors
- Full screen for critical errors
- Always provide recovery action

## Touch Target Guidelines

| Element | Minimum Size | Recommended |
|---------|--------------|-------------|
| Button | 44x44px | 48x48px |
| List row | 44px height | 56px height |
| Icon button | 44x44px | 44x44px |
| Text input | 44px height | 48px height |

## Visual Hierarchy

### Z-Index Layers

```
1000 - System UI (status bar)
 900 - Alerts, action sheets
 800 - Modals, full-screen overlays
 700 - Navigation bar
 600 - Tab bar
 500 - Floating action buttons
 400 - Cards, elevated content
 300 - Base content
 200 - Background
 100 - Decorative elements
```

### Shadow Elevations

```css
/* Card shadow */
box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);

/* Elevated card */
box-shadow: 0 4px 16px rgba(0, 0, 0, 0.12);

/* Modal shadow */
box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2);

/* Floating button */
box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
```
