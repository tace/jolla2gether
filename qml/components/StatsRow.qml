import QtQuick 2.0
import Sailfish.Silica 1.0

Row {
    property bool timesVisible: true
    property bool createTimeVisible: true
    property bool votesVisible: true
    property bool answersVisible: true
    property bool viewsVisible: true
    property int statsLabelsFontSize: Theme.fontSizeTiny
    property int rectangleHeightAdjustment: -5

    StatsRectangle {
        id: timesRectangle
        visible: timesVisible
        topLabelText: createTimeVisible ? "c: " + created : ""
        topLabelFontColor: Theme.secondaryColor
        bottomLabelText: "u: " + updated
        bottomLabelFontColor: Theme.secondaryColor
        recHeightAdjustment: rectangleHeightAdjustment
        anchorRight: true
    }
    StatsRectangle {
        id: viewsRectangle
        visible: viewsVisible
        topLabelText: view_count
        topLabelFontColor: "red"
        topLabelFontSize: statsLabelsFontSize
        bottomLabelText: qsTr("views")
        bottomLabelFontColor: Theme.secondaryColor
        recHeightAdjustment: rectangleHeightAdjustment
    }
    StatsRectangle {
        id: answersRectangle
        visible: answersVisible
        topLabelText: answer_count
        topLabelFontColor: "orange"
        topLabelFontSize: statsLabelsFontSize
        bottomLabelText: qsTr("answers")
        bottomLabelFontColor: Theme.secondaryColor
        recHeightAdjustment: rectangleHeightAdjustment
    }
    StatsRectangle {
        id: votesRectangle
        visible: votesVisible
        topLabelText: votes
        topLabelFontColor: "lightgreen"
        topLabelFontSize: statsLabelsFontSize
        bottomLabelText: qsTr("votes")
        bottomLabelFontColor: Theme.secondaryColor
        recHeightAdjustment: rectangleHeightAdjustment
    }
}
