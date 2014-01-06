import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: searchPage
    allowedOrientations: Orientation.All
    property string newSearchString: ""

    onStatusChanged: {
        // When leaving page
        if (status === PageStatus.Deactivating) {
            if (newSearchString !== searchCriteria) {
                searchCriteria = newSearchString
                refresh() // reload model to first page
            }
        }
    }
/*
    Component.onCompleted: {
        modelSearchTags.clear()
        modelSearchTags.append({"tag" : ""})
    }
*/
    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            title: qsTr("Questions search criteria")
        }
/*
        Label {
            text: qsTr("Free text criteria")
        }
*/
        SearchField {
            id: searchBox
            anchors.top: header.bottom
            placeholderText: qsTr("Search")
            width: parent.width
            text: searchCriteria // Show previous search if exists

            //            EnterKey.onClicked: {
            //                console.log(searchBox.text)
            //            }
            onTextChanged: {
                //console.log(searchBox.text)
                newSearchString = searchBox.text
            }
        }

/*
        Label {
            text: qsTr("Tags criteria")
        }

        SilicaListView {
            id: tagList
            width: parent.width
            height: parent.height
            model: modelSearchTags
            anchors.top : searchBox.bottom
//            ViewPlaceholder {
//                id: placeHolder
//                enabled: tagList.count == 0
//                text: qsTr("Insert tags here")
//            }

            VerticalScrollDecorator {}

            delegate:
                BackgroundItem {
                id: contentItem
                anchors.left: ListView.left
                anchors.right: ListView.right
                width: parent.width
                height: Theme.itemSizeSmall
                contentHeight: Theme.itemSizeSmall

//                onClicked: {
//                    placeHolder.enabled = false
//                }

                TextField {
                    id: tagText
                    //text: todo
                    placeholderText: "Enter new tag here"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    width: parent.width - clearButton.width
                    height: clearButton.height
                    anchors.leftMargin: 10
                    focus: true
                    color: {
                        if (status == 0) return "white"
                        else return "gray"
                    }
                    onTextChanged: {
                        modelSearchTags.get(index).tag = text
                    }
                    Keys.onEnterPressed: {
                        modelSearchTags.append({ "tag": ""});
                    }
                    Keys.onReturnPressed: {
                        modelSearchTags.append({ "tag": ""});
                    }
                }

                IconButton {
                    id: clearButton
                    anchors {
                        right: parent.right
                        rightMargin: Theme.paddingLarge
                    }
                    width: icon.width
                    height: parent.height
                    icon.source: "image://theme/icon-m-clear"

                    enabled: tagText.enabled

                    opacity: tagText.text.length > 0 ? 1 : 0
                    Behavior on opacity {
                        FadeAnimation {}
                    }

                    onClicked: {
                        tagText.text = ""
                        tagText._editor.forceActiveFocus()
                    }
                }
            }
        }
        */
    }
}
