//
//  HomeInteractor+Editor.swift
//  VideoMerger
//
//  Created by đào sơn on 04/01/2024.
//

import Foundation

extension HomeInteractor: EditorListener {
    func editorWantToDismiss() {
        self.router?.dismissEditor()
    }
}
