import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import SortFilterProxyModel 0.2

import PageEnum 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"

PageType {
    id: root

    Component.onCompleted: PageController.disableTabBarRequired(true)
    Component.onDestruction: PageController.disableTabBarRequired(false)

    property bool isTimerRunning: true
    property string progressBarText: qsTr("Usually it takes no more than 5 minutes")
    property bool isCancelButtonVisible: false

    Connections {
        target: InstallController

        function onInstallContainerFinished(finishedMessage, isServiceInstall) {
            var containerIndex = ContainersModel.getProcessedContainerIndex()
            if (!ConnectionController.isConnected && !ContainersModel.isServiceContainer(containerIndex)) {
                ServersModel.setDefaultContainer(ServersModel.processedIndex, containerIndex)
            }

            PageController.closePageRequired() // close installing page
            PageController.closePageRequired() // close protocol settings page

            if (stackView.currentItem.objectName === PageController.getPagePath(PageEnum.PageHome)) {
                PageController.restorePageHomeStateRequired(true)
            }

            PageController.showNotificationMessageRequired(finishedMessage)
        }

        function onInstallServerFinished(finishedMessage) {
            if (!ConnectionController.isConnected) {
                ServersModel.setDefaultServerIndex(ServersModel.getServersCount() - 1);
                ServersModel.processedIndex = ServersModel.defaultIndex
            }

            PageController.goToStartPageRequired()
            if (stackView.currentItem.objectName === PageController.getPagePath(PageEnum.PageSetupWizardStart)) {
                PageController.replaceStartPageRequired()
            }
            if (stackView.currentItem.objectName !== PageController.getPagePath(PageEnum.PageHome)) {
                PageController.goToPageHomeRequired()
            }

            PageController.showNotificationMessageRequired(finishedMessage)
        }

        function onServerAlreadyExists(serverIndex) {
            PageController.goToStartPageRequired()
            ServersModel.processedIndex = serverIndex
            PageController.goToPageRequired(PageEnum.PageSettingsServerInfo, false)

            PageController.showErrorMessageRequired(qsTr("The server has already been added to the application"))
        }

        function onServerIsBusy(isBusy) {
            if (isBusy) {
                root.isCancelButtonVisible = true
                root.progressBarText = qsTr("Amnezia has detected that your server is currently ") +
                                       qsTr("busy installing other software. Amnezia installation ") +
                                       qsTr("will pause until the server finishes installing other software")
                root.isTimerRunning = false
            } else {
                root.isCancelButtonVisible = false
                root.progressBarText = qsTr("Usually it takes no more than 5 minutes")
                root.isTimerRunning = true
            }
        }
    }

    SortFilterProxyModel {
        id: proxyContainersModel
        sourceModel: ContainersModel
        filters: [
            ValueFilter {
                roleName: "isCurrentlyProcessed"
                value: true
            }
        ]
    }

    FlickableType {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            spacing: 16

            ListView {
                id: container
                width: parent.width
                height: container.contentItem.height
                currentIndex: -1
                clip: true
                interactive: false
                model: proxyContainersModel

                delegate: Item {
                    implicitWidth: container.width
                    implicitHeight: delegateContent.implicitHeight

                    ColumnLayout {
                        id: delegateContent

                        anchors.fill: parent
                        anchors.rightMargin: 16
                        anchors.leftMargin: 16

                        HeaderType {
                            Layout.fillWidth: true
                            Layout.topMargin: 20

                            headerText: qsTr("Installing")
                            descriptionText: name
                        }

                        ProgressBarType {
                            id: progressBar

                            Layout.fillWidth: true
                            Layout.topMargin: 32

                            Timer {
                                id: timer

                                interval: 300
                                repeat: true
                                running: root.isTimerRunning
                                onTriggered: {
                                    progressBar.value += 0.003
                                }
                            }
                        }

                        ParagraphTextType {
                            id: progressText

                            Layout.fillWidth: true
                            Layout.topMargin: 8

                            text: root.progressBarText
                        }

                        BasicButtonType {
                            id: cancelIntallationButton

                            Layout.fillWidth: true
                            Layout.topMargin: 24

                            visible: root.isCancelButtonVisible

                            text: qsTr("Cancel installation")

                            clickedFunc: function() {
                                InstallController.cancelInstallation()
                                PageController.showBusyIndicatorRequired(true)
                            }
                        }
                    }
                }
            }
        }
    }
}
