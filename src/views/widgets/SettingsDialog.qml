import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.3

import org.mauikit.controls 1.3 as Maui
import org.mauikit.texteditor 1.0 as TE

import org.slike.strike 1.0 as Strike

Maui.SettingsDialog
{
    id: control

    Maui.SectionGroup
    {
        title: i18n("Editor")
        description: i18n("Configure the look and feel of the editor. The settings are applied globally")

        Maui.SectionItem
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

        Maui.SectionItem
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
        description: i18n("Configure the style of the syntax highliting. This configuration in not applied for rich text formats")
        visible: settings.enableSyntaxHighlighting


        Maui.SectionItem
        {
            label1.text:  i18n("Font Family")

            Maui.FontsComboBox
            {
                Layout.fillWidth: true
                model: Strike.Fonts.monospaceFamilies
                Component.onCompleted: currentIndex = find(settings.font.family, Qt.MatchExactly)
                onActivated: settings.font.family = currentText
            }
        }

        Maui.SectionItem
        {
            label1.text:  i18n("Font Size")

            SpinBox
            {
                from: 0; to : 500
                value: settings.font.pointSize
                onValueChanged: settings.font.pointSize = value
            }
        }

        Maui.SectionItem
        {
            label1.text:  i18n("Tab Spacing")

            SpinBox
            {
                from: 0; to : 500
                value: settings.tabSpace
                onValueChanged: settings.tabSpace = value
            }
        }

        Maui.SectionItem
        {
            label1.text: i18n("Colors")
            label2.text: i18n("Configure the color scheme of the syntax hightlighting.")
            enabled: settings.enableSyntaxHighlighting
            ToolButton
            {
                checkable: true
                onToggled: control.addPage(_stylePageComponent)
                icon.name: "go-next"
            }

        }


        Component
        {
            id:_stylePageComponent
            Maui.ScrollColumn
            {
                Maui.SectionGroup
                {
                    title: i18n("Style")
                    description: i18n("Configure the style of the syntax highliting. This configuration in not applied for rich text formats")

                    Maui.SectionItem
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
                            width: parent.parent.width
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

                                    template.iconComponent: Pane
                                    {
                                        implicitHeight: Math.max(contentHeight + topPadding + bottomPadding, 64)
                                        padding: Maui.Style.space.small

                                        background: Rectangle
                                        {
                                            //                                color: model.background
                                            color: appSettings.backgroundColor
                                            radius: Maui.Style.radiusV
                                        }

                                        contentItem: Column
                                        {
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
    }

    function switchBackgroundColor(backgroundColor, textColor)
    {
        settings.backgroundColor = backgroundColor
        settings.textColor = textColor
    }
}
