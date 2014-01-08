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
import "../../js/askbot.js" as Askbot

Page {
    id: pageFirst
    allowedOrientations: Orientation.All
    width: Screen.width
    height: Screen.height

    Timer {
        /* For uknown reason, we can't on onCompleted to push the page so this timer used instead */
        interval: 100
        repeat: false
        running: true
        onTriggered: { pageStack.pushAttached(Qt.resolvedUrl("WebView.qml"));  }
    }

    Label {
        font.pixelSize: Theme.fontSizeExtraSmall
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignHCenter
        text: questionsCount + " questions (page " + currentPage + "/" + pagesCount + ")"
    }
    PageHeader {
        id: header
            height: Theme.itemSizeSmall  // Default is Theme.itemSizeLarge
            _titleItem.font.pixelSize: Theme.fontSizeMedium  // Default is pixelSize: Theme.fontSizeLarge
        title: "Jolla Together (unofficialapp)"
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
//    SilicaFlickable {

        SilicaListView{
            id: questionListView
            header: Item { height: header.height; width: parent.width; }
            //interactive: !questionListView.flicking
            pressDelay: 0
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingSmall
            anchors.rightMargin: Theme.paddingSmall
            clip: true //  to have the out of view items clipped nicely.

            model: modelQuestions
            delegate: QuestionDelegate { id: questionDelegate }

            // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
            PullDownMenu {
                MenuItem {
                    text: qsTr("About")
                    onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
                MenuItem {
                    text: qsTr("Login")
                    onClicked: {siteURL = "https://together.jolla.com/account/signin/?next=/";  pageStack.navigateForward(); }
                }
                MenuItem {
                    text: qsTr("Info")
                    onClicked: pageStack.push(Qt.resolvedUrl("InfoPage.qml"))
                }
                MenuItem {
                    text: qsTr("Sort by...")
                    onClicked: pageStack.push(Qt.resolvedUrl("SortPage.qml"))
                }
                MenuItem {
                    text: qsTr("Search...")
                    onClicked: pageStack.push(Qt.resolvedUrl("SearchPage.qml"))
                }
                MenuItem {
                    text: qsTr("Refresh")
                    onClicked: { refresh(currentPage); }
                }
            }
            /*
             * PushUpMenu to be removed as it's not very usable with listview, to be change to swipes etc.
             */
            PushUpMenu {
                MenuItem {
                    text: qsTr("Next page")
                    onClicked: { get_questions(currentPage + 1) }
                }
                MenuItem {
                    text: qsTr("Previous page")
                    onClicked: { get_questions(currentPage - 1) }
                }
                MenuItem {
                    text: qsTr("Go to first page")
                    onClicked: { get_questions(1) }
                }
                MenuItem {
                    text: qsTr("Go to last page")
                    onClicked: { get_questions(pagesCount) }
                }
            }
            HorizontalScrollDecorator { flickable: questionListView }
    }
}


