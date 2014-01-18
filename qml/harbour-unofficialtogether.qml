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
import "../js/askbot.js" as Askbot
ApplicationWindow
{
    id: myapp
//    property alias pageStack: myapp.pageStack
    property bool urlLoading: false
    property string siteURL: "https://together.jolla.com/account/signin/?next=/"
    property string version: "0.0.5"
    property string license: "GPL v2.0"
    property string appicon: "qrc:/harbour-unofficialtogether_250px.png"
    property string appname: "Jolla Together(Unofficial)"

    property int pagesCount: 0;
    property int currentPageNum: 1;
    property int questionsCount: 0;

    // Filters
    property bool closedQuestionsFilter: true
    property bool answeredQuestionsFilter: true
    property bool unansweredQuestionsFilter: false

    // Sorting
    property string sort_ACTIVITY:      "activity"
    property string sort_AGE:           "age"
    property string sort_ANSWERS:       "answers"
    property string sort_VOTES:         "votes"
    property string sort_ORDER_ASC:     "asc"
    property string sort_ORDER_DESC:    "desc"
    property string sortingCriteria:    sort_ACTIVITY;
    property string sortingOrder:       sort_ORDER_DESC;

    // Search
    property string searchCriteria: ""
    ListModel
    {
        id: modelSearchTagsGlobal
    }

    ListModel
    {
        id: modelQuestions
    }
    function refresh(page)
    {
        modelQuestions.clear()
        get_questions(page) // goes to first page if page not given
    }
    function get_nextPageQuestions(params)
    {
        var askedPage = 0
        if (currentPageNum < pagesCount) {
            askedPage = currentPageNum + 1
        }
        else {
            askedPage = pagesCount
        }
        if (currentPageNum === pagesCount) {
            console.log("no more pages to load!")
        }
        else
            get_questions(askedPage, params)
    }
    function get_questions(page, params, onLoadedCallback)
    {
        Askbot.get_questions(modelQuestions, page, params, onLoadedCallback)
    }

    initialPage: Component { WebView { } }
    cover: undefined //Qt.resolvedUrl("cover/CoverPage.qml")
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

    Component.onCompleted: refresh()
}


