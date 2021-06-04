import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami
import org.mauikit.controls 1.2 as Maui

import org.maui.nota 1.0 as Nota

Maui.Dialog
{
    id: control
    title: i18n("New file")
    maxWidth: 350

    page.padding: 0
    spacing: 0
    persistent: false
    defaultButtons: false
    rejectButton.visible : false
    acceptButton.visible: false
    acceptButton.text: i18n("New template")

    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        hoverEnabled: true
        implicitHeight: 80

        Maui.ListItemTemplate
        {
            anchors.fill: parent
            headerSizeHint: iconSizeHint + Maui.Style.space.big
            iconSizeHint: Maui.Style.iconSizes.big
            iconSource: "folder-open"
            label1.text: i18n("Open file")
            label2.text: i18n("Open one or multiple files")
        }

        onClicked:
        {
            openFileDialog()
            control.close()
        }
    }

    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        hoverEnabled: true
        implicitHeight: 80

        Maui.ListItemTemplate
        {
            id: _textOption
            anchors.fill: parent
            headerSizeHint: iconSizeHint + Maui.Style.space.big
            iconSizeHint: Maui.Style.iconSizes.big
            iconSource: "text-x-generic"
            label1.text: i18n("Text file")
            label2.text: i18n("Simple text file with syntax highlighting")
        }

        onClicked:
        {
            editorView.openTab("")
            //                _editorListView.currentItem.body.textFormat = TextEdit.PlainText
            control.close()
        }
    }


    Maui.AlternateListItem
    {
        Layout.fillWidth: true
        implicitHeight: 80
        hoverEnabled: true
        lastOne: true

        Maui.ListItemTemplate
        {
            id: _richOption
            anchors.fill: parent
            headerSizeHint: iconSizeHint + Maui.Style.space.big
            iconSizeHint: Maui.Style.iconSizes.big
            iconSource: "text-enriched"
            label1.text: i18n("Rich text file")
            label2.text: i18n("With support for basic text format editing")
        }

        onClicked:
        {
            openTab("")
            //                _editorListView.currentItem.body.textFormat = TextEdit.RichText
            control.close()
        }
    }

}
