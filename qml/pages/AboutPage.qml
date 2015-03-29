import QtQuick 2.0
import Sailfish.Silica 1.0
import "../models"

Page {
    allowedOrientations: Orientation.All
    CreditsModel {id: credits}

    Flickable {
        width: parent.width
        height: parent.height - Theme.paddingLarge * 3
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge * 3
        contentHeight: column1.height

        Column{
            id: column1
            spacing: 15
            width: parent.width

            Image{
                source: appicon
                height: 128
                width: 128
                fillMode: Image.PreserveAspectFit
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }
            Label {
                font.pixelSize: Theme.fontSizeMedium
                text: appname+" v"+APP_VERSION
                anchors.horizontalCenter: parent.horizontalCenter

            }
            Rectangle{
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
                width: 360
                font.pixelSize: Theme.fontSizeMedium
                text: "Copyright 2013-2014 by\nMike7b4 <mike@7b4.se>"
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
            }

            Repeater{
                model: credits
                Label  {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: title
                    font.pixelSize: Theme.fontSizeTiny
                }
            }
            Rectangle{
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
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: "https://github.com/tace/jolla2gether"
            }
            Button {
                id: releaseNotesButton
                text: "Release notes"
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: Qt.openUrlExternally("https://github.com/tace/jolla2gether/wiki/ReleaseNotes")
            }
            Button {
                id: licenseButton
                text: "License "+license
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("LicensePage.qml"))
            }
            Label {
                width: parent.width-70
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
                height: 500
                wrapMode: Text.WordWrap
                text: qsTr("Jolla Together is a client application for https://together.jolla.com site which can be used to browse questions and users and see main statistics of questions.
 \nNOTE: jolla2gether is using webview component where you can login with your own together.jolla.com credentials. When logged in, be carefull concerning actions on page to avoid accidental cliks.")
            }
        }
    }
}
