import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Shapes

import PageEnum 1.0
import Style 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"
import "../Components"

PageType {
    id: root

    property bool isControlsDisabled: false
    property bool isTabBarDisabled: false
    property alias homeButton: homeTabButton

    Connections {
        target: PageController

        function onGoToPageHomeRequired() {
            tabBar.setCurrentIndex(0)
            tabBarStackView.goToTabBarPage(PageEnum.PageHome)
        }

        function onGoToPageSettingsRequired() {
            tabBar.setCurrentIndex(2)
            tabBarStackView.goToTabBarPage(PageEnum.PageSettings)
        }

        function onGoToPageViewConfigRequired() {
            var pagePath = PageController.getPagePath(PageEnum.PageSetupWizardViewConfig)
            tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.PushTransition)
        }

        function onDisableControlsRequired(disabled) {
            isControlsDisabled = disabled
        }

        function onDisableTabBarRequired(disabled) {
            isTabBarDisabled = disabled
        }

        function onClosePageRequired() {
            if (tabBarStackView.depth <= 1) {
                PageController.hideWindow()
                return
            }
            tabBarStackView.pop()
        }

        function onGoToPageRequired(page, slide) {
            var pagePath = PageController.getPagePath(page)

            if (slide) {
                tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.PushTransition)
            } else {
                tabBarStackView.push(pagePath, { "objectName" : pagePath }, StackView.Immediate)
            }
        }

        function onGoToStartPageRequired() {
            connectionTypeSelection.close()
            while (tabBarStackView.depth > 1) {
                tabBarStackView.pop()
            }
        }

        function onEscapePressed() {
            if (root.isControlsDisabled || root.isTabBarDisabled) {
                return
            }

            var pageName = tabBarStackView.currentItem.objectName
            if ((pageName === PageController.getPagePath(PageEnum.PageShare)) ||
                    (pageName === PageController.getPagePath(PageEnum.PageSettings))) {
                PageController.goToPageHomeRequired()
                tabBar.previousIndex = 0
            } else {
                PageController.closePageRequired()
            }
        }

        function onForceTabBarActiveFocus() {
            homeTabButton.focus = true
            tabBar.forceActiveFocus()
        }

        function onForceStackActiveFocus() {
            homeTabButton.focus = true
            tabBarStackView.forceActiveFocus()
        }
    }

    Connections {
        target: InstallController

        function onInstallationErrorOccurred(error) {
            PageController.showBusyIndicatorRequired(false)

            PageController.showErrorMessageRequired(error)

            var needCloseCurrentPage = false
            var currentPageName = tabBarStackView.currentItem.objectName

            if (currentPageName === PageController.getPagePath(PageEnum.PageSetupWizardInstalling)) {
                needCloseCurrentPage = true
            } else if (currentPageName === PageController.getPagePath(PageEnum.PageDeinstalling)) {
                needCloseCurrentPage = true
            }
            if (needCloseCurrentPage) {
                PageController.closePageRequired()
            }
        }

        function onUpdateContainerFinished(message) {
            PageController.showNotificationMessageRequired(message)
            PageController.closePageRequired()
        }

        function onCachedProfileCleared(message) {
            PageController.showNotificationMessageRequired(message)
        }
    }

    Connections {
        target: ConnectionController

        function onReconnectWithUpdatedContainer(message) {
            PageController.showNotificationMessageRequired(message)
            PageController.closePageRequired()
        }

        function onNoInstalledContainers() {
            PageController.setTriggeredByConnectButton(true)

            ServersModel.processedIndex = ServersModel.getDefaultServerIndex()
            InstallController.setShouldCreateServer(false)
            PageController.goToPageRequired(PageEnum.PageSetupWizardEasy)
        }
    }

    Connections {
        target: ImportController

        function onImportErrorOccurred(error, goToPageHome) {
            PageController.showErrorMessageRequired(error)
        }
    }

    Connections {
        target: SettingsController

        function onLoggingDisableByWatcher() {
            PageController.showNotificationMessageRequired(qsTr("Logging was disabled after 14 days, log files were deleted"))
        }
    }

    StackViewType {
        id: tabBarStackView

        anchors.top: parent.top
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: tabBar.top
        // activeFocusOnTab: true
        width: parent.width
        height: root.height - tabBar.implicitHeight

        enabled: !root.isControlsDisabled

        function goToTabBarPage(page) {
            connectionTypeSelection.close()

            var pagePath = PageController.getPagePath(page)
            tabBarStackView.clear(StackView.Immediate)
            tabBarStackView.replace(pagePath, { "objectName" : pagePath }, StackView.Immediate)
        }

        Component.onCompleted: {
            var pagePath = PageController.getPagePath(PageEnum.PageHome)
            ServersModel.processedIndex = ServersModel.defaultIndex
            tabBarStackView.push(pagePath, { "objectName" : pagePath })
        }

        KeyNavigation.down: tabBar.currentItem
    }

    TabBar {
        id: tabBar

        property int previousIndex: 0

        anchors.right: parent.right
        anchors.left: parent.left
        anchors.bottom: parent.bottom

        topPadding: 8
        bottomPadding: 8
        leftPadding: 96
        rightPadding: 96

        enabled: !root.isControlsDisabled && !root.isTabBarDisabled

        background: Shape {
            width: parent.width
            height: parent.height

            ShapePath {
                startX: 0
                startY: 0

                PathLine { x: width; y: 0 }
                PathLine { x: width; y: tabBar.height - 1 }
                PathLine { x: 0; y: tabBar.height - 1 }
                PathLine { x: 0; y: 0 }

                strokeWidth: 1
                strokeColor: AmneziaStyle.color.greyDark
                fillColor: AmneziaStyle.color.blackLight
            }
        }

        TabImageButtonType {
            id: homeTabButton
            objectName: "homeTabButton"

            focus: true
            activeFocusOnTab: true
            isSelected: tabBar.currentIndex === 0
            image: "qrc:/images/controls/home.svg"
            clickedFunc: function () {
                tabBarStackView.goToTabBarPage(PageEnum.PageHome)
                ServersModel.processedIndex = ServersModel.defaultIndex
                tabBar.currentIndex = 0
                tabBar.previousIndex = 0
            }

            // KeyNavigation.tab: shareTabButton
            KeyNavigation.right: shareTabButton
            KeyNavigation.up: tabBarStackView
            Keys.onEnterPressed: this.clicked()
            Keys.onReturnPressed: this.clicked()
        }

        TabImageButtonType {
            id: shareTabButton
            objectName: "shareTabButton"

            activeFocusOnTab: true
            Connections {
                target: ServersModel

                function onModelReset() {
                    var hasServerWithWriteAccess = ServersModel.hasServerWithWriteAccess()
                    shareTabButton.visible = hasServerWithWriteAccess
                    shareTabButton.width = hasServerWithWriteAccess ? undefined : 0
                }
            }

            visible: ServersModel.hasServerWithWriteAccess()
            width: ServersModel.hasServerWithWriteAccess() ? undefined : 0

            isSelected: tabBar.currentIndex === 1
            image: "qrc:/images/controls/share-2.svg"
            clickedFunc: function () {
                tabBarStackView.goToTabBarPage(PageEnum.PageShare)
                tabBar.currentIndex = 1
                tabBar.previousIndex = 1
            }

            // KeyNavigation.tab: settingsTabButton
            KeyNavigation.right: settingsTabButton
            KeyNavigation.up: tabBarStackView
        }

        TabImageButtonType {
            id: settingsTabButton
            objectName: "settingsTabButton"

            isSelected: tabBar.currentIndex === 2
            image: "qrc:/images/controls/settings-2.svg"
            clickedFunc: function () {
                tabBarStackView.goToTabBarPage(PageEnum.PageSettings)
                tabBar.currentIndex = 2
                tabBar.previousIndex = 2
            }
            activeFocusOnTab: true
            // KeyNavigation.tab: plusTabButton
            KeyNavigation.right: plusTabButton
            KeyNavigation.up: tabBarStackView
        }

        TabImageButtonType {
            id: plusTabButton
            objectName: "plusTabButton"
            
            isSelected: tabBar.currentIndex === 3
            image: "qrc:/images/controls/plus.svg"
            clickedFunc: function () {
                connectionTypeSelection.open()
            }
            activeFocusOnTab: true
            KeyNavigation.tab: tabBarStackView.currentItem
            KeyNavigation.up: tabBarStackView
        }
    }

    ConnectionTypeSelectionDrawer {
        id: connectionTypeSelection

        onAboutToHide: {
            PageController.forceTabBarActiveFocus()
            tabBar.setCurrentIndex(tabBar.previousIndex)
        }
    }

    Component.onCompleted: {
        console.log("\n\n")
        console.log("********************************************************")
        console.log("===>> view: ", tabBarStackView)
        console.log("===>> current item: ", tabBarStackView.currentItem)
        console.log("===>> content item: ", tabBarStackView.contentItem)
        console.log("===>> children", tabBarStackView.children)
        console.log("===>> child[0]: ", tabBarStackView.children[0])
        console.log("========================================================")
    }
}
