import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: itemsColumn
    width: parent.width
    height: childrenRect.height
    property alias itemsArrayModel: flowRepeater.model
    property alias flowSpacing: flowIt.spacing
    anchors.leftMargin: Theme.paddingMedium
    anchors.rightMargin: Theme.paddingMedium

    Flow {
        id: flowIt
        spacing: 5
        width: parent.width
        height: childrenRect.height
        Repeater {
            id: flowRepeater
            width: parent.width
            anchors.left: parent.left
            model: itemsArrayModel
            delegate:
                DynamicTextRectangle {
                id: dynamicRec
                visible: itemsArrayModel.length > 0 && itemsArrayModel[0] !== ""
                labelText: modelData
            }
        }
    }
}
