# My Agenda - Application Specification

## Overview
A **Flutter-based Android application** for managing TODOs, notes, and schedules using markdown files with an interactive tree view interface. Primary designed for Android mobile devices with touch-first interactions.

**Platform Focus**: Android (Mobile-first)
**Theme**: Yellow primary color

---

## Core Architecture

### Data Model
- **Format**: Markdown files (.md) mapped to outline trees
- **Structure**: 1 markdown file = 1 outline tree
- **Nesting**: Unlimited depth and unlimited width
- **Storage**: Local filesystem in app documents directory

### Outline Structure
```markdown
Project Name:
  - TODO First item
    - Child item
      - Grandchild item
  - NEXT Second item with state
    - Nested child
  - DONE Completed item
  - Regular note without state
```

---

## UI Layout (Android-Optimized)

### Navigation Drawer
Side drawer for file management and navigation, accessible via hamburger menu or swipe gesture.

#### Drawer Actions (Top Section)
1. **Agenda** - View scheduled items and deadlines
2. **Global Search** - Search across all markdown files  
3. **Journal** - Daily notes and journal entries view
4. **Calendar** - Calendar view with scheduled items
5. **Settings** - Application configuration

#### Drawer File List
- List of all markdown files in the workspace
- Shows file names (without .md extension)
- Current/active file highlighted
- Tap to open file and close drawer

---

### Main Body (Full Screen)

#### Tree View
Interactive nested outline display optimized for touch:

**Visual Structure:**
```
● First item
  ● Child item
    ● Grandchild item
● Second item
  ● Nested child
● Third item
```

**Features:**
- **Unlimited depth**: Support deeply nested hierarchies
- **Unlimited width**: No limit on children per parent
- **Bullet points**: Visual indicator for each tree node
- **Text fields**: Each node is an editable text field
- **Focus**: Visual indicator for currently selected node
- **Collapsing/Expanding**: Nodes can be collapsed/expanded
- **Visual indentation**: Clear hierarchy representation

**Interactions:**
- **Tap text**: Select/focus the node (default action)
- **Tap bullet**: Cycle TODO state (TODO → NEXT → DONE → none)
- **Long press**: Reveal context menu with actions
- **Swipe gestures**: Quick actions (configurable)

---

### Bottom Action Bar (FAB + Menu)
Android-style floating action button and bottom menu for quick actions.

#### Floating Action Button (FAB)
- **Primary**: Add new item at current level
- **Long press**: Add child item

#### Bottom Sheet Menu (accessible via toolbar or swipe up)
1. **Indent** - Increase nesting level
2. **Dedent** - Decrease nesting level  
3. **Move Up** - Reorder item up
4. **Move Down** - Reorder item down
5. **Delete** - Remove current item
6. **Toggle Fold** - Collapse/expand current node

---

## TODO Management

### TODO States
- **Configurable state machine**
- **Default states**: `TODO` → `NEXT` → `DONE`
- **Cycling**: Tap bullet point cycles through configured states
- **Colors**: Each state has configurable color (Yellow theme compatible)
- **Custom states**: Support for arbitrary state names and colors

### State Configuration Example
```yaml
todo_states:
  - name: TODO
    color: #FFD700  # Yellow
    next: NEXT
  - name: NEXT
    color: #FFA500  # Orange
    next: DONE
  - name: DONE
    color: #32CD32  # Green
    next: TODO
```

---

## Touch Interactions (Android-First)

### Navigation
- **Tap item** - Select/focus
- **Swipe left** - Delete item (with confirmation)
- **Swipe right** - Indent/Dedent toggle
- **Long press** - Context menu

### Editing
- **Tap text field** - Edit mode
- **Enter/Done on keyboard** - New sibling
- **Backspace on empty** - Delete item
- **Double tap bullet** - Cycle TODO state

### View
- **Swipe from left edge** - Open drawer
- **Tap outside drawer** - Close drawer
- **Pinch** - Collapse/expand all (optional)
- **Pull down** - Refresh file list

---

## Special Features

### Agenda View
- Shows all TODO items with deadlines or scheduled dates
- Filters by date ranges
- Groups by date
- Shows overdue items

### Journal View
- Daily note entries
- Chronological view
- Quick entry for current date
- Links to outline items

### Calendar View
- Month view (primary for mobile)
- Shows scheduled TODOs and deadlines
- Color-coded by TODO state
- Tap date to jump to items

### Global Search
- Full-text search across all markdown files
- Search in item text and TODO states
- Results show file + context
- Tap result to open file at location

### Refiling
- Move items between files
- Quick refile to journal/agenda
- Preserve hierarchy when moving

---

## File Format Specification

### TaskPaper Format (Primary)
Outline uses TaskPaper-style format:

```markdown
Project Name:
  - TODO Task item @today
  - Task 2 @done(2024-03-07)
  Subproject:
    - Nested task
    - Another task

Another Project:
  - Task here
```

### Parsing Rules
- **Projects**: Lines ending with `:` (no bullet)
- **Tasks**: Lines starting with `- ` or `* `
- **TODO states**: Optional prefix (TODO, NEXT, DONE, etc.)
- **Tags**: `@tag` or `@tag(value)` format
- **Indentation**: 2 spaces indicates nesting level
- **Empty lines**: Preserved as spacing

---

## State Management

### Application State
- Current file path
- Focused node ID
- Expanded/collapsed state (persisted per file)
- TODO state configuration
- Drawer visibility
- View mode (Agenda/Journal/Calendar/Outline)

### Data Persistence
- Auto-save on changes (2-second debounce)
- Save collapsed/expanded state
- Save TODO state configuration
- Android shared preferences for settings

---

## Android-Specific Considerations

### Screen Sizes
- **Phone**: Single column, full-screen drawer
- **Tablet**: Persistent drawer on left, content on right
- **Foldable**: Adapt layout based on unfolded state

### Input Methods
- **Touch**: Primary interaction method
- **Keyboard**: Optional hardware keyboard support
- **Stylus**: Supported for handwriting (future)

### Platform Integration
- **Share**: Share outlines via Android share sheet
- **Widgets**: Home screen widget for quick capture (future)
- **Notifications**: Deadline reminders (future)
- **Backup**: Auto-backup to Google Drive (future)

---

## Theme (Yellow Primary)

### Color Palette
- **Primary**: Yellow (#FFD700 or #FFC107)
- **Primary Container**: Light yellow (#FFF9C4)
- **Secondary**: Amber (#FFB300)
- **Surface**: White/Light cream
- **Background**: Very light yellow tint
- **TODO states**: Yellow-adjacent colors

---

## Future Extensibility

The architecture supports:
- Additional drawer actions
- Custom bottom menu items
- Plugin system for custom TODO states
- Theme customization (beyond yellow)
- Cloud sync (Google Drive, Dropbox)
- Export formats (PDF, HTML, etc.)
- iOS port (cross-platform Flutter)
