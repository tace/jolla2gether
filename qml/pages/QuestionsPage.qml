/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: questionsPage
    objectName: "Questions"
    allowedOrientations: Orientation.All
    property bool userIdSearch: false
    property var pageCounter: null // To keep track in whihc level of questionsPage we are

    onStatusChanged: {
        if (status === PageStatus.Active) {
            connections.target = coverProxy
            if (!userIdSearch && questionsModel.userQuestionsAsked) {
                questionsModel.restoreModel()
                questionListView.positionViewAtIndex(questionsModel.listViewCurrentIndex, ListView.Center);
            }
        }
    }
    Component.onCompleted: {
        pageCounter = pageStack.depth
    }

    Connections {
        id: connections
        target: coverProxy
        onStart: {
            if (activateCoverSignals()) {
                changeListItemFromCover(questionListView.currentIndex)
            }
        }
        onRefresh: {
            if (activateCoverSignals()) {
                if (questionsModel.pageHeader === questionsModel.pageHeader_FOLLOWED_QUESTIONS) {
                    // Commented out as webview cannot be used when app unactivated (cover actions)
                    // So for now do nothing in refresh from cover for followed questions.
                    //loadFollowedQuestions()
                }
                else {
                    var closure = function(x) {
                        return function(filteredCount) {
                            //console.log("filteredCount: "+filteredCount)
                            changeListItemFromCover(x);
                        }
                    };
                    questionsModel.refresh(questionsModel.currentPageNum, closure(questionListView.currentIndex))
                }
            }
        }
        onNextItem: {
            if (activateCoverSignals()) {
                questionListView.currentIndex = questionListView.currentIndex + 1
                changeListItemFromCover(questionListView.currentIndex)
                viewPageUpdater.changeViewPage(questionListView.currentIndex)
            }
        }
        onPreviousItem: {
            if (activateCoverSignals()) {
                questionListView.currentIndex = questionListView.currentIndex - 1
                changeListItemFromCover(questionListView.currentIndex)
                viewPageUpdater.changeViewPage(questionListView.currentIndex)
            }
        }
    }

    // Pagestack can have many times this page and we want signals only one time
    // and also we want signals to be executed if QuestionViewPage is active
    function activateCoverSignals() {
        if (status === PageStatus.Active ||
                (pageStack.currentPage.objectName === "QuestionViewPage") && (pageStack.depth - pageCounter) === 2) {
            return true
        }
        return false
    }

    function changeListItemFromCover(index) {

        // Load more already when on previous last item if fast cover actions
        if (index === (questionsModel.count - 2)) {
            if (questionsModel.questionsCount > (index + 1)) {
                console.log("Load next page questions from cover")
                questionsModel.get_nextPageQuestions()
            }
        }
        questionListView.positionViewAtIndex(index, ListView.Center);
        coverProxy.hasPrevious = index > 0;
        coverProxy.hasNext = (index < questionsModel.count - 1) &&
                (index < questionsModel.questionsCount - 1)
        coverProxy.currentQuestion = index + 1
        coverProxy.questionsCount = questionsModel.questionsCount
        coverProxy.currentPage = questionsModel.currentPageNum
        coverProxy.pageCount = questionsModel.pagesCount
        coverProxy.title = questionsModel.get(index).title;
    }
    function loadFollowedQuestions() {
        questionsModel.pageHeader = questionsModel.pageHeader_FOLLOWED_QUESTIONS
        siteURL = siteBaseUrl + "/users/" +
                questionsModel.ownUserIdValue + "/" +
                questionsModel.ownUserName + "/?sort=favorites"
        unattachWebview()
        attachWebview({callbacks: [questionsModel.get_followed_questions_callback()]})
    }

    Drawer {
        id: infoDrawer
        anchors.fill: parent
        dock: Dock.Top
        open: false
        backgroundSize: drawerView.contentHeight

        function show(text) {
            infoTextLabel.text = text
            infoDrawer.open = true
        }

        background: SilicaFlickable {
            id: drawerView
            anchors.fill: parent
            contentHeight: 340
            clip: true

            Item {
                visible: infoDrawer.open
                width: parent.width
                height: parent.height - Theme.itemSizeSmall

                Separator {
                    width: parent.width
                    horizontalAlignment: Qt.AlignHCenter
                    color: Theme.highlightColor
                }

                Label {
                    id: infoTextLabel
                    visible: infoDrawer.open
                    anchors.centerIn: parent
                    color: Theme.highlightColor
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignHCenter
                    font.pixelSize: Theme.fontSizeLarge
                    wrapMode: Text.WordWrap
                    width: parent.width
                    height: 100
                    text: ""
                }
                IconButton {
                    anchors.top: infoTextLabel.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon.source: "image://theme/icon-m-close"

                    onClicked: {
                        infoDrawer.open = false
                    }
                }
            }
        }

        // To enable PullDownMenu, place our content in a SilicaFlickable
        SilicaFlickable {
            interactive: !questionListView.flicking
            pressDelay: 0
            anchors.fill: parent
            Label {
                id: pagesCountLabel
                font.pixelSize: Theme.fontSizeExtraSmall
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignHCenter
                text: questionsModel.questionsCount +
                      " questions (pages loaded " +
                      questionsModel.currentPageNum + "/" +
                      questionsModel.pagesCount + ")"
            }
            PageHeader {
                id: header
                title: questionsModel.pageHeader
            }

            // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
            PullDownMenu {
                MenuItem {
                    text: questionsModel.pageHeader_ALL_QUESTIONS
                    visible: (questionsModel.pageHeader !== questionsModel.pageHeader_ALL_QUESTIONS) && !userIdSearch
                    onClicked: {
                        questionsModel.resetUserIdSearchCriteria()
                        questionsModel.pageHeader = questionsModel.pageHeader_ALL_QUESTIONS
                        questionsModel.refresh()
                    }
                }
                MenuItem {
                    text: questionsModel.pageHeader_MY_QUESTIONS
                    visible: (questionsModel.pageHeader !== questionsModel.pageHeader_MY_QUESTIONS) && !userIdSearch
                    onClicked: {
                        if (questionsModel.setUserIdSearchCriteria(questionsModel.ownUserIdValue)) {
                            questionsModel.pageHeader = questionsModel.pageHeader_MY_QUESTIONS
                            questionsModel.refresh()
                        }
                        else {
                            infoDrawer.show(qsTr("Please log in from login page to list your own questions!"))
                        }
                    }
                }
                MenuItem {
                    text: questionsModel.pageHeader_FOLLOWED_QUESTIONS
                    visible: (questionsModel.pageHeader !== questionsModel.pageHeader_FOLLOWED_QUESTIONS) && !userIdSearch
                    onClicked: {
                        if (questionsModel.isUserLoggedIn()) {
                            loadFollowedQuestions()
                        }
                        else {
                            infoDrawer.show(qsTr("Please log in from login page to list your followed questions!"))
                        }
                    }
                }
                MenuItem {
                    visible: questionsModel.isSearchCriteriaActive() &&
                             questionsModel.pageHeader !== questionsModel.pageHeader_FOLLOWED_QUESTIONS
                    text: qsTr("Reset Search/Filter")
                    onClicked: {
                        questionsModel.resetSearchCriteria()
                        questionsModel.refresh()
                    }
                }
                MenuItem {
                    visible: questionsModel.pageHeader !== questionsModel.pageHeader_FOLLOWED_QUESTIONS
                    text: qsTr("Search/Filter...")
                    onClicked: pageStack.push(Qt.resolvedUrl("SearchQuestions.qml"))
                }
                MenuItem {
                    text: qsTr("Refresh")
                    onClicked: {
                        if (questionsModel.pageHeader === questionsModel.pageHeader_FOLLOWED_QUESTIONS) {
                            loadFollowedQuestions()
                        }
                        else {
                            questionsModel.refresh()
                        }
                    }
                }
            }
            QuestionTypeSelector {
                id: questionTypeSelector
                anchors.top: header.bottom
                visible: userIdSearch || questionsModel.pageHeader === questionsModel.pageHeader_MY_QUESTIONS
            }

            Row {
                id: searchActiveBanner
                visible: questionsModel.pageHeader !== questionsModel.pageHeader_FOLLOWED_QUESTIONS
                width: parent.width
                height: childrenRect.height
                anchors.right: parent.right
                anchors.left: parent.left
                anchors.top: questionTypeSelector.bottom
                Image {
                    visible: questionsModel.isSearchCriteriaActive()
                    anchors.leftMargin: Theme.paddingLarge
                    source: "image://theme/icon-s-task"
                }
                Flow {
                    id: searchCriteriaRow
                    width: parent.width
                    spacing: 5
                    Label {
                        visible: questionsModel.searchCriteria !== ""
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.highlightColor
                        text: qsTr("Search: ")
                    }
                    Label {
                        visible: questionsModel.searchCriteria !== ""
                        font.pixelSize: Theme.fontSizeTiny
                        text: questionsModel.searchCriteria
                    }
                    Label {
                        visible: modelSearchTagsGlobal.count > 0 || ignoredSearchTagsGlobal.count > 0
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.highlightColor
                        text: qsTr("Tags: ")
                    }
                    Repeater {
                        visible: modelSearchTagsGlobal.count > 0
                        model: modelSearchTagsGlobal
                        Label {
                            font.pixelSize: Theme.fontSizeTiny
                            text: modelData
                        }
                    }
                    Repeater {
                        visible: ignoredSearchTagsGlobal.count > 0
                        model: ignoredSearchTagsGlobal
                        Label {
                            font.pixelSize: Theme.fontSizeTiny
                            font.strikeout: true
                            text: modelData
                        }
                    }
                    Label {
                        visible: questionsModel.isFilterCriteriasActive()
                        font.pixelSize: Theme.fontSizeTiny
                        color: Theme.highlightColor
                        text: qsTr("Filters: ")
                    }
                    Label {
                        visible: questionsModel.closedQuestionsFilter !== questionsModel.closedQuestionsFilter_DEFAULT
                        font.pixelSize: Theme.fontSizeTiny
                        font.strikeout: true
                        color: "lightgreen"
                        text: "[closed]"
                    }
                    Label {
                        visible: (questionsModel.answeredQuestionsFilter !== questionsModel.answeredQuestionsFilter_DEFAULT) && !unansweredFilter.visible
                        font.pixelSize: Theme.fontSizeTiny
                        font.strikeout: true
                        color: "orange"
                        text: "[answered]"
                    }
                    Label {
                        id: unansweredFilter
                        visible: questionsModel.unansweredQuestionsFilter !== questionsModel.unansweredQuestionsFilter_DEFAULT
                        font.pixelSize: Theme.fontSizeTiny
                        color: "lightblue"
                        text: "[UNANSWERED]"
                    }
                    Separator {
                        visible: questionsModel.isSearchCriteriaActive()
                        width: parent.width
                        horizontalAlignment: Qt.AlignCenter
                        color: Theme.secondaryColor
                        height: 2
                    }
                }
            }

            SilicaListView {
                id: questionListView
                pressDelay: 0
                anchors.top: searchActiveBanner.bottom
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingSmall
                anchors.rightMargin: Theme.paddingSmall
                clip: true //  to have the out of view items clipped nicely.

                model: questionsModel
                onCurrentIndexChanged: questionsModel.listViewCurrentIndex = currentIndex
                delegate: QuestionDelegate { id: questionDelegate }
                VerticalScrollDecorator { flickable: questionListView }
                onAtYEndChanged: {
                    if (atYEnd && contentY >= parent.height) {
                        // BugFix: Ensure Y and height are something, if not page is just loaded and we do not want to load douple items to view
                        if (contentY > 0 && parent.height > 0) {
                            console.log("At end of view, load next page questions")
                            questionsModel.get_nextPageQuestions()
                        }
                    }
                }
            }
        }
    } // Drawer
}


