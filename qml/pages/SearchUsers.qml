import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: searchPage
    allowedOrientations: Orientation.All
    property string newSearchString: ""
    property string searchUrlBase: "https://together.jolla.com/users/?t=user&query="

    SilicaFlickable {
        anchors.fill: parent

        DialogHeader {
            id: header;
            title: qsTr("User search");
            acceptText: qsTr("Apply");
        }

        SearchField {
            id: searchBox
            anchors.top: header.bottom
            placeholderText: qsTr("Search")
            width: parent.width
            text: ""
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            EnterKey.enabled: text.length > 0
            EnterKey.iconSource: "image://theme/icon-m-search"
            onTextChanged: {
                newSearchString = searchBox.text
            }
            Keys.onReturnPressed: {
                makeSearch()
            }
        }

        Rectangle{
            id: bottomRec
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#333333" }
                GradientStop { position: 1.0; color: "#777777" }
            }
            anchors {
                top: searchBox.bottom
                horizontalCenter: parent.horizontalCenter
            }
            height: 3
            width: parent.width-64
        }
        Label {
            anchors.top: bottomRec.bottom
            font.pixelSize: Theme.fontSizeTiny
            font.italic: true
            color: Theme.secondaryHighlightColor
            width: searchPage.width
            wrapMode: Text.Wrap
            text: qsTr("Note: User search supported only by web portal (not by API).")
        }
    }

    onAccepted: {
        makeSearch()
    }

    function makeSearch() {
        searchPage.forceActiveFocus()
        siteURL = searchUrlBase + newSearchString
        pageStack.push(Qt.resolvedUrl("WebView.qml"))
    }
}
