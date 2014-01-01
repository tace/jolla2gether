# The name of your app.
# NOTICE: name defined in TARGET has a corresponding QML filename.
#         If name defined in TARGET is changed, following needs to be
#         done to match new name:
#         - corresponding QML filename must be changed
#         - desktop icon filename must be changed
#         - desktop filename must be changed
#         - icon definition filename in desktop file must be changed
TARGET = harbour-unofficialtogether

CONFIG += sailfishapp webkit

SOURCES += src/harbour-unofficialtogether.cpp

OTHER_FILES += qml/harbour-unofficialtogether.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-unofficialtogether.spec \
    rpm/harbour-unofficialtogether.yaml \
    harbour-unofficialtogether.desktop \
    js/askbot.js \
    qml/pages/AboutPage.qml \
    qml/pages/QuestionDelegate.qml \
    qml/pages/InfoPage.qml \
    harbour-unofficialtogether.png \
    harbour-unofficialtogether.svg \
    qml/pages/WebView.qml \
    qml/pages/CreditsModel.qml \
    qml/pages/LicensePage.qml


js.files = js
js.path = /usr/share/$${TARGET}
INSTALLS+=js
RESOURCES += \
    qrc.qrc
