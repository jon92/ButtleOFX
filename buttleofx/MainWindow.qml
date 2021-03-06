import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQml 2.1

import QuickMamba 1.0

import "gui/graph/qml"
import "gui/viewer/qml"
import "gui/paramEditor/qml"

ApplicationWindow {
    width: 1200
    height: 800

    //TopFocusHandler {
    //    //anchors.fill: parent
    //}

    Keys.onPressed: {

        // Graph toolbar
        if (event.key == Qt.Key_Delete) {
           _buttleManager.deleteSelection();
        }
        if ((event.key == Qt.Key_Z) && (event.modifiers & Qt.ControlModifier)) {
            if(_buttleManager.canUndo) {
                _buttleManager.undo();
            }
        }
        if ((event.key == Qt.Key_Y) && (event.modifiers & Qt.ControlModifier)) {
            if(_buttleManager.canRedo) {
                _buttleManager.redo();
            }
        }
        if ((event.key == Qt.Key_D) && (event.modifiers & Qt.ControlModifier)){
            if (!_buttleData.currentSelectedNodeWrappers.isEmpty()) {
                _buttleManager.nodeManager.duplicationNode()
            }
        }
        if ((event.key == Qt.Key_C) && (event.modifiers & Qt.ControlModifier)){
            if (!_buttleData.currentSelectedNodeWrappers.isEmpty()) {
                _buttleManager.nodeManager.copyNode()
            }
        }
        if ((event.key == Qt.Key_V) && (event.modifiers & Qt.ControlModifier)){
           if (_buttleData.canPaste) {
                _buttleManager.nodeManager.pasteNode();
           }
        }
        if ((event.key == Qt.Key_X) && (event.modifiers & Qt.ControlModifier)){
            if (!_buttleData.currentSelectedNodeWrappers.isEmpty()) {
                _buttleManager.nodeManager.cutNode()
            }
        }
        if ((event.key == Qt.Key_S) && (event.modifiers & Qt.ControlModifier)){
            if(_buttleData.graphCanBeSaved) {
                graphEditor.doAction("save")
            }
        }
        if ((event.key == Qt.Key_L) && (event.modifiers & Qt.ControlModifier)){
            graphEditor.doAction("load")
        }

        // Viewer
        if ((event.key == Qt.Key_1) && (event.modifiers & Qt.KeypadModifier)){
            player.changeViewer(1)
        }
        if ((event.key == Qt.Key_2) && (event.modifiers & Qt.KeypadModifier)){

            player.changeViewer(2)
        }
        if ((event.key == Qt.Key_3) && (event.modifiers & Qt.KeypadModifier)){
            player.changeViewer(3)
        }
        if ((event.key == Qt.Key_4) && (event.modifiers & Qt.KeypadModifier)){
            player.changeViewer(4)
        }
        if ((event.key == Qt.Key_5) && (event.modifiers & Qt.KeypadModifier)){
            player.changeViewer(5)
        }
        if ((event.key == Qt.Key_6) && (event.modifiers & Qt.KeypadModifier)){
            player.changeViewer(6)
        }
        if ((event.key == Qt.Key_7) && (event.modifiers & Qt.KeypadModifier)){
            player.changeViewer(7)
        }
        if ((event.key == Qt.Key_8) && (event.modifiers & Qt.KeypadModifier)){
            player.changeViewer(8)
        }
        if ((event.key == Qt.Key_9) && (event.modifiers & Qt.KeypadModifier)){
            player.changeViewer(9)
        }
        // Assign the mosquito to the selected node
        if ((event.key == Qt.Key_Return)||(event.key == Qt.Key_Enter)) {
            var selectedNodes = _buttleData.currentSelectedNodeWrappers

            // we assign the mosquito only if there is only one node selected
            if(selectedNodes.count == 1) {
                var node = selectedNodes.get(0)
                _buttleData.currentViewerNodeWrapper = node
                _buttleData.currentViewerFrame = 0
                _buttleData.assignNodeToViewerIndex(node, 0)
                _buttleEvent.emitViewerChangedSignal()
            }
        }

        // Player
        if (event.key == Qt.Key_Space && player.node != null) {
            if(player.isPlaying) {
                player.doAction("pause");
            }
            else {
                player.doAction("play");
            }
        }

        // Send the selected node on the parameters editor
        if ((event.key == Qt.Key_P)) {
            var selectedNodes = _buttleData.currentSelectedNodeWrappers

            // we send the node only if there is only one node selected
            if(selectedNodes.count == 1) {
                var node = selectedNodes.get(0)
                _buttleData.currentParamNodeWrapper = node
            }
        }
    }

    menuBar: MenuBar {
        Menu {
            title: "File"

            MenuItem {
                text: "Load"
                shortcut: "Ctrl+L"
                onTriggered: graphEditor.doAction("load")
            }

            MenuItem {
                text: "Save"
                shortcut: "Ctrl+S"
                onTriggered:
                    if(_buttleData.graphCanBeSaved) {
                        graphEditor.doAction("save")
                    }
            }

            MenuSeparator { }

            MenuItem {
                text: "Exit"
                onTriggered: Qt.quit()
            }
        }

        Menu {
            title: "Edit"
            
            MenuItem {
                text: "Undo"
                shortcut: "Ctrl+Z"
                onTriggered:
                    if(_buttleManager.canUndo) {
                        _buttleManager.undo();
                    }
            }

            MenuItem {
                text: "Redo"
                shortcut: "Ctrl+Y"
                onTriggered:
                    if(_buttleManager.canRedo) {
                        _buttleManager.redo();
                    }
            }

            MenuSeparator { }

            MenuItem {
                text: "Copy"
                shortcut: "Ctrl+C"
                onTriggered:
                    if(!_buttleData.currentSelectedNodeWrappers.isEmpty()) {
                        _buttleManager.nodeManager.copyNode()
                    }
            }

            MenuItem {
                text: "Paste"
                shortcut: "Ctrl+V"
                onTriggered:
                    if(_buttleData.canPaste) {
                        _buttleManager.nodeManager.pasteNode();
                    }
            }

            MenuItem {
                text: "Cut"
                shortcut: "Ctrl+X"
                onTriggered:
                    if (!_buttleData.currentSelectedNodeWrappers.isEmpty()) {
                        _buttleManager.nodeManager.cutNode()
                    }
            }

            MenuItem {
                text: "Duplicate"
                shortcut: "Ctrl+D"
                onTriggered:
                    if (!_buttleData.currentSelectedNodeWrappers.isEmpty()) {
                        _buttleManager.nodeManager.duplicationNode()
                    }
            }

            MenuItem {
                text: "Delete"
                onTriggered: _buttleManager.deleteSelection()
            }
        }

        Menu {
            id: nodesMenu
            title: "Nodes"

            Instantiator {
                model: _buttleData.pluginsIdentifiers
                MenuItem {
                    text: object
                    onTriggered: _buttleManager.nodeManager.creationNode(object, 0, 0)
                }
                onObjectAdded: nodesMenu.insertItem(index, object)
                onObjectRemoved: nodesMenu.removeItem(object)
            }
        }
    }

    //this rectangle represents the zone under the menu, it allows to define the anchors.fill and margins for the SplitterRow
    Rectangle {
        id: modulsContainer
        width: parent.width
        height: parent.height - y
        color: "#353535"

        SplitView {
            anchors.fill: parent
            anchors.margins: 3
            //handleWidth: 3
            orientation: Qt.Horizontal

            SplitView {
                width: 0.7*parent.width
                height: parent.height
                //handleWidth: 3
                orientation: Qt.Vertical
                //Splitter.expanding: true // obligatory to allow to have the minimumWidth

                Player {
                    //Splitter.minimumHeight: 0
                    //Splitter.expanding: true
                    id: player
                    width: parent.width
                    height: 0.5*parent.height
                    node: _buttleData.currentViewerNodeWrapper
                }

                GraphEditor {
                    id: graphEditor
                    //Splitter.minimumHeight: 0
                    width: parent.width
                    height: 0.5*parent.height
                }
            }

            ParamEditor {
                //Splitter.minimumWidth: 0 
                width: 0.3*parent.width
                params: _buttleData.currentParamNodeWrapper ? _buttleData.currentParamNodeWrapper.params : null
                currentParamNode: _buttleData.currentParamNodeWrapper
            }
        }
    }
}
