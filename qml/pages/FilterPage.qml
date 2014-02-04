import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: filterPage
    anchors.fill: parent

    onStatusChanged: {
        // When leaving page change selections only if those are changed
        if (status === PageStatus.Deactivating) {
            var change = false
            if (closedSwitch.checked !== questionsModel.closedQuestionsFilter) {
                questionsModel.closedQuestionsFilter = closedSwitch.checked
                change = true
            }
            if (answeredSwitch.checked !== questionsModel.answeredQuestionsFilter) {
                questionsModel.answeredQuestionsFilter = answeredSwitch.checked
                change = true
            }
            if (unansweredSwitch.checked !== questionsModel.unansweredQuestionsFilter) {
                questionsModel.unansweredQuestionsFilter = unansweredSwitch.checked
                change = true
            }
            if (change) {
                questionsModel.refresh()
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
                checked: questionsModel.closedQuestionsFilter
                description: qsTr("List also closed questions")
                text: qsTr("Closed questions")
            }
            TextSwitch {
                id: answeredSwitch
                checked: questionsModel.answeredQuestionsFilter
                description: qsTr("List also questions having accepted answers")
                text: qsTr("Answered questions")
            }
            TextSwitch {
                id: unansweredSwitch
                checked: questionsModel.unansweredQuestionsFilter
                description: qsTr("List only questions having no answers yet. (Overrides 'Answered questions' selection)")
                text: qsTr("Unanswered questions")
            }
            Rectangle{
                id: bottomRec
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
                font.pixelSize: Theme.fontSizeTiny
                font.italic: true
                color: Theme.secondaryHighlightColor
                width: filterPage.width
                wrapMode: Text.Wrap
                text: qsTr("Note: Default selections are listing ALL questions. 'Unanswered questions' filter is global among all questions, but 'Answered/Closed questions' filters are applied only to currently loaded page's questions (API does not support global). All selected filters persists untill changed from this page")
            }
        }
    }
}
