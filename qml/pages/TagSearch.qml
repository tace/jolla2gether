import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: tagSearchPage
    allowedOrientations: Orientation.All
    property int include_MODE: 1
    property int ignore_MODE: 2
    property int tagmode: include_MODE
    property ListModel savedSearchTags
    ListModel
    {
        id: modelSearchTags
    }

    onStatusChanged: {
        // When leaving page
        if (status === PageStatus.Deactivating) {
            var changed = saveTags()
            if (changed) {
                setTagsChangedStatus(true)
            }
        }
    }
    Component.onCompleted: {
        loadTags()
    }

    SilicaFlickable {
        anchors.fill: parent

        PageHeader {
            id: header
            title: getPageHeaderText()
        }

        PullDownMenu {
            MenuItem {
                text: getPullDownMenuText()
                onClicked: {
                    //saveTags()
                    if (tagmode === include_MODE) {
                        pageStack.replace(Qt.resolvedUrl("TagSearch.qml"),
                                          {tagmode: ignore_MODE,
                                           savedSearchTags: ignoredSearchTagsGlobal})
                    }
                    if (tagmode === ignore_MODE) {
                        pageStack.replace(Qt.resolvedUrl("TagSearch.qml"),
                                          {tagmode: include_MODE,
                                           savedSearchTags: modelSearchTagsGlobal})
                    }
                }
            }
        }


        SilicaListView {
            id: tagList
            width: parent.width
            height: parent.height
            model: modelSearchTags
            anchors.top : header.bottom
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
                    //focus: true
                    // Tric to set texts to list on page load from model. Causes binding loop warning for propery text!
                    text: modelSearchTags.get(index) ? modelSearchTags.get(index).tag : ""

                    onTextChanged: {
                        modelSearchTags.get(index).tag = text
                        addNewTagItem()
                    }
                    Keys.onEnterPressed: {
                        addNewTagItem()
                        tagSearchPage.forceActiveFocus()
                    }
                    Keys.onReturnPressed: {
                        addNewTagItem()
                        tagSearchPage.forceActiveFocus()
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

    function setTagsChangedStatus(changed) {
        if (tagmode === include_MODE)
            questionsModel.includeTagsChanged = changed
        if (tagmode === ignore_MODE)
            questionsModel.ignoreTagsChanged = changed
    }
    function getPageHeaderText() {
        if (tagmode === include_MODE)
            return qsTr("Include these tags to search")
        if (tagmode === ignore_MODE)
            return qsTr("Ignore these tags from search")
        return "no found"
    }
    function getPullDownMenuText() {
        if (tagmode === include_MODE)
            return qsTr("Ignored tags")
        if (tagmode === ignore_MODE)
            return qsTr("Included tags")
        return "no found"
    }
    function loadTags() {
        fillModelFromModel(savedSearchTags, modelSearchTags)
        addNewTagItem() // Adds first if no items yet
    }
    function saveTags() {
        var changed = checkIfTagsChanged()
        if (changed) {
            fillModelFromModel(modelSearchTags, savedSearchTags)
        }
        return changed
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
        if (modelSearchTags.count !== savedSearchTags.count) {
            return true
        }
        for (var i = 0; i < modelSearchTags.count; i++) {
            if (modelSearchTags.get(i).tag !== savedSearchTags.get(i).tag) {
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
