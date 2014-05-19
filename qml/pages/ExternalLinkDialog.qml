import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {

    property string url
    property string __browser_type: "webview"


    Column {
        spacing: 2
        width: parent.width

        DialogHeader {
            title: qsTr("Clicked link")
            acceptText: qsTr("Open");
        }

        Label {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeMedium
            color: Theme.highlightColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            text: url
        }

        TextSwitch {
            id: webview
            automaticCheck: false
            text: qsTr("with webview")
            onClicked: {
                webview.checked = true
                browser.checked = false
                __browser_type = "webview"
            }
        }
        TextSwitch {
            id: browser
            automaticCheck: false
            text: qsTr("with default browser")
            onClicked: {
                browser.checked = true
                webview.checked = false
                __browser_type = "buildin"
            }
        }
    }
    Component.onCompleted: {
        // set default as webview
        webview.checked = true
    }

    onAccepted: {
        if (__browser_type === "webview") {
            siteURL = url
        }
        else
            Qt.openUrlExternally(url);
    }
}
