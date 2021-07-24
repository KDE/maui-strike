import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.mauikit.filebrowsing 1.3 as FB

SwipeView
{
    id: control

    property alias terminal : _terminal

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Complementary
    Kirigami.Theme.backgroundColor: "#2c2c2c"

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

    Maui.Terminal
    {
        id: _terminal
        kterminal.colorScheme: "DarkPastels"
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
