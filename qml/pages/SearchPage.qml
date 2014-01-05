import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: searchPage

    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            title: "Search questions"
        }

        SearchField {
            id: searchBox
            anchors.top: header.bottom
            placeholderText: qsTr("Search")
            width: parent.width
            text: searchCriteria

//            EnterKey.onClicked: {
//                console.log(searchBox.text)
//            }
            onTextChanged: {
                //console.log(searchBox.text)
                searchCriteria = searchBox.text
            }
        }
    }
}
