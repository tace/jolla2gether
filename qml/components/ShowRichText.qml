import QtQuick 2.0
import Sailfish.Silica 1.0

/* Pretty fancy element for displaying rich text fitting the width.
 *
 * Images are scaled down to fit the width, or, technically speaking, the
 * rich text content is actually scaled down so the images fit, while the
 * font size is scaled up to keep the original font size.
 */
Item {
    id: root

    property string text
    property alias color: contentLabel.color
    property real fontSize: Theme.fontSizeSmall

    property real scaling: 1

    property string _style: "<style>" +
                            "a:link { color:" + Theme.highlightColor + "}" +
                            "</style>"
    property bool textSelectMode: false

    signal linkActivated(string link)

    //    height: (contentLabel.height * scaling) + textSelectButton.height
    height: contentLabel.height * scaling
    clip: true

    onWidthChanged: {
        rescaleTimer.restart();
    }

    Label {
        id: layoutLabel

        visible: false
        width: parent.width
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        textFormat: Text.RichText

        // tiny font so that only images are relevant
        text: "<style>* { font-size: 1px }</style>" + parent.text

        onContentWidthChanged: {
            //console.log("contentWidth: " + contentWidth);
            rescaleTimer.restart();
        }
    }

    TextEdit {
        id: contentLabel
        readOnly: true

        onSelectedTextChanged: {
            if (selectedText !== "") {
                //copy()
                Clipboard.text = selectedText
            }
        }

        width: parent.width / scaling
        scale: scaling

        transformOrigin: Item.TopLeft
        font.pixelSize: parent.fontSize / scaling
        wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        textFormat: Text.RichText

        smooth: true

        text: _style + parent.text

        onLinkActivated: {
            root.linkActivated(link);
        }
    }
    function toggleTextSelectMode() {
        if (textSelectMode) {
            contentLabel.selectByMouse = false
            textSelectMode = false
            return false
        }
        else {
            contentLabel.selectByMouse = true
            textSelectMode = true
            return true
        }
    }

    Timer {
        id: rescaleTimer
        interval: 100

        onTriggered: {
            var contentWidth = Math.floor(layoutLabel.contentWidth);
            scaling = Math.min(1, parent.width / (layoutLabel.contentWidth + 0.0));
            //console.log("scaling: " + scaling);

            // force reflow
            contentLabel.text = contentLabel.text + " ";
        }
    }
}
