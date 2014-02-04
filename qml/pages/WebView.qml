import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0

Page {
    id: page
    property string browseBackText: "Back"
    allowedOrientations: Orientation.All
    forwardNavigation: false

    SilicaWebView {
        id: webview
        url: siteURL
        overridePageStackNavigation: true
        width: page.orientation == Orientation.Portrait ? 540 : 960
        height: page.orientation == Orientation.Portrait ? 960 : 540
        onLoadingChanged:
        {
            if (loadRequest.status === WebView.LoadStartedStatus)
                urlLoading = true;
            else
                urlLoading = false;
            if (loadRequest.status === WebView.LoadSucceededStatus) {
                urlLoading = false;
                page.forceActiveFocus()
            }
        }
        onNavigationRequested: {
            // detect URL scheme prefix, most likely an external link
            var schemaRE = /^\w+:/;
            if (schemaRE.test(request.url)) {
                request.action = WebView.AcceptRequest;
            } else {
                request.action = WebView.IgnoreRequest;
                // delegate request.url here
            }
        }
        PullDownMenu {
            MenuItem {
                text: qsTr("together.jolla.com main page")
                onClicked: { siteURL = "https://together.jolla.com/"; }
            }
            MenuItem {
                text: qsTr(browseBackText)
                onClicked: {
                    pageStack.navigateBack()
                }
            }
        }
    }
    onStatusChanged: {
        if (status === PageStatus.Inactive) {
            // Just to stop the ProgressCircle animation
            urlLoading = false
        }
    }
}



