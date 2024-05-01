#pragma once
#include <QProcess>
#include <QObject>

class GitProcess : public QProcess
{
  Q_OBJECT
public:
  GitProcess();
};
