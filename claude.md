# LuxAnimate

A frame-by-frame animation app for iPad.

## Platform

- iOS/iPadOS, Swift, UIKit
- Metal for rendering
- Apple Pencil for drawing

## Editor Structure

Two levels of editing:

- **Main Editor:** Arrange and composite layers on a timeline (like a video editor). No drawing here.
- **Frame Editor:** Draw frame-by-frame within an animation layer. Brush/eraser tools, per-layer timeline.

## Data Model

```
Project → Scene → Layers → Drawings
```

- Drawings are sparse keyframes that hold until the next keyframe
- Assets (images) are content-addressed files with UUID filenames
- JSON manifests describe project structure and reference assets

## Rendering

- Each frame is represented as a scene graph (layers, transforms, asset references)
- Frames are fingerprinted (XXHash) for render caching - identical frames share a fingerprint
- Metal-based compositing

## Packages

- **BrushEngine:** Handles brush stroke processing, stamp rendering, and canvas compositing. Includes stroke smoothing, pressure/tilt handling, and various brush behaviors.
- **Geometry:** Vector/matrix math, SIMD-backed
- **Color:** Color types and conversions
