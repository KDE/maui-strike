import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.texteditor as TE

import org.slike.strike as Strike

Maui.SettingsDialog
{
    id: control

    Component
    {
        id: _editorPageComponent
        Maui.SettingsPage
        {
            title: i18n("Editor")
            Maui.SectionGroup
            {
                title: i18n("Editor")
                description: i18n("Configure the look and feel of the editor. The settings are applied globally")


                Maui.FlexSectionItem
                {
                    label1.text:  i18n("Auto Save")
                    label2.text: i18n("Auto saves your file every 5 seconds.")
                    Switch
                    {
                        checkable: true
                        checked: settings.autoSave
                        onToggled: settings.autoSave = !settings.autoSave
                    }
                }


                Maui.FlexSectionItem
                {
                    label1.text:  i18n("Syntax Highlighting")
                    Switch
                    {
                        checkable: true
//                        checked: settings.autoSave
//                        onToggled: settings.autoSave = !settings.autoSave
                    }
                }

                Maui.FlexSectionItem
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
            }

            Maui.SectionGroup
            {
                title: i18n("Style")
                description: i18n("Configure the style of the syntax highlighting. This configuration in not applied for rich text formats")
                visible: settings.enableSyntaxHighlighting

                Maui.FlexSectionItem
                {
                    label1.text:  i18n("Tab Spacing")

                    SpinBox
                    {
                        from: 0; to : 500
                        value: settings.tabSpace
                        onValueChanged: settings.tabSpace = value
                    }
                }

                Maui.FlexSectionItem
                {
                    label1.text: i18n("Fonts")
                    label2.text: i18n("Configure the fonts family and style.")

                    ToolButton
                    {
                        checkable: true
                        onToggled: control.addPage(_fontsPageComponent)
                        icon.name: "go-next"
                    }
                }

                Maui.FlexSectionItem
                {
                    label1.text: i18n("Colors")
                    label2.text: i18n("Configure the color scheme of the syntax highlighting.")
                    enabled: settings.enableSyntaxHighlighting
                    ToolButton
                    {
                        checkable: true
                        onToggled: control.addPage(_stylePageComponent)
                        icon.name: "go-next"
                    }
                }
            }
        }
    }

    Component
    {
        id: _fontsPageComponent

        Maui.SettingsPage
        {
            title: i18n("Fonts")
            Maui.FontPicker
            {
                Layout.fillWidth: true
                mfont:  settings.font
                model.onlyMonospaced: true
                onFontModified:
                {
                    settings.font = font
                }
            }
        }
    }

    Maui.FlexSectionItem
    {
        label1.text: i18n("Editor")
        label2.text: i18n("Configure the look and feel of the text editor.")
        ToolButton
        {
            checkable: true
            onToggled: control.addPage(_editorPageComponent)
            icon.name: "go-next"
        }
    }

    Maui.FlexSectionItem
    {
        label1.text: i18n("Builder")
        label2.text: i18n("Configure the build steps commands.")
        ToolButton
        {
            checkable: true
            //            onToggled: control.addPage(_stylePageComponent)
            icon.name: "go-next"
        }
    }

    Maui.FlexSectionItem
    {
        label1.text: i18n("Plugins")
        label2.text: i18n("Toggle available plugins.")
        ToolButton
        {
            checkable: true
            //            onToggled: control.addPage(_stylePageComponent)
            icon.name: "go-next"
        }
    }

    Maui.FlexSectionItem
    {
        label1.text: i18n("Tools")
        label2.text: i18n("More tools.")
        ToolButton
        {
            checkable: true
            //            onToggled: control.addPage(_stylePageComponent)
            icon.name: "go-next"
        }
    }

    Component
    {
        id:_stylePageComponent
        Maui.SettingsPage
        {
            title: i18n("Style")

            Maui.SectionGroup
            {
                title: i18n("Style")
                description: i18n("Configure the style of the syntax highliting. This configuration in not applied for rich text formats")

                Maui.FlexSectionItem
                {
                    label1.text:  i18n("Color")
                    label2.text: i18n("Editor background color")
                    Maui.ColorsRow
                    {
                        spacing: Maui.Style.space.medium
                        currentColor: appSettings.backgroundColor
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
                            default: textColor = Maui.Theme.textColor;
                            }

                            switchBackgroundColor(color, textColor)
                        }

                    }
                }

                Maui.SectionItem
                {
                    label1.text:  i18n("Theme")
                    label2.text: i18n("Editor color scheme style")

                    GridLayout
                    {
                        columns: 3
                        Layout.fillWidth: true
                        opacity: enabled ? 1 : 0.5
                        Repeater
                        {
                            model: TE.ColorSchemesModel
                            {
                            }

                            delegate: Maui.GridBrowserDelegate
                            {
                                Layout.fillWidth: true
                                checked: model.name === settings.theme
                                onClicked: settings.theme = model.name

                                template.iconComponent: Rectangle
                                {
                                    implicitHeight: _previewLayout.implicitHeight +  Maui.Style.space.small*2
                                    color: appSettings.backgroundColor
                                    radius: Maui.Style.radiusV

                                    Column
                                    {
                                        id: _previewLayout
                                        anchors.fill: parent
                                        anchors.margins: Maui.Style.space.small
                                        spacing: 2

                                        Text
                                        {
                                            wrapMode: Text.NoWrap
                                            elide: Text.ElideLeft
                                            width: parent.width
                                            //                                    font.pointSize: Maui.Style.fontSizes.small
                                            text: "Hello world!"
                                            color: model.foreground
                                            font.family: settings.font.family
                                        }

                                        Rectangle
                                        {
                                            radius: 2
                                            height: 8
                                            width: parent.width
                                            color: model.highlight
                                        }

                                        Rectangle
                                        {
                                            radius: 2
                                            height: 8
                                            width: parent.width
                                            color: model.color3
                                        }

                                        Rectangle
                                        {
                                            radius: 2
                                            height: 8
                                            width: parent.width
                                            color: model.color4
                                        }

                                        Rectangle
                                        {
                                            radius: 2
                                            height: 8
                                            width: parent.width
                                            color: model.color5
                                        }
                                    }
                                }

                                label1.text: model.name
                            }
                        }
                    }
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
