import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: itemsColumn
    width: parent.width
    height: childrenRect.height
    property alias itemsArrayModel: flowRepeater.model
    property alias flowSpacing: flowIt.spacing
    property bool dynTextStrikeOut: false
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
                labelTextStrikeOut: dynTextStrikeOut
                visible: itemsArrayModel.length > 0 && itemsArrayModel[0] !== ""
                labelText: modelData
            }
        }
    }
}
