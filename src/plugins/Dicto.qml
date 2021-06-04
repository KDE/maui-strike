import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.7 as Kirigami
import org.kde.mauikit 1.0 as Maui
import org.kde.mauikit 1.1 as MauiLab
import org.maui.nota 1.0 as Nota

Maui.Page
{
    id: plugin

    property bool running : false
    property bool mobileMode : false
    property string style : "kde.org.desktop"

    ListModel
    {
        id: styles
        ListElement { key: "Plasma"; value: "org.kde.desktop" }
        ListElement { key: "Material"; value: "Material" }
        ListElement { key: "Maui"; value: "maui-style" }
        ListElement { key: "Fusion"; value: "Fusion" }
        ListElement { key: "Universal"; value: "Universal" }
    }

    Layout.fillWidth: true
    Layout.minimumHeight: 500


    Loader
    {
        anchors.centerIn: parent
        anchors.fill: parent
        id: _loader

        function reload()
        {
            const  sourceFile = _loader.source
            _loader.source = ""
            _loader.source = sourceFile
        }
    }

    footBar.leftContent:[
     Maui.ToolActions
    {
        checkable: false
        autoExclusive: false
        expanded: true
        display: ToolButton.TextBesideIcon

        Action
        {
            icon.name: "run-build"
            text: i18n("Run")

            onTriggered:
            {
                console.log("trying to run a script", currentEditor.fileUrl)
//                Nota.Nota.run("qmlscene", [currentEditor.fileUrl])
if(_loader.source.length)
                    {
                        _loader.source = " "
                    }else
                    {
                        _loader.source = currentEditor.fileUrl

                    }

            }
        }

        Action
        {
            icon.name: "debug-run"
            text: i18n("Run & Debug")
            enabled: Nota.Nota.supportsEmbededTerminal()
            onTriggered: start("QML_IMPORT_TRACE=1 " + "QT_QUICK_CONTROLS_MOBILE=" + (plugin.mobileMode ? "1" : "0") + " QT_QUICK_CONTROLS_STYLE=" + plugin.style  +" qmlscene " + String(currentEditor.fileUrl).replace("file://", ""))
        }

        Action
        {
            enabled: Nota.Nota.supportsEmbededTerminal()
            icon.name: "cm_runterm"
            text: i18n("Run in Terminal")
            onTriggered: start("QT_QUICK_CONTROLS_MOBILE=" + (plugin.mobileMode ? "1" : "0") + " QT_QUICK_CONTROLS_STYLE=" + plugin.style  +" qmlscene " + String(currentEditor.fileUrl).replace("file://", "") );

        }
    },

    ComboBox
    {
        model: styles
        textRole: "key"

        Component.onCompleted: currentIndex = find(plugin.style, Qt.MatchExactly)
        onActivated:
        {
            plugin.style = styles.get(currentIndex).value
        }
    },

    Switch
    {
        text: i18n("Mobile")
        checkable: true
        checked: plugin.mobileMode
        onToggled: plugin.mobileMode = checked
    },

    ToolButton
    {
        visible: plugin.running
        icon.name: "process-stop"
        onClicked: stop()

    }
]

    function start(command)
    {
        if(currentTab.terminal)
        {
            if(!currentTab.terminal.visible)
            {
                root.terminalVisible = true
            }

            currentTab.terminal.session.sendText(command+"\n")
            plugin.running = true
        }
    }

    function stop()
    {
          if(currentTab.terminal)
          {
              currentTab.terminal.simulateKeyPress(Qt.Key_C, Qt.ControlModifier, true, 0, "")
              plugin.running = false
          }
    }

}
