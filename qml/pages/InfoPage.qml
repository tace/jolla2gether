import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: infoPage
    anchors.fill: parent
    allowedOrientations: Orientation.All
    PageHeader {
        title: "Jolla Together Info"
    }
    Rectangle {
        id: infoRec
        anchors.centerIn: parent
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        color: "transparent"
        smooth: true
        //border.width: 1
        width: 260
        height: 230
        radius: 10
        Column
        {
            id: infoCol
            anchors.fill: parent
//            Repeater {
//                model: infoModel
//                Label {
//                    anchors.horizontalCenter: parent.horizontalCenter
//                    text: item
//                }
//            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Groups: " + infoModel.groups
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Users: " + infoModel.users
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Questions: " + infoModel.questions
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Answers: " + infoModel.answers
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Comments: " + infoModel.comments
            }
        }
    }

    Component.onCompleted: {
        infoModel.get_info()
    }
}
