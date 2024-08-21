import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../Config"

FocusScope {
    id: root
    objectName: "PageType"

    property StackView stackView: StackView.view

    property Item defaultActiveFocusItem: null

    onVisibleChanged: {
        if (visible && !GC.isMobile()) {
            timer.start()
        }
    }

    Component.onCompleted: {
        console.log(">>>>>>>>>>>>>");
        console.log("==> root: ", root);
        for (let i = 0; i < root.children.length; i++) {
            let child = root.children[i];
            console.log("\t|-[", i, "]:", child);

            for (let j = 0; j < child.children.length; j++) {
                let grandchild = child.children[j];
                console.log("\t\t|-[", j, "]:", grandchild.type);
            }
        }
        // console.log("===>> children: ", root.children);
        // for (let i = 0; i < root.children.length; i++) {
        //     console.log("***>> child's [", i, "] children: ", root.children[i].children);
        // }
        console.log("<<<<<<<<<<<<<");
    }

    // function lastItemTabClicked(focusItem) {
    //     if (GC.isMobile()) {
    //         return
    //     }

    //     if (focusItem) {
    //         focusItem.forceActiveFocus()
    //         PageController.forceTabBarActiveFocus()
    //     } else {
    //         if (defaultActiveFocusItem) {
    //             defaultActiveFocusItem.forceActiveFocus()
    //         }
    //         PageController.forceTabBarActiveFocus()
    //     }
    // }

//    MouseArea {
//        id: globalMouseArea
//        z: 99
//        anchors.fill: parent

//        enabled: true

//        onPressed: function(mouse) {
//            forceActiveFocus()
//            mouse.accepted = false
//        }
//    }

    // Set a timer to set focus after a short delay
    Timer {
        id: timer
        interval: 100 // Milliseconds
        onTriggered: {
            if (defaultActiveFocusItem) {
                defaultActiveFocusItem.forceActiveFocus()
            }
        }
        repeat: false // Stop the timer after one trigger
        running: !GC.isMobile()  // Start the timer
    }
}
