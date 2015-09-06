import QtQuick 2.0
import Sailfish.Silica 1.0

Drawer {
    id: searchDrawer
    anchors.fill: parent
    dock: Dock.Bottom
    open: false
    backgroundSize: drawerContent.contentHeight

    property var mainFlickable
    property var pageMainTextElement
    property var pageDynamicTextModelElement
    property bool previousButtonEnabled: false
    property bool nextButtonEnabled: true
    property variant searchMainTextIndexesArray: []
    property variant searchModelTextIndexesArray: []
    property variant searchModelTextModelIndexArray: []
    property int searchRepeatIndex: 0
    property bool searchInsideDynModelText: false
    property string searchTextCache: ""
    property int modelItemCountCache: 0
    property bool searchStringNotFound: false

    background:
        SilicaFlickable {
        id: drawerContent
        anchors.fill: parent
        contentHeight: contColumn.height
        Column {
            id: contColumn
            width: parent.width
            height: childrenRect.height
            anchors.centerIn: parent
            Row {
                id: buttons
                width: childrenRect.width
                spacing: phoneOrientation === Orientation.Landscape ||
                         phoneOrientation === Orientation.LandscapeInverted ? 250 : 100
                anchors.horizontalCenter: parent.horizontalCenter
                IconButton {
                    enabled: searchField.text.trim().length > 0 &&
                             previousButtonEnabled
                    icon.source: "image://theme/icon-m-left"
                    //rotation: -180
                    onClicked: {
                        makeSearch(searchField.text, true)
                    }
                }
                IconButton {
                    icon.source: "image://theme/icon-m-reset"
                    onClicked: {
                        //resetMainSearch()
                        //resetModelSearch()
                        hide()
                        mainFlickable.focus = true
                    }
                }
                IconButton {
                    enabled: searchField.text.trim().length > 0 &&
                             nextButtonEnabled
                    icon.source: "image://theme/icon-m-right"
                    onClicked: {
                        makeSearch(searchField.text)
                    }
                }
            }
            Rectangle {
                id: searchBorder
                color: "transparent"
                radius: 10
                smooth: true
                border.width: searchStringNotFound ? 2 : 1
                border.color: searchStringNotFound ? "red" : Theme.secondaryHighlightColor
                width: parent.width - 2 * Theme.paddingMedium
                height: searchField.height
                anchors.horizontalCenter: parent.horizontalCenter
                SearchField {
                    id: searchField
                    focus: true
                    width: parent.width
                    font.pixelSize: Theme.fontSizeSmall
                    placeholderText: qsTr("Search...")
                    EnterKey.enabled: text.trim().length > 0
                    EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                    EnterKey.onClicked: {
                        makeSearch(text)
                    }
                    onTextChanged: {
                        resetMainSearch()
                    }
                    Component.onCompleted: {
                        searchField.height = searchField.height - 40 // Make it a bit smaller
                    }
                }
            }
            Item {
                width: 1
                height: Theme.paddingMedium
            }
        }
    }

    function makeSearch(searchText, backward) {
        backward = backward || false
        searchField.focus = false
        if (!isSearchStringChanged(searchText)) {
            // Same search string, just update index forward or backwards
            if (backward) {
                nextButtonEnabled = true
                searchRepeatIndex -= 1
                if (searchRepeatIndex < 0) {
                    if (searchInsideDynModelText) {
                        searchInsideDynModelText = false
                        searchRepeatIndex = searchMainTextIndexesArray.length - 1
                    }
                    else {
                        // In the beginning.. do not continue
                        searchStringNotFound = true
                    }
                }
            }
            else {
                previousButtonEnabled = true
                searchRepeatIndex += 1
                if (searchRepeatIndex > (searchMainTextIndexesArray.length - 1)) {
                    if (!searchInsideDynModelText)
                        searchRepeatIndex = 0  // Init to start only ones
                    searchInsideDynModelText = true
                }
            }
        }

        beforeSearchtInits()
        makeSearchAndStoreIndexes(searchText)
        traverseSearchHits(searchText)

        if (searchStringNotFound) {
            if (backward) {
                previousButtonEnabled = false
                searchRepeatIndex += 1 // Correct index back to last found item
            }
            else {
                nextButtonEnabled = false
                searchRepeatIndex -= 1 // Correct index back to last found item
            }
        }
    }
    function isSearchStringChanged(searchText) {
        if (searchText !== searchTextCache) {
            // Change cache and reset search
            resetMainSearch()
            searchTextCache = searchText
            resetModelSearch()
            return true
        }
        return false
    }
    function beforeSearchtInits() {
        // Each time inited items
        searchStringNotFound = false

        // Always check if model items amount changed and needs reload
        if (pageDynamicTextModelElement.visible) {
            if (pageDynamicTextModelElement.model.count !== modelItemCountCache) {
                resetModelSearch()
                modelItemCountCache = pageDynamicTextModelElement.model.count
            }
        }
    }
    // makes search only if needed
    function makeSearchAndStoreIndexes(searchText) {
        // Get hits from main text
        if (searchMainTextIndexesArray.length === 0) {
            searchMainTextIndexesArray = getIndexes(searchText, pageMainTextElement.getPlainText())
        }

        // Update indexes from model
        if (pageDynamicTextModelElement.visible) {
            if (searchModelTextIndexesArray.length === 0) {
                var tmpRepeaterItemIndex = []
                for (var i = 0; i < pageDynamicTextModelElement.model.count; i++) {
                    var tmpArr = getIndexes(searchText, pageDynamicTextModelElement.itemAt(i).getPlainText())
                    searchModelTextIndexesArray = appendArrayToArray(searchModelTextIndexesArray, tmpArr)
                    for (var n = 0; n < tmpArr.length; n++) {
                        tmpRepeaterItemIndex.push(i)
                    }
                }
                searchModelTextModelIndexArray = tmpRepeaterItemIndex
            }
        }
    }
    function traverseSearchHits(searchText) {
        var found = false
        var loc
        if (searchRepeatIndex >= 0) {
            if ((searchMainTextIndexesArray.length > 0) && (searchRepeatIndex < searchMainTextIndexesArray.length)
                    && !searchInsideDynModelText) {
                found = true
            }
            else { // then find from answers and comments
                if ((searchModelTextIndexesArray.length > 0) && (searchRepeatIndex < searchModelTextIndexesArray.length)) {
                    searchInsideDynModelText = true
                    found = true
                }
            }
        }
        if (found) {
            // Reset previous text selection only when new one is found
            resetMainSearchTextSelection()
            resetModelSearchTextSelection()

            // Move cursor to found location
            if (!searchInsideDynModelText) {
                loc = searchMainTextIndexesArray[searchRepeatIndex]
                pageMainTextElement.selectAndMovetoText(loc, loc + searchText.length)
            }
            else {
                loc = searchModelTextIndexesArray[searchRepeatIndex]
                var pos = pageDynamicTextModelElement.itemAt(searchModelTextModelIndexArray[searchRepeatIndex]).selectAndMovetoText(loc, loc + searchText.length)
                var previousItemsHeight = 0
                for (var j = 0; j < searchModelTextModelIndexArray[searchRepeatIndex]; j++) {
                    previousItemsHeight += pageDynamicTextModelElement.itemAt(j).height
                }
                var modelY = mainFlickable.heighBeforeTextContent() + pageMainTextElement.y + pageMainTextElement.height
                var modelHeight = previousItemsHeight + pos
                if (mainFlickable.contentY >= modelY) {
                    mainFlickable.contentY = modelY
                }
                else if (mainFlickable.contentY+mainFlickable.height <= modelY+modelHeight) {
                    mainFlickable.contentY = modelY+modelHeight-mainFlickable.height
                }
                mainFlickable.contentY += drawerContent.height
            }
        }
        else {
            console.log("String \"" + searchText + "\" not found!")
            searchStringNotFound = true
        }
    }
    function getIndexes(searchStr, str) {
        var regex = new RegExp(searchStr,'gi'), result, indices = [];
        while ( (result = regex.exec(str)) ) {
            indices.push(result.index);
            //console.log("Found '" + searchStr + "' from '" + str + "' in index: " + result.index)
        }
        return indices
    }
    function appendArrayToArray(base, appended) {
        var newArr = base
        for (var i = 0; i < appended.length; i++) {
            newArr.push(appended[i])
        }
        return newArr
    }
    function resetMainSearch() {
        searchStringNotFound = false
        previousButtonEnabled = false
        nextButtonEnabled = true
        searchRepeatIndex = 0
        searchInsideDynModelText = false
        resetMainSearchTextSelection()
        searchMainTextIndexesArray = []
        searchTextCache = ""
    }
    function resetModelSearch() {
        resetModelSearchTextSelection()
        searchModelTextIndexesArray = []
        searchModelTextModelIndexArray = []
        modelItemCountCache = 0
    }
    function resetMainSearchTextSelection() {
        pageMainTextElement.resetTextSelection()
    }
    function resetModelSearchTextSelection() {
        if (pageDynamicTextModelElement.visible) {
            for (var i = 0; i < pageDynamicTextModelElement.model.count; i++) {
                pageDynamicTextModelElement.itemAt(i).resetSearchTextSelection()
            }
        }
    }
}
