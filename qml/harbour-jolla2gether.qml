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
import jolla2gether 1.0
import "pages"

ApplicationWindow
{
    property bool urlLoading: false
    property string siteBaseUrl: "https://together.jolla.com"
    property string loginURL: siteBaseUrl + "/account/signin/?next=/"
    property string siteURL: loginURL
    property string version: "0.0.9"
    property string license: "GPL v2.0"
    property string appicon: "qrc:/harbour-jolla2gether_250px.png"
    property string appname: "Jolla Together"
    property bool webviewAttached: false
    property string webviewBrowseBackText: "Back"
    property bool webviewWasActiveWhenUnattached: false

    Settings {
        id: appSettings
    }
    QClipboard{
         id: clipboard
     }
    ListModel {
        id: modelSearchTagsGlobal
    }
    ListModel {
        id: ignoredSearchTagsGlobal
    }
    ListModel {
        id: modelSearchTagsGlobalCache
    }
    ListModel {
        id: ignoredSearchTagsGlobalCache
    }
    InfoModel {
        id: infoModel
    }
    QuestionsModel {
        id: questionsModel
    }
    QuestionsModel {
        id: questionsModelCache
    }
    UsersModel {
        id: usersModel
    }

    QtObject {
        id: coverProxy

        property string header: "together.jolla.com"
        property string mode_INFO: "info"
        property string mode_QUESTIONS: "questions"
        property string mode

        // Questions
        property string title
        property int currentQuestion
        property int questionsCount
        property int currentPage
        property int pageCount

        property bool hasNext
        property bool hasPrevious

        signal start
        signal stop
        signal refresh
        signal nextItem
        signal previousItem
    }

    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    ProgressCircle {
        id: progressCircle
        z: 2
        anchors.top: parent.top
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        visible: urlLoading
        width: 32
        height: 32
        Timer {
            interval: 32
            repeat: true
            onTriggered: progressCircle.value = (progressCircle.value + 0.005) % 1.0
            running: urlLoading
        }
    }


    // Make it accepted on Harbour: Save power consumption as WebView seems to be "faulty component" to use?
    onApplicationActiveChanged: {
        if (!Qt.application.active) {
            unattachWebview()
        }
        else {
            attachWebview()
        }
    }

    function attachWebview(who) {
        if (!isWebviewAttached()) {
            if (onPageAllowedtoAttachWebview()) {
                if (siteURL === loginURL)
                    siteURL = siteBaseUrl
                var text = ""
                if (who !== undefined) {
                    webviewBrowseBackText = who
                }
                questionsModel.pushWebviewWithCustomScript(true, {browseBackText: webviewBrowseBackText})
                webviewAttached = true
                // Navigate back to return where user left
                if (webviewWasActiveWhenUnattached) {
                    pageStack.navigateForward(PageStackAction.Immediate)
                    webviewWasActiveWhenUnattached = false
                }
                console.log("WebView attached")
            }
        }
    }
    function unattachWebview() {
        if (webviewAttached) {
            if (pageStack.currentPage.pageName === "WebView") {
                if (siteURL === loginURL)
                    pageStack.pop()
                else {
                    // Save back browsing text and move away from webview
                    pageStack.currentPage.backNavigation = true
                    pageStack.navigateBack(PageStackAction.Immediate)
                    webviewWasActiveWhenUnattached = true
                }
            }
            var page = pageStack.find(function(page) {
                return (page.pageName === "Questions" || page.pageName === "Users")
            })
            if (page !== null)
                pageStack.popAttached(page)
            webviewAttached = false
            console.log("WebView unattached")
        }
    }
    function onPageAllowedtoAttachWebview() {
        if (pageStack.currentPage.pageName === "Questions" ||
                pageStack.currentPage.pageName === "Users") {
            return true
        }
        return false
    }
    function isWebviewAttached() {
        if (pageStack.currentPage.pageName === "WebView")
            return true
        if (onPageAllowedtoAttachWebview()) {
            var nextPage = pageStack.nextPage()
            if (nextPage !== null) {
                if (nextPage.pageName === "WebView")
                    return true
            }
        }
        return false
    }
}


