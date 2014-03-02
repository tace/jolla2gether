import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    CreditsModel {id: credits}
    Column{
        id: column1
        anchors.fill: parent
        anchors.topMargin: Theme.paddingLarge * 3
        spacing: 15

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
            text: appname+" v"+version
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
            width: parent.width-100
            text: "Release notes for version "+version
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: Qt.openUrlExternally("https://github.com/tace/jolla2gether/wiki/ReleaseNotes#wiki-"+version2WikiIndex(version))
        }
        Button {
            id: licenseButton
            width: parent.width-100
            text: "License "+license
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: pageStack.push(Qt.resolvedUrl("LicensePage.qml"))
        }
    }

    function version2WikiIndex(version) {
        return version.replace(/\./g, "")
    }
}
