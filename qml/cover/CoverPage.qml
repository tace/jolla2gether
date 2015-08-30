import QtQuick 2.0
import Sailfish.Silica 1.0

CoverBackground {
    id: cover

    onStatusChanged: {
        if (status === Cover.Activating) {
            coverProxy.start()
        }
        if (status === Cover.Inactive) {
            coverProxy.stop()
        }
    }

    Image {
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: appicon
        opacity: 0.1
    }

    Column {
        visible: coverProxy.mode === coverProxy.mode_INFO

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        width: parent.width

        Item {
            width: parent.width
            height: childrenRect.height

            Label {
                id: headerLabel
                anchors.horizontalCenter: parent.horizontalCenter
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: coverProxy.header
            }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: headerLabel.bottom
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "total number of"
            }
        }

        Separator {
            width: parent.width
            horizontalAlignment: Qt.AlignCenter
            color: Theme.secondaryColor
        }

        Item {
            width: 1
            height: Theme.paddingSmall
        }

        Row {
            width: parent.width
            Label {
                id: groupsText
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: "Groups: "
            }
            Item {
                width: parent.width - groupsText.width - groupsValue.width
                height: 1
            }
            Label {
                id: groupsValue
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: infoModel.groups
            }
        }
        Row {
            width: parent.width
            Label {
                id: usersText
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: "Users: "
            }
            Item {
                width: parent.width - usersText.width - usersValue.width
                height: 1
            }
            Label {
                id: usersValue
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: infoModel.users
            }
        }
        Row {
            width: parent.width
            Label {
                id: questionsText
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: "Questions: "
            }
            Item {
                width: parent.width - questionsText.width - questionsValue.width
                height: 1
            }
            Label {
                id: questionsValue
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: infoModel.questions
            }
        }
        Row {
            width: parent.width
            Label {
                id: answersText
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: "Answers: "
            }
            Item {
                width: parent.width - answersText.width - answersValue.width
                height: 1
            }
            Label {
                id: answersValue
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: infoModel.answers
            }
        }
        Row {
            width: parent.width
            Label {
                id: commentsText
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: "Comments: "
            }
            Item {
                width: parent.width - commentsText.width - commentsValue.width
                height: 1
            }
            Label {
                id: commentsValue
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                text: infoModel.comments
            }
        }
    }

    Column {
        visible: coverProxy.mode === coverProxy.mode_QUESTIONS

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        width: parent.width

        Item {
            width: parent.width
            height: childrenRect.height

            Label {
                id: titleLabel
                anchors.horizontalCenter: parent.horizontalCenter
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: coverProxy.header
            }

            Label {
                id: questionsLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: titleLabel.bottom
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "question: " + coverProxy.currentQuestion + "/" + coverProxy.questionsCount
            }
            Label {
                id: pageLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: questionsLabel.bottom
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.secondaryColor
                text: "pages loaded: " + coverProxy.currentPage + "/" + coverProxy.pageCount
            }
        }

        Separator {
            width: parent.width
            horizontalAlignment: Qt.AlignCenter
            color: Theme.secondaryColor
        }

        Item {
            width: 1
            height: Theme.paddingSmall
        }

        Label {
            width: parent.width
            color: Theme.highlightColor
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            elide: Text.ElideRight
            font.pixelSize: Theme.fontSizeSmall
            maximumLineCount: 6
            text: coverProxy.title
        }
    }


    // [previous] and [next]
    CoverActionList {
        enabled: coverProxy.hasPrevious &&
                 coverProxy.hasNext &&
                 coverProxy.mode === coverProxy.mode_QUESTIONS

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                coverProxy.previousItem();
            }
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                coverProxy.nextItem();
            }
        }
    }

    // [previous] only
    CoverActionList {
        enabled: coverProxy.hasPrevious &&
                 ! coverProxy.hasNext &&
                 coverProxy.mode === coverProxy.mode_QUESTIONS

        CoverAction {
            iconSource: "image://theme/icon-cover-previous"
            onTriggered: {
                coverProxy.previousItem();
            }
        }
    }

    // [refresh only]
    CoverActionList {
        enabled: ! coverProxy.hasPrevious &&
                 ! coverProxy.hasNext ||
                 coverProxy.mode === coverProxy.mode_INFO

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                coverProxy.refresh()
            }
        }
    }

    // [refresh] and [next]
    CoverActionList {
        enabled: ! coverProxy.hasPrevious &&
                 coverProxy.hasNext &&
                 coverProxy.mode === coverProxy.mode_QUESTIONS

        CoverAction {
            iconSource: "image://theme/icon-cover-refresh"
            onTriggered: {
                coverProxy.refresh()
            }
        }
        CoverAction {
            iconSource: "image://theme/icon-cover-next"
            onTriggered: {
                coverProxy.nextItem();
            }
        }
    }
}


