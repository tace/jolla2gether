import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    property alias feedRepeater: commentsRepeater
    property string buttonLabelText: ""
    property bool buttonActivated: false
    property var repeaterModel: null
    property bool buttonVisible: true
    property bool modelReady: false
    property Component repeaterDelegate
    signal buttonPressed
    signal sortAscPressed
    signal sortDescPressed

    width: parent.width
    height: childrenRect.height
    anchors.left: parent.left
    anchors.right: parent.right

    onButtonActivatedChanged: {
        if (buttonActivated) {
            areaRec.color = Theme.highlightColor
            buttonText.font.bold = true
        }
        else
        {
            areaRec.color = "transparent"
            buttonText.font.bold = false
        }
    }

    Rectangle {
        id: areaRec
        width: parent.width
        height: arrowButton.height
        color: "transparent"
        border.width: 0
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: Theme.secondaryHighlightColor }
        }
        MouseArea {
            id: commentsClicker
            anchors.fill: parent
            enabled: buttonVisible
            width: parent.width
            height: parent.width

            onPressed: {
                buttonText.font.bold = true
            }
            onExited: {
                buttonText.font.bold = false
            }
            onClicked: {
                buttonPressed()
            }

            Image {
                id: arrowButton
                visible: buttonVisible
                source: "image://theme/icon-m-down"
                anchors.leftMargin: Theme.paddingMedium
                rotation: buttonActivated > 0 ? 0 : -90
                anchors.left: parent.left
                Behavior on rotation { NumberAnimation { duration: 300; } }
            }
            BusyIndicator {
                id: busyIndicator
                size: BusyIndicatorSize.Small
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingMedium
                running: !modelReady
            }
            Label {
                id: buttonText
                z: 1
                anchors.centerIn: parent
                font.pixelSize: Theme.fontSizeMedium
                text: buttonLabelText
            }
        }
    }

    Item {
        width: 1
        height: Theme.paddingExtraLarge
    }
    ComboBox {
        id: sortingOrder
        visible: buttonActivated && repeaterModel.count > 1 && modelReady
        width: parent.width
        label: qsTr("Sort by")
        currentIndex: 0
        menu: ContextMenu {
            MenuItem {
                text: qsTr("oldest first")
                onClicked: {
                    sortAscPressed()
                    sortingOrder.currentIndex = 0
                }
            }
            MenuItem {
               text: qsTr("newest first")
               onClicked: {
                   sortDescPressed()
                   sortingOrder.currentIndex = 1
               }
            }
        }
    }
    Separator {
        width: parent.width
        horizontalAlignment: Qt.AlignCenter
        color: Theme.secondaryHighlightColor
        height: 1
    }

    Item {
        width: 1
        height: Theme.paddingExtraLarge
    }

    Repeater {
        id: commentsRepeater
        visible: buttonActivated
        width: parent.width
        height: childrenRect.height
        anchors.left: parent.left
        anchors.right: parent.right
        model: buttonActivated ? repeaterModel : ListModel
        clip: true
        delegate: repeaterDelegate
        onItemAdded: {

            if (rssFeedModel.pageSizeAmountItemsRead(repeaterModel, index)) {
                urlLoading = false
                endTime = Date.now()
                console.log("AnswersAndComments load time: " + (endTime - startTime))
            }
        }
    }
}
