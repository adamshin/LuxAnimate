//
//  SceneEditorModel.swift
//

struct SceneEditorModel {
    
    var projectManifest: Project.Manifest
    var sceneRef: Project.SceneRef
    var sceneManifest: Scene.Manifest
    
    var availableUndoCount: Int
    var availableRedoCount: Int
    
}
