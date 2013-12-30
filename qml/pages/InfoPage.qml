import QtQuick 2.0
import Sailfish.Silica 1.0
import "../../js/askbot.js" as Askbot
Page {
    anchors.fill: parent
    id: infoPage
    property int group: 0
    property int users: 0
    property int questions: 0
    property int answers: 0
    property int comments: 0
    ListModel
    {
        id: modelInfo
    }
    PageHeader {
        title: "Jolla Together Info"
    }
    Column
    {
        anchors.centerIn: parent
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium

        Repeater {
            model: modelInfo
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: item
            }
        }
    }

    Component.onCompleted: {
        modelInfo.clear()
        Askbot.get_info(modelInfo)
    }
}
