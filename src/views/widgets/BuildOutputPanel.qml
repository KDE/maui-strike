import QtQuick 2.14
import QtQuick.Controls 2.14

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.3 as Maui

ScrollView
{
    id: control
    Maui.Theme.inherit: false
    Maui.Theme.colorSet: Maui.Theme.Complementary
    Maui.Theme.backgroundColor: "#2c2c2c"

    contentWidth: availableWidth
    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

    property alias outputArea : _outputArea

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
