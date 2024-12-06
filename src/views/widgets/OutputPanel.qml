import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.filebrowsing as FB
import org.mauikit.terminal as Term

Maui.SwipeView
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
        kterminal.colorScheme: "Adaptive"
        Maui.Controls.title: i18n("Terminal")
        Maui.Controls.iconName: "dialog-scripts"
    }

    BuildOutputPanel
    {
        id: _buildOutputPanel
        Maui.Controls.title: i18n("Output")
        Maui.Controls.iconName: "love"
    }

    GitPanel
    {
        id: _gitPanel
        Maui.Controls.title: i18n("Git")
        Maui.Controls.iconName: "git"
    }

    function goTerminal()
    {
        control.setCurrentIndex(0)
    }

    function goOutput()
    {
        control.setCurrentIndex(1)
    }

    function syncTerminal(path)
    {

        if(control.terminal && control.terminal.visible && FB.FM.fileExists(path))
            terminal.session.changeDir(String(FB.FM.fileDir(path)).replace("file://", ""))
    }
}
