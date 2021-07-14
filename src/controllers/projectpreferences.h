#ifndef PROJECTPREFERENCES_H
#define PROJECTPREFERENCES_H

#include <QObject>
#include <QUrl>

class ProjectPreferences : public QObject
{
  Q_OBJECT
    //The buil dir where building takes palce
    Q_PROPERTY(QString cmakeProgram READ cmakeProgram WRITE setCmakeProgram NOTIFY cmakeProgramChanged)
    Q_PROPERTY(QString installPrefix READ installPrefix WRITE setInstallPrefix NOTIFY installPrefixChanged)
    Q_PROPERTY(QUrl buildDir READ buildDir WRITE setBuildDir NOTIFY buildDirChanged)

public:
    explicit ProjectPreferences(QObject *parent = nullptr);

    QUrl buildDir() const;
    QString cmakeProgram() const;
    QString installPrefix() const;

public slots:    
    void setBuildDir(QUrl buildDir);
    void setCmakeProgram(QString cmakeProgram);
    void setInstallPrefix(QString installPrefix);

private:
    QUrl m_buildDir;
    QString m_installPrefix ="/usr";
    QString m_cmakeProgram = "cmake";

signals:
    void buildDirChanged(QUrl buildDir);
    void cmakeProgramChanged(QString cmakeProgram);
    void installPrefixChanged(QString installPrefix);
};

#endif // PROJECTPREFERENCES_H
