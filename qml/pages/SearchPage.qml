import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: searchPage
    allowedOrientations: Orientation.All
    property string newSearchString: searchCriteria
    ListModel
    {
        id: modelSearchTags
    }

    onStatusChanged: {
        // When leaving page
        if (status === PageStatus.Deactivating) {
            var reload = false
            if (newSearchString !== searchCriteria) {
                searchCriteria = newSearchString
                reload = true
            }
            if (checkIfTagsChanged()) {
                fillModelFromModel(modelSearchTags, modelSearchTagsGlobal)
                reload = true
            }
            if (reload)
                questionsReloadGlobal = true
        }
    }

    Component.onCompleted: {
        fillModelFromModel(modelSearchTagsGlobal, modelSearchTags)
        addNewTagItem() // Adds first if no items yet
    }

    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            title: qsTr("Questions search criteria")
        }

        Label {
            id: freeLabel
            anchors.top: header.bottom
            text: qsTr("Free text criteria")
        }
        SearchField {
            id: searchBox
            anchors.top: freeLabel.bottom
            placeholderText: qsTr("Search")
            width: parent.width
            text: searchCriteria // Show previous search if exists
            onTextChanged: {
                newSearchString = searchBox.text
            }
        }

        Label {
            id: tagsLabel
            anchors.top: searchBox.bottom
            text: qsTr("Tags criteria")
        }

        SilicaListView {
            id: tagList
            width: parent.width
            height: parent.height
            model: modelSearchTags
            anchors.top : tagsLabel.bottom
            VerticalScrollDecorator {}

            delegate:
                BackgroundItem {
                id: contentItem
                anchors.left: ListView.left
                anchors.right: ListView.right
                width: parent.width
                height: Theme.itemSizeMedium
                //contentHeight: Theme.itemSizeSmall

                TextField {
                    id: tagText
                    placeholderText: "Enter new tag here"
                    anchors.left: parent.left
                    anchors.right: parent.right
                    width: parent.width - clearButton.width
                    height: clearButton.height
                    anchors.leftMargin: 10
                    focus: true
                    // Tric to set texts to list on page load from model. Causes binding loop warning for propery text!
                    text: modelSearchTags.get(index) ? modelSearchTags.get(index).tag : ""

                    onTextChanged: {
                        modelSearchTags.get(index).tag = text
                    }
                    Keys.onEnterPressed: {
                        addNewTagItem()
                    }
                    Keys.onReturnPressed: {
                        addNewTagItem()
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
                    onClicked: {
                        if (modelSearchTags.count === 1) {
                            modelSearchTags.get(index).tag = ""
                            tagText.text = ""
                        }
                        else
                            modelSearchTags.remove(index)
                    }
                }
            }
        }
    }

    function fillModelFromModel(source, target){
        target.clear()
        for (var i = 0; i < source.count; i++) {
            target.append(source.get(i))
        }
    }
    function removeEmptyTags(model){
        for (var i = 0; i < model.count; i++) {
            if (model.get(i).tag === "")
                model.remove(i)
        }
    }
    function checkIfTagsChanged() {
        removeEmptyTags(modelSearchTags)
        if (modelSearchTags.count !== modelSearchTagsGlobal.count) {
            return true
        }
        for (var i = 0; i < modelSearchTags.count; i++) {
            if (modelSearchTags.get(i).tag !== modelSearchTagsGlobal.get(i).tag) {
                return true
            }
        }
        return false
    }

    function addNewTagItem() {
        var emptyFound = false
        for (var i = 0; i < modelSearchTags.count; i++) {
            if (modelSearchTags.get(i).tag === "") {
                emptyFound = true
                break
            }
        }
        if ((!emptyFound) || (modelSearchTags.count === 0))
            modelSearchTags.append({ "tag": ""});
    }
}
