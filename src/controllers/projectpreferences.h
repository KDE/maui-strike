#pragma once

#include <QObject>
#include <QUrl>
#include <QString>

class ProjectPreferences : public QObject
{
  Q_OBJECT
    //The buil dir where building takes palce
    Q_PROPERTY(QString cmakeProgram READ cmakeProgram WRITE setCmakeProgram NOTIFY cmakeProgramChanged)
    Q_PROPERTY(QString installPrefix READ installPrefix WRITE setInstallPrefix NOTIFY installPrefixChanged)
    Q_PROPERTY(QUrl buildDir READ buildDir WRITE setBuildDir NOTIFY buildDirChanged)

//  Q_PROPERTY(QStringList args READ args WRITE setArgs NOTIFY argsChanged)
//  Q_PROPERTY(QStringList envVar READ envVar WRITE setEnvVar NOTIFY envVarChanged)

public:
    explicit ProjectPreferences(QObject *parent = nullptr);

    QUrl buildDir() const;
    QString cmakeProgram() const;
    QString installPrefix() const;

public Q_SLOTS:
    void setBuildDir(QUrl buildDir);
    void setCmakeProgram(QString cmakeProgram);
    void setInstallPrefix(QString installPrefix);

private:
    QUrl m_buildDir;
    QString m_installPrefix ="/usr";
    QString m_cmakeProgram = "cmake";

Q_SIGNALS:
    void buildDirChanged(QUrl buildDir);
    void cmakeProgramChanged(QString cmakeProgram);
    void installPrefixChanged(QString installPrefix);
};
