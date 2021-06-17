import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.kde.kirigami 2.7 as Kirigami

import org.mauikit.controls 1.3 as Maui
import org.mauikit.texteditor 1.0 as TE

Maui.SettingsDialog
{
    Maui.SettingsSection
    {
        title: i18n("General")
        description: i18n("Configure the app UI, behaviour and plugins.")
        Maui.SettingTemplate
        {
            label1.text: i18n("Places Sidebar")
            label2.text: i18n("Browse your file system from the sidebar")

            Switch
            {
                checkable: true
                checked: settings.enableSidebar
                onToggled: settings.enableSidebar = !settings.enableSidebar
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Editor")
        description: i18n("Configure the look and feel of the editor. The settings are applied globally")

        Maui.SettingTemplate
        {
            label1.text:  i18n("Auto Save")
            label2.text: i18n("Auto saves your file every few seconds")
            Switch
            {
                checkable: true
                checked: settings.autoSave
                onToggled: settings.autoSave = !settings.autoSave
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Line Numbers")
            label2.text: i18n("Display the line numbers on the left side")

            Switch
            {
                checkable: true
                checked: settings.showLineNumbers
                onToggled: settings.showLineNumbers = !settings.showLineNumbers
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Syntax Highlighting Languages")
            label2.text: i18n("Display available languages")

            Switch
            {
                checkable: true
                checked: settings.showSyntaxHighlightingLanguages
                onToggled: settings.showSyntaxHighlightingLanguages = !settings.showSyntaxHighlightingLanguages
            }
        }

        Maui.SettingTemplate
        {
            label1.text: i18n("Syntax Highlighting")
            label2.text: i18n("Enable syntax highlighting for supported languages")
            Switch
            {
                checkable: true
                checked: settings.enableSyntaxHighlighting
                onToggled: settings.enableSyntaxHighlighting = !settings.enableSyntaxHighlighting
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Fonts")
        description: i18n("Configure the global editor font family and size")

        Maui.SettingTemplate
        {
            label1.text:  i18n("Family")

            ComboBox
            {
                Layout.fillWidth: true
                model: Qt.fontFamilies()
                Component.onCompleted: currentIndex = find(settings.font.family, Qt.MatchExactly)
                onActivated: settings.font.family = currentText
            }
        }

        Maui.SettingTemplate
        {
            label1.text:  i18n("Size")

            SpinBox
            {
                from: 0; to : 500
                value: settings.font.pointSize
                onValueChanged: settings.font.pointSize = value
            }
        }

        Maui.SettingTemplate
        {
            label1.text:  i18n("Tab Space")

            SpinBox
            {
                from: 0; to : 500
                value: settings.tabSpace
                onValueChanged: settings.tabSpace = value
            }
        }
    }

    Maui.SettingsSection
    {
        title: i18n("Style")
        description: i18n("Configure the style of the syntax highliting. This configuration in not applied for rich text formats")
        visible: settings.enableSyntaxHighlighting

        Maui.SettingTemplate
        {
            label1.text:  i18n("Theme")
            label2.text: i18n("Editor color scheme style")

            ComboBox
            {
                model:  _dummyDocumentHandler.getThemes()
                Component.onCompleted: currentIndex = find(settings.theme, Qt.MatchExactly)

                onActivated: settings.theme = currentText

                TE.DocumentHandler
                {
                    id: _dummyDocumentHandler
                }
            }
        }

        Maui.SettingTemplate
        {
            label1.text:  i18n("Color")
            label2.text: i18n("Editor background color")

            Maui.ColorsRow
            {
                spacing: Maui.Style.space.medium

                colors: ["#333", "#fafafa", "#fff3e6", "#4c425b"]

                onColorPicked:
                {
                    currentColor = color

                    var textColor

                    switch(color)
                    {
                    case "#333": textColor = "#fafafa"; break;
                    case "#fafafa": textColor = "#333"; break;
                    case "#fff3e6": textColor = Qt.darker(color, 2); break;
                    case "#4c425b": textColor = Qt.lighter(color, 2.5); break;
                    default: textColor = Kirigami.Theme.textColor;
                    }

                    switchBackgroundColor(color, textColor)
                }

            }
        }
    }

    function switchBackgroundColor(backgroundColor, textColor)
    {
        settings.backgroundColor = backgroundColor
        settings.textColor = textColor
    }
}
