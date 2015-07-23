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
import "pages"
import "models"

ApplicationWindow
{
    property bool urlLoading: false
    property string siteBaseUrl: "https://together.jolla.com"
    property string loginURL: siteBaseUrl + "/account/signin/?next=/"
    property string siteURL: loginURL
    property string license: "GPL v2.0"
    property string appicon: "qrc:/harbour-jolla2gether_250px.png"
    property string appname: "Jolla Together"
    property bool webviewAttached: false
    property string webviewBrowseBackText: "Back"
    property bool webviewWasActiveWhenUnattached: false
    property int phoneOrientation: deviceOrientation


    Settings {
        id: appSettings
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
    QtObject {
        id: viewPageUpdater
        signal changeViewPage(int pageIndex)
    }

    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    BusyIndicator {
        running: urlLoading
        visible: urlLoading
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
    }

    Connections {
        target: pageStack
        onCurrentPageChanged: {
            coverProxy.mode = pageStack.currentPage.objectName === "Questions" ||
                    pageStack.currentPage.objectName === "QuestionViewPage"
                    ? coverProxy.mode_QUESTIONS
                    : coverProxy.mode_INFO

            // Initialize webview back text on first page
            if (pageStack.currentPage.objectName === "FirstPage")
                webviewBrowseBackText = "Back"
            // Initialize attachment of vebview on qustions list page
            if (pageStack.currentPage.objectName === "Questions")
                webviewAttached = false
        }
    }

    // Make it accepted on Harbour: Save power consumption as WebView seems to be "faulty component" to use?
    onApplicationActiveChanged: {
        if (!Qt.application.active) {
            unattachWebview()
        }
        else {
            attachWebview({attachRequestedByAppActive: true})
        }
    }

    function attachWebview(props) {
        if (!webviewAttached && Qt.application.active) {
            if (onPageAllowedtoAttachWebview(props)) {
                if (siteURL === loginURL)
                    siteURL = siteBaseUrl
                var properties = props
                var backtext = webviewBrowseBackText
                var browseBackFromProps = questionsModel.getProp("browseBackText", props)
                if (browseBackFromProps !== undefined) {
                    properties = questionsModel.merge({browseBackText: browseBackFromProps}, props)
                }
                else
                    properties = questionsModel.merge({browseBackText: backtext}, props)

                var webPage = questionsModel.pushWebviewWithCustomScript(true, properties)
                // Navigate back to return where user left
                if (webviewWasActiveWhenUnattached) {
                    pageStack.navigateForward(PageStackAction.Immediate)
                    webviewWasActiveWhenUnattached = false
                }
                webviewAttached = true
                console.log("WebView attached")
                return webPage
            }
        }
        return null
    }
    function unattachWebview() {
        if (webviewAttached) {
            if (pageStack.currentPage.objectName === "WebView") {
                // Save back browsing text and move away from webview
                webviewBrowseBackText = pageStack.currentPage.browseBackText
                webviewWasActiveWhenUnattached = true
                pageStack.currentPage.backNavigation = true
                pageStack.navigateBack(PageStackAction.Immediate)
                console.log("Webview was active while unattaching")
            }
            else {
                var page = pageStack.find(onPageAllowedtoAttachWebview)
                if (page !== null) {
                    var nextPage = pageStack.nextPage()
                    if (nextPage !== null && nextPage.objectName === "WebView") {
                        webviewBrowseBackText = nextPage.browseBackText
                        pageStack.popAttached()
                        console.log("Webview was attached to page " + page.objectName)
                    }
                }
            }
            webviewAttached = false
            console.log("WebView unattached")
        }
    }
    function onPageAllowedtoAttachWebview(props) {
        var attachRequestedByAppActive = questionsModel.getProp("attachRequestedByAppActive", props)
        if (pageStack.currentPage.objectName === "Users" ||
                pageStack.currentPage.objectName === "FirstPage" ||
                // In Questionspage webview attach not allowed when app is getting active
                (pageStack.currentPage.objectName === "Questions" && attachRequestedByAppActive === undefined) ||
                pageStack.currentPage.objectName === "QuestionViewPage" ||
                pageStack.currentPage.objectName === "AnswerPage") {
            return true
        }
        return false
    }
}


