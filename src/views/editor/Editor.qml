import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.texteditor as TE

import org.slike.strike as Strike

Maui.SplitViewItem
{
    id: control

    property alias editor : _editor
    property alias fileUrl : _editor.fileUrl
    property alias title : _editor.title

    Maui.Controls.title: title

    TE.TextEditor
    {
        id: _editor
        anchors.fill: parent

        showLineNumbers: settings.showLineNumbers
        body.color: settings.textColor
        body.font.family: settings.font.family
        body.font.pointSize: settings.font.pointSize
        document.backgroundColor: settings.backgroundColor
        Maui.Theme.backgroundColor: settings.backgroundColor
        document.theme: settings.theme
        document.autoSave: settings.autoSave
        document.tabSpace: ((settings.tabSpace+1) * body.font.pointSize) / 2
        document.enableSyntaxHighlighting: true
        onFileUrlChanged: editorView.outputPanel.syncTerminal(_editor.fileUrl)

        Keys.enabled: true
        Keys.onPressed: (event) =>
        {
            if((event.key === Qt.Key_S) && (event.modifiers & Qt.ControlModifier))
            {
                saveFile(document.fileUrl, _editor)
            }

            if((event.key === Qt.Key_T) && (event.modifiers & Qt.ControlModifier))
            {
                syncTerminal(_editor.fileUrl)
                _editor.terminal.forceActiveFocus()
            }

            if((event.key === Qt.Key_O) && (event.modifiers & Qt.ControlModifier))
            {
                openFile()
            }

            if((event.key === Qt.Key_N) && (event.modifiers & Qt.ControlModifier))
            {
                openTab("")
            }

            if((event.key === Qt.Key_L) && (event.modifiers & Qt.ControlModifier))
            {
                settings.showLineNumbers = !settings.showLineNumbers
            }
        }

        DropArea
        {
            id: _dropArea
            property var urls : []
            anchors.fill: parent
            onDropped: (drop) =>
            {
                if(drop.urls)
                {
                    var m_urls = drop.urls.join(",")
                    _dropArea.urls = m_urls.split(",")
                    _dropAreaMenu.show()

                    //                Nota.Nota.requestFiles( _dropArea.urls )
                }
            }

            Maui.ContextualMenu
            {
                id: _dropAreaMenu

                MenuItem
                {
                    text: i18n("Open here")
                    icon.name : "open-for-editing"
                    onTriggered:
                    {
                        _editor.fileUrl = _dropArea.urls[0]
                    }
                }

                MenuItem
                {
                    text: i18n("Open in new tab")
                    icon.name: "tab-new"
                    onTriggered:
                    {
                        Strike.Strike.requestFiles( _dropArea.urls )
                    }
                }

                MenuItem
                {
                    enabled: _dropArea.urls.length === 1 && currentTab.count <= 1 && settings.supportSplit
                    text: i18n("Open in new split")
                    icon.name: "view-split-left-right"
                    onTriggered:
                    {
                        currentTab.split(_dropArea.urls[0])
                    }
                }

                MenuSeparator{}

                MenuItem
                {
                    text: i18n("Cancel")
                    icon.name: "dialog-cancel"
                    onTriggered:
                    {
                        _dropAreaMenu.close()
                    }
                }

                onClosed: _editor.forceActiveFocus()
            }
        }

    }
}
