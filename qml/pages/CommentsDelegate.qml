import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

AnswerAndCommentDelegateBase  {
    id: commentItem
    contentHeight: commentsColumn.height
    _showPress: false // Disable normal list item highlighting

    property bool loadCommentData: false
    property string relatedQuestionOrAnswerNumber
    property bool upvotedThisComment: false
    property int numberOfCommentUpVotes: 0

    Timer {
        id: waitingWebResultsTimer
        interval: 1500 + Math.floor((Math.random() * 100) + 20);
        onTriggered: {
            console.log("Timer triggered, interval was: " +interval)
            get_comment_data(getAnswerOrCommentNumber(), commentItem)
        }
    }
    function startWebTimer() {
        waitingWebResultsTimer.start()
        console.log("Started web timer for item: " + getAnswerOrCommentNumber())
    }

    onLoadCommentDataChanged: {
        if (loadCommentData) {
            get_comment_data(getAnswerOrCommentNumber(), commentItem, pressSeeMoreCommentsButton)
        }
    }

    Column {
        id: commentsColumn
        width: parent.width
        height: childrenRect.height
        Separator {
            width: parent.width
            horizontalAlignment: Qt.AlignCenter
            color: Theme.secondaryHighlightColor
            height: 1
        }
        Row {
            width: parent.width
            height:  titleLabel.height + Theme.paddingLarge
            Column {
                id: commentTitleColumn
                height: childrenRect.height
                width: parent.width
                Row {
                    width: parent.width
                    Label {
                        id: titleLabel
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.secondaryColor
                        text: getTitle() + getUserFormatted() + "  " + getTimeForTitle()
                    }
                    Item {
                        height: 1
                        width: parent.width -
                               titleLabel.width -
                               commentVotingButton.width -
                               Theme.paddingMedium
                    }
                    Rectangle {
                        id: commentVotingButton
                        visible: loadCommentData
                        height: commentLikeRow.height
                        width: commentLikeRow.width
                        border.width: 0
                        color: "transparent"
                        Row {
                            id: commentLikeRow
                            anchors.centerIn: parent
                            Item {
                                height: 1
                                width: Theme.paddingSmall
                            }                            
                            Image {
                                id: commentLikeImage
                                smooth: true
                                source: "image://theme/icon-m-like"
                            }
                            Item {
                                height: 1
                                width: Theme.paddingSmall
                            }
                            Label {
                                id: commentVoteAmountLabel
                                visible: numberOfCommentUpVotes > 0
                                font.pixelSize: Theme.fontSizeSmall
                                font.bold: upvotedThisComment ? true : false
                                color: upvotedThisComment ? "red" : Theme.secondaryHighlightColor
                                text: numberOfCommentUpVotes
                            }
                            Item {
                                height: 1
                                width: Theme.paddingSmall
                            }
                        }
                        MouseArea {
                            enabled: ! infoBanner.visible()
                            anchors.fill: parent
                            onClicked: {
                                if (amILoggedIn(qsTr("Please log in to upvote comments!")))
                                    voteUpComment(getAnswerOrCommentNumber())
                            }
                        }
                    }
                }
            }
            Item {
                id: fillSpace
                height: 1
                width: parent.width - commentTitleColumn.width
            }
            //            Image {
            //                id: textSelect
            //                visible: textSelectionEnabled
            //                anchors.right: parent.right
            //                anchors.rightMargin: Theme.paddingMedium
            //                source: "image://theme/icon-m-clipboard"
            //                MouseArea {
            //                    anchors.fill: parent
            //                    onClicked: {
            //                        answerCommentText.toggleTextSelectMode()
            //                    }
            //                }
            //            }
        }

        ShowRichTextWithLinkActions {
            id: answerCommentText
            fontSize: getTextSize()
            text: questionsModel.wiki2Html(description)
            textBanner: infoBanner
        }

        Item {
            id: filler
            width: 1
            anchors.left: parent.left
            height: Theme.paddingLarge
        }
    }
    function amILoggedIn(error_text) {
        if (!questionsModel.isUserLoggedIn()) {
            infoBanner.showText(error_text)
            return false
        }
        return true
    }
    function pressSeeMoreCommentsButton(item) {
        var answer_id = item.relatedQuestionOrAnswerNumber
        console.log("Called pressSeeMoreCommentsButton for answer/question: " + answer_id)
        var script = "(function() { \
                      var addMoreButton = document.getElementById('add-comment-to-post-" + answer_id + "'); \
                      if (addMoreButton.childNodes[0].nodeValue === 'see more comments') { \
                          addMoreButton.click(); \
                      } \
                      })()"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            console.log("add-comment-to-post- button pressed, update comment data again")
            item.startWebTimer()
        })
    }

    function get_comment_data(comment_id, item, failCallback) {
        var script = "(function() { \
                      var commentElem = document.getElementById('comment-" + comment_id + "'); \
                      var commentSubs = commentElem.getElementsByTagName('div'); \
                      var numberOfVotes = 0; \
                      var iHaveUpvoted = false; \
                      for (var i = 0; i < commentSubs.length; i++) { \
                          if (commentSubs[i].getAttribute('class') === 'upvote upvoted') { \
                              iHaveUpvoted = true; \
                              numberOfVotes = commentSubs[i].childNodes[0].nodeValue; \
                          } \
                          if (commentSubs[i].getAttribute('class') === 'upvote') { \
                              numberOfVotes = commentSubs[i].childNodes[0].nodeValue; \
                          } \
                      } \
                      if (numberOfVotes === '') { \
                          numberOfVotes = 0; \
                      } \
                      return iHaveUpvoted + ',' + numberOfVotes; \
                      })()"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            if (result === undefined) {
                console.log("Failed to get comment data..." + comment_id)
                if (failCallback !== undefined) {
                    failCallback(item)
                    return
                }
            }
            console.log("Comment: " + comment_id + ", result: " + result)
            var commentData = result.split(',')
            item.setCommentVotesData(commentData[0].trim() === "true",
                                     commentData[1].trim())
        })
    }
    function voteUpComment(comment_id) {
        if (upvotedThisComment) {
            infoBanner.showText(qsTr("Already upvoted this comment!"))
            console.log("Already upvoted this comment")
            return
        }
        var script = "var commentElem = document.getElementById('comment-" + comment_id + "'); \
                      var commentSubs = commentElem.getElementsByTagName('div'); \
                      for (var i = 0; i < commentSubs.length; i++) { \
                          if (commentSubs[i].getAttribute('class') === 'upvote') { \
                              commentSubs[i].click(); \
                              break; \
                          } \
                      }"
        pageStack.nextPage().evaluateJavaScriptOnWebPage(script,  function(result) {
            numberOfCommentUpVotes += 1
            upvotedThisComment = true
            console.log("Upvoted comment "+ comment_id + ", result: "+result)
        })
    }
    function setCommentVotesData(upvoted, nbrOfVotes) {
        upvotedThisComment = upvoted
        numberOfCommentUpVotes = nbrOfVotes
    }
}
