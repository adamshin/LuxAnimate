//
//  AnimFrameSceneGenerator.swift
//

import Foundation

// How should this work?

// The frame editor should probably generate some kind of
// scene object that's agnostic to the current tool. This
// would tell us the structure of the frame, and give us
// all the drawings we need to load assets for.

// The frame editor would also need to load assets for the
// current selection mask, if one exists. It could do this
// separately from frame generation.

// Once we generate the frame scene, we need to adapt it
// into an editor workspace scene. The frame editor will
// need to work with the tool state to do this. We'll
// replace the active drawing with the tool render buffer.
// We also may add overlays, layer borders, etc.

// Having separate objects to represent the frame scene and
// the workspace scene is the key here, I think.

// Once we load the asset for the active drawing, and copy
// the texture data into the tool's render buffer, maybe we
// should delete that texture from the asset loader. It's
// no longer needed, and will be replaced with a new asset
// as soon as the user makes an edit.

// As the user makes edits, we could update our frame scene
// object. We could store the asset ID for the new asset,
// maybe regenerate the full list of asset IDs, and update
// the asset loader. Before doing this, we could also
// insert the new asset texture into the asset loader so it
// doesn't have to be loaded from disk. So the asset loader
// will always stay in sync with the editor. If we need to
// edit the selection mask, it could happen the same way.

// This also answers the question of how to handle assets
// when reloading the frame editor. If the asset loader is
// always in sync, there's no need to extract textures from
// the frame editor manually.

// The objects I'll be using are FrameSceneGraph and 
// EditorWorkspaceSceneGraph.

// This file is no longer necessary, except for this note.
