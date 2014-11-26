import QtQuick 2.0
import Sailfish.Silica 1.0

Row {
    id: qTypeSelector
    anchors.right: parent.right
    anchors.left: parent.left
    width: parent.width
    height: childrenRect.height
    z: 1
    anchors.leftMargin: Theme.paddingMedium
    anchors.rightMargin: Theme.paddingMedium

    Item {
        id: filler
        width: parent.width - qTypeSelectionBox.width
        height: 1
    }
    ComboBox {
        id: qTypeSelectionBox
        width: parent.width / 1.9
        currentIndex: 0
        label: qsTr("Filter:")
        description: ""

        menu: ContextMenu {
            MenuItem {
                id: authorQuestions
                text: qsTr("author")
                font.pixelSize: Theme.fontSizeSmall
                onClicked: {
                    qTypeSelectionBox.description = ""
                    questionsModel.userIdSearchFilterType = questionsModel.userIdSearchFilter_AUTHOR_QUESTIONS
                    questionsModel.refresh()
                }
            }
            MenuItem {
                id: answeredQuestions
                text: qsTr("answered")
                font.pixelSize: Theme.fontSizeSmall
                onClicked: {
                    qTypeSelectionBox.description = qsTr("excluding wikiposts")
                    questionsModel.userIdSearchFilterType = questionsModel.userIdSearchFilter_ANSWERED_QUESTIONS
                    questionsModel.refresh()
                }
            }
        }
    }
}
