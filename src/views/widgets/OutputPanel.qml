import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB
import org.mauikit.terminal 1.0 as Term

SwipeView
{
    id: control

    property alias terminal : _terminal

    Maui.Theme.inherit: false
    Maui.Theme.colorSet: Maui.Theme.Complementary
    Maui.Theme.backgroundColor: "#2c2c2c"

    Connections
    {
        target: _project.manager.process

        function onOutputLine(output)
        {
            console.log("OUTPUT LINE", output)
            _buildOutputPanel.outputArea.append(output)
        }

        function onProcessRunningChanged(running)
        {
            if(running)
            {
                control.goOutput()
            }
        }
    }

    Term.Terminal
    {
        id: _terminal
        kterminal.colorScheme: _customCS.path

        Term.CustomColorScheme
        {
            id: _customCS
            Maui.Theme.inherit: false
            Maui.Theme.colorSet: Maui.Theme.Complementary
            Maui.Theme.backgroundColor: "#2c2c2c"
            name: "Adaptive"
            description: i18n("Follows the system color scheme.")
            backgroundColor: Maui.Theme.backgroundColor
            foregroundColor: Maui.Theme.textColor
            color2: Maui.Theme.highlightColor
            color3: Maui.Theme.negativeBackgroundColor
            color4: Maui.Theme.positiveBackgroundColor
            color5: Maui.Theme.hoverColor
            color6: Maui.Theme.highlightColor
            color7: Maui.Theme.linkColor
            color8: Maui.Theme.neutralBackgroundColor
            color9: Maui.Theme.textColor
        }
    }

    BuildOutputPanel
    {
        id: _buildOutputPanel
    }

    GitPanel
    {
        id: _gitPanel
    }

    function goTerminal()
    {
        control.currentIndex = 0
    }

    function goOutput()
    {
        control.currentIndex = 1
    }

    function syncTerminal(path)
    {
        if(control.terminal && control.terminal.visible && FB.FM.fileExists(path))
            control.terminal.session.sendText("cd '" + String(FB.FM.fileDir(path)).replace("file://", "") + "'\n")
    }
}
