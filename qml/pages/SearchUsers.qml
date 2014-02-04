import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: searchPage
    allowedOrientations: Orientation.All
    property string newSearchString: ""
    property string searchUrlBase: "https://together.jolla.com/users/?t=user&query="

    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            title: qsTr("User search")
        }

        SearchField {
            id: searchBox
            anchors.top: header.bottom
            placeholderText: qsTr("Search")
            width: parent.width
            text: ""
            onTextChanged: {
                newSearchString = searchBox.text
            }
            Keys.onReturnPressed: {
                makeSearch()
            }
        }
        Button {
            id: serachButton
            text: "Search"
            anchors.top: searchBox.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
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
                top: serachButton.bottom
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

    function makeSearch() {
        searchPage.forceActiveFocus()
        siteURL = searchUrlBase + newSearchString
        pageStack.push(Qt.resolvedUrl("WebView.qml"))
    }
}
