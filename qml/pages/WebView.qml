import QtQuick 2.0
import Sailfish.Silica 1.0
import QtWebKit 3.0
Page {
    id: page
    allowedOrientations: Orientation.All
    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaWebView {
        id: webview
        url: siteURL
        width: page.orientation == Orientation.Portrait ? 540 : 960
        height: page.orientation == Orientation.Portrait ? 960 : 540
        onLoadingChanged:
        {
            if (loadRequest.status == WebView.LoadStartedStatus)
                urlLoading = true;
            else
                urlLoading = false;
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
                text: qsTr("Questions")
                onClicked: pageStack.navigateBack()
            }
        }
    }
}


