import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: filterPage
    anchors.fill: parent

    onStatusChanged: {
        // When leaving page change selections only if those are changed
        if (status === PageStatus.Deactivating) {
            var change = false
            if (closedSwitch.checked !== closedQuestionsFilter) {
                closedQuestionsFilter = closedSwitch.checked
                change = true
            }
            if (answeredSwitch.checked !== answeredQuestionsFilter) {
                answeredQuestionsFilter = answeredSwitch.checked
                change = true
            }
            if (unansweredSwitch.checked !== unansweredQuestionsFilter) {
                unansweredQuestionsFilter = unansweredSwitch.checked
                change = true
            }
            if (change) {
                refresh()
            }
        }
    }

    SilicaFlickable
    {
        anchors.fill: parent

        Column {
            spacing: 1
            anchors.fill: parent
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            PageHeader {
                title: qsTr("Filter questions")
            }

            Rectangle{
                id: middleRectangle1
                gradient: Gradient {
                    GradientStop { position: 0.0; color: "#333333" }
                    GradientStop { position: 1.0; color: "#777777" }
                }
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
                height: 3
                width: parent.width-64

            }
            Label {
                width: parent.width-70
                font.pixelSize: Theme.fontSizeSmall
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                text: qsTr("Select filters for questions")
            }
            TextSwitch {
                id: closedSwitch
                checked: closedQuestionsFilter
                description: qsTr("List also closed questions")
                text: qsTr("Closed questions")
            }
            TextSwitch {
                id: answeredSwitch
                checked: answeredQuestionsFilter
                description: qsTr("List also questions having accepted answers")
                text: qsTr("Answered questions")
            }
            TextSwitch {
                id: unansweredSwitch
                checked: unansweredQuestionsFilter
                description: qsTr("List only questions having no answers yet. (Overrides 'Answered questions' selection)")
                text: qsTr("Only unanswered questions")
            }
        }
    }
}
