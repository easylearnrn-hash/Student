# Group Notes: Reorder & Search Features

## Overview
Added comprehensive search and drag-and-drop reordering capabilities to the Group Notes Manager in Student-Portal-Admin.html.

## New Features

### 1. **Global Search** 🔍
- **Location**: Top of Group Notes tab, above group tabs
- **Functionality**: 
  - Searches across ALL systems and notes simultaneously
  - Searches in: note titles, content, metadata (PDF names, dates), and folder names
  - Auto-expands folders with matching results
  - Hides folders/notes that don't match search term

### 2. **Per-Folder Search** 🔍
- **Location**: Inside each expanded folder
- **Functionality**:
  - Searches only within that specific system/folder
  - Same search targets: titles, content, metadata
  - Independent from global search

### 3. **Reorder Mode** ⇅
- **Location**: "⇅ Reorder" button next to global search
- **Functionality**:
  - Click to enter reorder mode (button changes to "✓ Done")
  - Drag handles (⋮⋮) appear on folders and notes
  - Drag folders to reorganize system order
  - Drag notes within folders to reorganize note order
  - Changes persist to database automatically
  - Click "✓ Done" to exit reorder mode

## Usage Instructions

### Searching All Notes
1. Type in the "🔍 Search all notes across all systems..." field
2. All folders expand automatically showing matching notes
3. Non-matching items are hidden
4. Clear search to show everything again

### Searching Within a System
1. Expand any folder (e.g., Cardiovascular, Respiratory)
2. Type in the folder's search box "🔍 Search in [System Name]..."
3. Only notes in that folder are filtered
4. Works independently of global search

### Reordering Folders (Systems)
1. Click the "⇅ Reorder" button
2. Grab the ⋮⋮ handle to the left of any folder name
3. Drag up or down to new position
4. Release to drop
5. Order saves automatically to database
6. Click "✓ Done" when finished

### Reordering Notes Within a Folder
1. Click the "⇅ Reorder" button
2. Expand the folder containing notes you want to reorder
3. Grab the ⋮⋮ handle to the left of any note title
4. Drag up or down within the same folder
5. Release to drop
6. Order saves automatically to database
7. Click "✓ Done" when finished

## Database Changes

### Migration Required
Run `add-sort-order-to-notes.sql` in Supabase SQL editor to add:
- `sort_order` column to `note_folders` table
- `sort_order` column to `note_assignments` table
- Indexes for performance
- Initial sequential ordering based on creation date

### New Columns
```sql
-- note_folders
sort_order INTEGER DEFAULT 0

-- note_assignments  
sort_order INTEGER DEFAULT 0
```

## Technical Details

### CSS Classes
- `.notes-controls` - Container for search + reorder button
- `.search-notes` - Global search input
- `.folder-search` - Per-folder search input
- `.toggle-reorder-btn` - Reorder mode button
- `.drag-handle` - Draggable grip icon (⋮⋮)
- `.reorder-mode` - Applied to container when reorder is active
- `.dragging` - Applied to element being dragged
- `.drag-over` - Applied to drop target

### JavaScript Functions
- `filterAllNotes()` - Global search filter
- `filterFolderNotes(folderId)` - Per-folder search filter
- `toggleReorderMode()` - Enable/disable reorder mode
- `initializeFolderDragDrop()` - Set up drag-drop event listeners
- `updateFolderOrder()` - Save folder order to database
- `updateNoteOrder(container)` - Save note order to database

### Drag-Drop Events
- `handleFolderDragStart/End` - Folder drag lifecycle
- `handleFolderDragOver/Drop` - Folder drop targets
- `handleNoteDragStart/End` - Note drag lifecycle
- `handleNoteDragOver/Drop` - Note drop targets

## User Experience

### Visual Feedback
- Drag handles (⋮⋮) only visible in reorder mode
- Blue border on drop targets during drag
- Semi-transparent dragged elements
- Button changes color when active
- Auto-expand folders with search matches

### Performance
- Database updates happen asynchronously after each drop
- No page reload required
- Expanded state preserved during reorders
- Search is instant (client-side filtering)

## Notes
- Reorder only works when "⇅ Reorder" button is active
- Search and reorder can be used together
- Drag-drop limited to mouse/trackpad (no touch support yet)
- Each group maintains independent note order
- Folder order is global across all groups
