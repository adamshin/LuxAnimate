# LuxAnimate

A frame-by-frame animation app for iPad.

## Platform & Tech

- **Platform:** iOS/iPadOS (Swift, UIKit)
- **Rendering:** Metal for drawing canvas and compositing
- **Storage:** File-based with JSON manifests, assets stored as separate files

## Editor Structure

The app has two levels of editing:

### Main Editor (Project Level)
- Preview window showing composited scene
- Timeline for arranging layers (similar to video editors like Final Cut)
- No drawing tools - this is for composition and timing
- Currently minimal UI, needs to be built out

### Frame Editor (Layer Level)
- Opened by selecting a layer from the main editor
- Drawing tools (brush, eraser) with Apple Pencil support
- Frame-by-frame animation workflow
- Timeline for managing frames within the animation layer

## Data Model

```
Project
└── Scenes (currently just one per project)
    └── Layers
        └── Drawings (sparse - only at keyframes, hold until next)
```

- **Project.Manifest:** Top-level project metadata, references to scenes
- **Scene.Manifest:** Frame count, background color, layers with transforms
- **Drawings:** Each has a frameIndex, fullAssetID (hi-res), thumbnailAssetID

Assets are content-addressed files (UUIDs) stored in the project directory.

## Rendering System

### Frame Scene Graph
Each frame is represented as a `FrameSceneGraph` - a snapshot of what to render:
- Which drawing is visible on each layer at that frame
- Layer transforms, alpha, compositing order

### Fingerprint-Based Caching
- Each frame's render manifest is hashed (XXHash) to create a fingerprint
- Identical frames (e.g., holds) share the same fingerprint
- Cache lookup: fingerprint → rendered image
- Automatic invalidation: content changes → new fingerprint

### Render Preview (WIP)
Scaffolding exists for pre-rendering frame previews for smooth scrubbing. The fingerprint system is implemented; the actual rendering and caching needs completion.

## Undo System

Full undo/redo with 50-level history:
- Each edit creates a history entry storing the old manifest + orphaned assets
- Assets moved (not deleted) to history, allowing full restoration
- Stored in Caches directory

## Key Directories

```
LuxAnimate/
├── Models/          # Data structures (Project, Scene, FrameSceneGraph)
├── Logic/           # Business logic
│   ├── Project Editing/
│   ├── Frame Scene Graph/
│   ├── Render Preview/
│   └── Brush Library/
├── Views/
│   ├── Editor/      # Main project/scene editor
│   └── Animation Editor/  # Frame editor for drawing
└── Packages/        # Local Swift packages (BrushEngine, Geometry, etc.)
```

## Work In Progress

- **Animation Editor 2:** Reworking the frame editor layout with a drawer-based timeline and better tool UI placement. Partially complete - layout done, rendering/tool state commented out.
- **Main Editor:** Needs preview window and arrangement timeline built out.
- **Tool Settings UI:** Popup menus for brush settings (size, smoothing). Menu system exists, needs tool-specific content views.
