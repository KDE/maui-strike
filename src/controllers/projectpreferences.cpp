#include "projectpreferences.h"

ProjectPreferences::ProjectPreferences(QObject *parent) : QObject(parent)
{

}

QUrl ProjectPreferences::buildDir() const
{
    return m_buildDir;
}

QString ProjectPreferences::installPrefix() const
{
    return m_installPrefix;
}

QString ProjectPreferences::cmakeProgram() const
{
    return m_cmakeProgram;
}

void ProjectPreferences::setInstallPrefix(QString installPrefix)
{
    if (m_installPrefix == installPrefix)
        return;

    m_installPrefix = installPrefix;
    emit installPrefixChanged(m_installPrefix);
}

void ProjectPreferences::setCmakeProgram(QString cmakeProgram)
{
    if (m_cmakeProgram == cmakeProgram)
        return;

    m_cmakeProgram = cmakeProgram;
    emit cmakeProgramChanged(m_cmakeProgram);
}

void ProjectPreferences::setBuildDir(QUrl buildDir)
{
    if (m_buildDir == buildDir)
        return;

    m_buildDir = buildDir;
    emit buildDirChanged(m_buildDir);
}
