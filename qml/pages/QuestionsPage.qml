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

Page {
    id: questionsPage
    allowedOrientations: Orientation.All
    property string pageName: "Questions"
    property bool userIdSearch: false

    onStatusChanged: {
        if (status === PageStatus.Active) {
            connections.target = coverProxy
            if (!userIdSearch && questionsModel.userQuestionsAsked) {
                questionsModel.restoreModel()
                questionListView.positionViewAtIndex(questionsModel.listViewCurrentIndex, ListView.Center);
            }
            attachWebview("Questions")
            coverProxy.mode = coverProxy.mode_QUESTIONS
        }
        if (status === PageStatus.Inactive && pageStack.currentPage.pageName !== "WebView") {
            connections.target = dummyTarget
        }
    }


    QtObject {
        id: dummyTarget
        property bool hasNext
        property bool hasPrevious
        signal start
        signal refresh
        signal nextItem
        signal previousItem
    }
    Connections {
        id: connections
        target: coverProxy
        onStart: {
            changeListItemFromCover(questionListView.currentIndex)
        }
        onRefresh: {
            var closure = function(x) {
                return function() {
                    changeListItemFromCover(x);
                }
            };
            questionsModel.refresh(questionsModel.currentPageNum, closure(questionListView.currentIndex))
        }
        onNextItem: {
            questionListView.currentIndex = questionListView.currentIndex + 1
            changeListItemFromCover(questionListView.currentIndex)
        }
        onPreviousItem: {
            questionListView.currentIndex = questionListView.currentIndex - 1
            changeListItemFromCover(questionListView.currentIndex)
        }
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
                    text: qsTr("All questions")
                    visible: questionsModel.myQuestionsToggle && !userIdSearch
                    onClicked: {
                        questionsModel.resetUserIdSearchCriteria()
                        questionsModel.refresh()
                        questionsModel.myQuestionsToggle = false
                    }
                }
                MenuItem {
                    text: qsTr("My questions")
                    visible: !questionsModel.myQuestionsToggle && !userIdSearch
                    onClicked: {
                        if (questionsModel.setUserIdSearchCriteria(questionsModel.ownUserIdValue)) {
                            questionsModel.pageHeader = questionsModel.pageHeader_MY_QUESTIONS
                            questionsModel.refresh()
                            questionsModel.myQuestionsToggle = true
                        }
                        else {
                            infoDrawer.show(qsTr("Please login from login page to list your own questions!"))
                        }
                    }
                }
                MenuItem {
                    text: qsTr("Search/Filter...")
                    onClicked: pageStack.push(Qt.resolvedUrl("SearchQuestions.qml"))
                }
                MenuItem {
                    text: qsTr("Refresh")
                    onClicked: questionsModel.refresh();
                }
            }
            SilicaListView {
                id: questionListView
                pressDelay: 0
                anchors.top: header.bottom
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

                //            onMovementEnded: {
                //                if(atYEnd) {
                //                    questionsModel.get_nextPageQuestions()
                //                }
                //            }
                onAtYEndChanged: {
                    if (atYEnd && contentY >= parent.height)
                        questionsModel.get_nextPageQuestions()
                }
            }
            FancyScroller {
                anchors.fill: questionListView
                flickable: questionListView
            }
        }
    } // Drawer

    function changeListItemFromCover(index) {

        // Load more already when on previous last item if fast cover actions
        if (index === (questionsModel.count - 2)) {
            if (questionsModel.questionsCount > (index + 1)) {
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
}


