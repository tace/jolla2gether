import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: searchPage
    allowedOrientations: Orientation.All
    property string newSearchString: ""
    property string searchUrlBase: siteBaseUrl + "/users/by-group/2/everyone/?t=user&query="

    SilicaFlickable {
        anchors.fill: parent
        focus: true
        Keys.onEscapePressed: {
            pageStack.navigateBack()
        }

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
                searchPage.accept()
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
            height: 1
            width: parent.width-64
        }
    }

    onAccepted: {
        siteURL = searchUrlBase + newSearchString
    }
}
