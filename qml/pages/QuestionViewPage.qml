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

    Component.onCompleted: {
        usersModel.get_user(userId, setUserData)

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
        contentHeight: column.height

        Column {
            id: column
            width: parent.width
            height: childrenRect.height

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
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                height: childrenRect.height

                Label {
                    anchors.left: parent.left
                    //anchors.right: shelveIcon.left
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

//                Image {
//                    id: shelveIcon
//                    anchors.right: parent.right
//                    source:  "image://theme/icon-l-favorite"
//                             //       : "image://theme/icon-l-star"

//                    MouseArea {
//                        anchors.fill: parent
//                        onClicked: {
//                        }
//                    }
//                }
            }

            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                horizontalAlignment: Text.AlignLeft
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Asked: ") + asked
            }
            Label {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge
                horizontalAlignment: Text.AlignLeft
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeTiny
                text: qsTr("Updated: ") + updated
            }

            Item {
                width: 1
                height: Theme.paddingMedium
            }

            RescalingRichText {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.rightMargin: Theme.paddingLarge

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

}
