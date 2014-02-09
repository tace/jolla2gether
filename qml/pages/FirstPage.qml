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
    id: pageFirst
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        PageHeader {
            title: qsTr("Jolla Together")
        }

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }
            MenuItem {
                text: qsTr("Login")
                onClicked: {
                    siteURL = "https://together.jolla.com/account/signin/?next=/";
                    pageStack.push(Qt.resolvedUrl("WebView.qml"))
                }
            }
            MenuItem {
                text: qsTr("Users")
                onClicked: {
                    usersModel.refresh()
                    pageStack.push(Qt.resolvedUrl("UsersPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Questions")
                onClicked:
                {
                    questionsModel.refresh()
                    pageStack.push(Qt.resolvedUrl("QuestionsPage.qml"))
                }
            }
        }

        Column {
            spacing: 20
            anchors.centerIn: parent
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            id: infoCol
            height: Theme.itemSizeLarge * 3
            Image{
                source: appicon
                height: 128
                width: 128
                fillMode: Image.PreserveAspectFit
                anchors {
                    horizontalCenter: parent.horizontalCenter
                }
            }
            Separator {
               // alignment: Qt.AlignHCenter
                anchors.left: parent.left
                anchors.right: parent.right
                height: 2
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Groups: " + infoModel.groups
                color: Theme.primaryColor
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Users: " + infoModel.users
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Questions: " + infoModel.questions
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Answers: " + infoModel.answers
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "Comments: " + infoModel.comments
            }

        }
    }

    Connections {
        target: coverProxy

        onRefresh: {
            if (coverProxy.mode === coverProxy.mode_INFO)
                infoModel.get_info()
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Active) {
            coverProxy.mode = coverProxy.mode_INFO
        }
    }

    Component.onCompleted: {
        coverProxy.mode = coverProxy.mode_INFO
        if (!firstPageLoaded) {
            firstPageLoaded = true
            infoModel.get_info()
        }
    }
}


