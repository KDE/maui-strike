import QtQuick 2.14
import QtQuick.Controls 2.14

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.3 as Maui

Maui.Page
{
    id: control
    headBar.visible: false
    footBar.leftContent: [
        ToolButton
        {
            icon.name: "vcs-pull"
        },
        ToolButton
        {
            icon.name: "vcs-push"
        },
        ToolButton
        {
            icon.name: "vcs-stash"
        },
        ToolButton
        {
            icon.name: "vcs-stash-pop"
        },
        ToolButton
        {
            icon.name: "vcs-branch"
        },
        ToolButton
        {
            icon.name: "vcs-commit"
        },
        ToolButton
        {
            icon.name: "vcs-merge"
        }
    ]

    footBar.farRightContent: Maui.ToolButtonMenu
    {
        icon.name: "overflow-menu"
    }

    ScrollView
    {
        anchors.fill: parent
        Maui.Theme.inherit: false
        Maui.Theme.colorSet: Maui.Theme.Complementary
        Maui.Theme.backgroundColor: "#2c2c2c"

        contentWidth: availableWidth
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        Flickable
        {
            interactive: Kirigami.Settings.hasTransientTouchInput
            boundsBehavior: Flickable.StopAtBounds
            boundsMovement :Flickable.StopAtBounds

            TextArea.flickable:   TextArea
            {
                id: _outputArea
                width: parent.width
                color: "violet"
                readOnly: true
                font.family: "Monospace"
                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                background: Rectangle
                {
                    color:  Maui.Theme.backgroundColor
                }
            }
        }
    }
}
