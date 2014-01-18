import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0
Page {
    id: page
    allowedOrientations: Orientation.All
    // To enable PullDownMenu, place our content in a SilicaFlickable
    Timer {
           /* For uknown reason, we can't on onCompleted to push the page so this timer used instead */
            interval: 100
            repeat: false
            running: true
            onTriggered: { pageStack.pushAttached(Qt.resolvedUrl("FirstPage.qml")); pageStack.navigateForward() }
    }
    SilicaWebView {
        id: webview
        url: siteURL
        width: page.orientation == Orientation.Portrait ? 540 : 960
        height: page.orientation == Orientation.Portrait ? 960 : 540
        overridePageStackNavigation: true
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
                text: qsTr("Info")
                onClicked: pageStack.push(Qt.resolvedUrl("InfoPage.qml"))
            }
            MenuItem {
                text: qsTr("Login")
                //onClicked: {siteURL = "https://together.jolla.com/account/signin/?next=/";  pageStack.navigateForward(); }
                onClicked: {
                    siteURL = "https://together.jolla.com/account/signin/?next=/";
                    pageStack.push(Qt.resolvedUrl("WebView.qml"));
                }
            }
            MenuItem {
                text: qsTr("together.jolla.com main page")
                onClicked: { siteURL = "https://together.jolla.com/"; }
            }
            MenuItem {
                text: qsTr("Questions")
                onClicked: {
                    var was = webview.overridePageStackNavigation
                    webview.overridePageStackNavigation = true
                    pageStack.navigateForward()
                    webview.overridePageStackNavigation = was
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


