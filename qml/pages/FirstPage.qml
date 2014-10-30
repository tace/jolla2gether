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
    objectName: "FirstPage"
    allowedOrientations: Orientation.All
    forwardNavigation: false
    property int ownPicSize: 128
    property string userId: questionsModel.ownUserIdValue

    onUserIdChanged: {
        console.log("userId changed: " + userId)
        if (!questionsModel.isUserLoggedIn()) {
            loginLabel.text = qsTr("Not logged in")
            loginLabel.color = "red"
            loginLabel.font.bold = true
            ownPic.source = appicon
            loginIndicator.running = false
        }
        if (questionsModel.isUserLoggedIn()) {
            loginLabel.text = qsTr("Logged in as ")
            loginLabel.color = Theme.primaryColor
            loginLabel.font.bold = false
            usersModel.get_user(userId, function(user_data) {
                ownPic.source = "http:" + usersModel.changeImageLinkSize(user_data.avatar, ownPicSize)
            })
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent
        width: parent.width
        PageHeader {
            id: header
            height: headerRow.height
            Row {
                id: headerRow
                height: childrenRect.height
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                y: Theme.itemSizeLarge/2 - height/2
                Image{
                    source: "image://theme/icon-m-jolla"
                    height: 70
                    width: 70
                    fillMode: Image.PreserveAspectFit
                    smooth: true
                }
                Label {
                    font {
                        pixelSize: Theme.fontSizeLarge
                        family: Theme.fontFamilyHeading
                    }
                    color: Theme.highlightColor
                    text: "Together"
                }
            }
        }
        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: {
                    unattachWebview()
                    pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: {
                    unattachWebview()
                    pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Log in")
                visible: !questionsModel.isUserLoggedIn()
                onClicked: {
                    unattachWebview()
                    attachWebview()
                    siteURL = loginURL
                    forwardNavigation = true
                    pageStack.navigateForward()
                }
            }
            MenuItem {
                text: qsTr("Log out")
                visible: questionsModel.isUserLoggedIn()
                onClicked: {
                    questionsModel.logOut()
                }
            }
            MenuItem {
                visible: false
                enabled: questionsModel.isUserLoggedIn()                
                text: qsTr("Followed Questions")
                onClicked: {
                    unattachWebview()
                    siteURL = siteBaseUrl + "/users/" +
                            questionsModel.ownUserIdValue + "/" +
                            questionsModel.ownUserName + "/?sort=favorites"
                    attachWebview({callbacks: [questionsModel.get_followed_questions_callback()]})
                    pageStack.push(Qt.resolvedUrl("QuestionsPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Users")
                onClicked: {
                    unattachWebview()
                    usersModel.refresh()
                    pageStack.push(Qt.resolvedUrl("UsersPage.qml"))
                }
            }
            MenuItem {
                text: qsTr("Questions")
                onClicked:
                {
                    unattachWebview()
                    questionsModel.refresh()
                    pageStack.push(Qt.resolvedUrl("QuestionsPage.qml"))
                }
            }
        }

        Column {
            id: contentColumn
            spacing: 20
            anchors.top: header.bottom
            anchors.centerIn: parent
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            height: childrenRect.height
            width: parent.width
            Separator {
                width: parent.width
                horizontalAlignment: Qt.AlignCenter
                color: Theme.secondaryColor
                height: 2
            }
            Row {
                id: userDataRow
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                width: parent.width
                Image{
                    id: ownPic
                    source: appicon
                    height: ownPicSize
                    width: ownPicSize
                    smooth: true
                    fillMode: Image.PreserveAspectFit
                }
                Item {
                    width: Theme.paddingMedium
                    height: 1
                }
                Column {
                    Row {
                        Label {
                            id: loginLabel
                            color: Theme.primaryColor
                            font.pixelSize: Theme.fontSizeSmall
                            text: qsTr("Fetching login data...")
                        }
                        Label {
                            color: Theme.highlightColor
                            font.pixelSize: Theme.fontSizeSmall
                            font.bold: true
                            text: questionsModel.ownUserName
                            visible: questionsModel.isUserLoggedIn()
                        }
                    }
                    Label {
                        visible: questionsModel.isUserLoggedIn()
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeSmall
                        text: qsTr("Karma: ") + questionsModel.ownKarma
                    }
                    Label {
                        width: userDataRow.width - ownPic.width - Theme.paddingLarge
                        visible: questionsModel.isUserLoggedIn()
                        color: Theme.primaryColor
                        font.pixelSize: Theme.fontSizeTiny
                        wrapMode: Text.Wrap
                        text: qsTr("You have ") + questionsModel.ownBadges
                    }
                }
                Item {
                    width: Theme.paddingMedium
                    height: 1
                }
                BusyIndicator {
                    id: loginIndicator
                    size: BusyIndicatorSize.Small
                    running: questionsModel.ownUserIdValue === ""
                }
            }
            Separator {
                width: parent.width
                horizontalAlignment: Qt.AlignCenter
                color: Theme.secondaryColor
                height: 2
            }

            Rectangle {
                id: togetherInfoStats
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: 2*Theme.paddingLarge
                anchors.rightMargin: 2*Theme.paddingLarge
                color: "transparent"
                width: getStatLabelMaxWidth()
                height: childrenRect.height
                Label {
                    id: infoUsersText
                    anchors.left: parent.left
                    horizontalAlignment: Text.AlignLeft
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Users") + ":"
                }
                Label {
                    id: infoUsersValue
                    anchors.top: infoUsersText.top
                    anchors.left: infoUsersText.right
                    anchors.right: parent.right
                    horizontalAlignment: Text.AlignRight
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: infoModel.users
                }
                Label {
                    id: infoQuestionsText
                    anchors.left: parent.left
                    anchors.top: infoUsersValue.bottom
                    horizontalAlignment: Text.AlignLeft
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Questions") + ":"
                }
                Label {
                    id: infoQuestionsValue
                    anchors.left: infoQuestionsText.right
                    anchors.right: parent.right
                    anchors.top: infoQuestionsText.top
                    horizontalAlignment: Text.AlignRight
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: infoModel.questions
                }
                Label {
                    id: infoAnswersText
                    anchors.left: parent.left
                    anchors.top: infoQuestionsValue.bottom
                    horizontalAlignment: Text.AlignLeft
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Answers") + ":"
                }
                Label {
                    id: infoAnswersValue
                    anchors.left: infoAnswersText.right
                    anchors.right: parent.right
                    anchors.top: infoAnswersText.top
                    horizontalAlignment: Text.AlignRight
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: infoModel.answers
                }
                Label {
                    id: infoCommentsText
                    anchors.left: parent.left
                    anchors.top: infoAnswersValue.bottom
                    horizontalAlignment: Text.AlignLeft
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: qsTr("Comments") + ":"
                }
                Label {
                    id: infoCommentsValue
                    anchors.left: infoCommentsText.right
                    anchors.right: parent.right
                    anchors.top: infoCommentsText.top
                    horizontalAlignment: Text.AlignRight
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    text: infoModel.comments
                }
            }
            Separator {
                width: parent.width
                horizontalAlignment: Qt.AlignCenter
                color: Theme.secondaryColor
                height: 2
            }
        }
    }

    function getStatLabelMaxWidth() {
        var res_width = 0
        if (infoUsersText.paintedWidth + infoUsersValue.paintedWidth > res_width)
            res_width = infoUsersText.width + infoUsersValue.width
        if (infoQuestionsText.paintedWidth + infoQuestionsValue.paintedWidth > res_width)
            res_width = infoQuestionsText.width + infoQuestionsValue.width
        if (infoAnswersText.paintedWidth + infoAnswersValue.paintedWidth > res_width)
            res_width = infoAnswersText.width + infoAnswersValue.width
        if (infoCommentsText.paintedWidth + infoCommentsValue.paintedWidth > res_width)
            res_width = infoCommentsText.width + infoCommentsValue.width
        return res_width
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
            attachWebview()
            infoModel.get_info()
            urlLoading = false
            forwardNavigation = false
        }
    }
}


