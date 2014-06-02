import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page
    objectName: "QuestionViewPage"
    allowedOrientations: Orientation.All

    property int index: 0
    property string title: questionsModel.get(index).title
    property string text: questionsModel.get(index).text
    property string url: questionsModel.get(index).url
    property string asked: questionsModel.get(index).created
    property string updated: questionsModel.get(index).updated
    property string userId: questionsModel.get(index).author_id
    property string userName: questionsModel.get(index).author
    property string userPageUrl: questionsModel.get(index).author_page_url
    property string votes: questionsModel.get(index).votes
    property string answer_count: questionsModel.get(index).answer_count
    property string view_count: questionsModel.get(index).view_count
    property string tags: questionsModel.get(index).tags
    property var tagsArray: null
    property string userKarma: ""
    property string userAvatarUrl: ""

    property bool openExternalLinkOnWebview: false
    property string externalUrl: ""

    function goToItem(idx) {
        var props = {
            "index": idx
        };
        pageStack.replace("QuestionViewPage.qml", props);
    }

    Connections {
        id: connections
        target: viewPageUpdater
        onChangeViewPage: {
            goToItem(pageIndex)
        }
    }

    // Set some properties
    // after answer got from asyncronous (get_user) http request.
    function setUserData(user_data) {
        userKarma = user_data.reputation
        userAvatarUrl = "http:" + user_data.avatar
    }
    function selectLabelRight() {
        return askedLabel.paintedWidth > updatedLabel.paintedWidth ? askedLabel.right : updatedLabel.right
    }

    Component.onCompleted: {
        usersModel.get_user(userId, setUserData)
        tagsArray = getTagsArray()
    }

    onStatusChanged: {
        if (status === PageStatus.Active && (url !== "" || externalUrl !== ""))
        {
            siteURL = page.url
            attachWebview()
            if (openExternalLinkOnWebview) {
                openExternalLinkOnWebview = false
                siteURL = externalUrl
                externalUrl = ""
                console.log("Opening external url: " + siteURL)
                pageStack.navigateForward()
            }
        }
    }


    SilicaFlickable {
        id: contentFlickable
        anchors.fill: parent
        contentHeight: pageHeader.height +
                       questionTitleItem.height +
                       timesAndStatsRec.height +
                       tagsColumn.height +
                       questionTextContentColumn.height

        PageHeader {
            id: pageHeader
            Label {
                id: userNameLabel
                anchors.top: pageHeader.top
                anchors.right: userPic.left
                anchors.topMargin: Theme.paddingSmall
                anchors.rightMargin: Theme.paddingSmall
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "<b>" + userName + "</b>"
            }
            Label {
                id: userKarmaLabel
                anchors.top: userNameLabel.bottom
                anchors.right: userPic.left
                anchors.rightMargin: Theme.paddingSmall
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Karma: ") + userKarma
            }
            Image {
                id: userPic
                anchors.top: pageHeader.top
                anchors.right: pageHeader.right
                anchors.rightMargin: Theme.paddingSmall
                anchors.topMargin: Theme.paddingSmall
                width: 100
                height: 100
                smooth: true
                source: userAvatarUrl
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        siteURL = userPageUrl
                        pageStack.navigateForward()
                    }
                }
            }
        }
        Item {
            id: questionTitleItem
            anchors.top: pageHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            height: childrenRect.height

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingMedium
                horizontalAlignment: Text.AlignLeft
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                textFormat: Text.RichText
                text: page.title

                MouseArea {
                    enabled: page.url !== ""
                    anchors.fill: parent
                    onClicked: {
                        siteURL = page.url
                        pageStack.navigateForward()
                    }
                }
            }
        }

        Rectangle {
            id: timesAndStatsRec
            anchors.top: questionTitleItem.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium
            color: "transparent"
            width: parent.width
            height: askedLabel.height + updatedLabel.height

            Label {
                id: askedLabel
                anchors.left: parent.left
                horizontalAlignment: Text.AlignLeft
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Asked: ") + asked
            }
            Label {
                id: updatedLabel
                anchors.top: askedLabel.bottom
                anchors.left: parent.left
                horizontalAlignment: Text.AlignLeft
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Updated: ") + updated
            }

            // Fill some space before statics rectangles
            Rectangle {
                id: fillRectangel
                anchors.left: selectLabelRight()
                color: "transparent"
                width: 15
                height: 40
            }
            // Votes
            Rectangle {
                id: votesRectangle
                anchors.left: fillRectangel.right
                anchors.bottom: updatedLabel.bottom
                color: "transparent"
                smooth: true
                border.width: 1
                width: 60
                height: 40
                radius: 10
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    color: "lightgreen"
                    text: votes
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: qsTr("votes")
                }
            }
            // Answers
            Rectangle {
                id: answersRectangle
                anchors.left: votesRectangle.right
                anchors.bottom: updatedLabel.bottom
                color: "transparent"
                smooth: true
                border.width: 1
                width: 70
                height: 40
                radius: 10
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    color: "orange"
                    text: answer_count
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: qsTr("answers")
                }
            }
            // Views
            Rectangle {
                id: viewsRectangle
                anchors.left: answersRectangle.right
                anchors.bottom: updatedLabel.bottom
                color: "transparent"
                smooth: true
                border.width: 1
                width: 60
                height: 40
                radius: 10
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    color: "red"
                    text: view_count
                }
                Label {
                    font.pixelSize: Theme.fontSizeTiny
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    text: qsTr("views")
                }
            }
        }

        Item {
            id: filler
            width: 1
            anchors.left: parent.left
            anchors.top: timesAndStatsRec.bottom
            height: Theme.paddingMedium
        }

        Column {
            id: tagsColumn
            width: parent.width
            height: childrenRect.height
            anchors.top: filler.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: Theme.paddingMedium
            anchors.rightMargin: Theme.paddingMedium

            Flow {
                spacing: 5
                width: parent.width
                height: childrenRect.height
                Repeater {
                    width: parent.width
                    anchors.left: parent.left
                    model: tagsArray
                    delegate:
                        Rectangle {
                        visible: tagsArray.length > 0 && tagsArray[0] !== ""
                        color: "transparent"
                        smooth: true
                        border.width: 1
                        //border.color: "gray"
                        border.color: Theme.secondaryHighlightColor
                        height: 30
                        //radius: 10
                        Label {
                            id: tagText
                            anchors.centerIn: parent
                            font.pixelSize: Theme.fontSizeTiny
                            text: modelData
                        }
                        Component.onCompleted: {
                            width = tagText.paintedWidth + 20
                        }
                    }
                }
            }
        }

        Column {
            id: questionTextContentColumn
            width: parent.width
            height: childrenRect.height
            anchors.top: tagsColumn.bottom

            Item {
                width: 1
                height: Theme.paddingLarge
            }

            RescalingRichText {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.rightMargin: Theme.paddingMedium

                color: Theme.primaryColor
                fontSize: Theme.fontSizeSmall
                text: page.text

                onLinkActivated: {
                    var props = {
                        "url": link
                    }
                    var dialog = pageStack.push(Qt.resolvedUrl("ExternalLinkDialog.qml"), props);
                    dialog.accepted.connect(function() {
                        if (dialog.__browser_type === "webview") {
                            openExternalLinkOnWebview = true
                            externalUrl = link
                        }
                    })
                }
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }
        }

        ScrollDecorator { }
    }

    function getTagsArray() {
        return tags.split(",")
    }

}
