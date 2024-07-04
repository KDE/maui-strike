#pragma once

#include <QProcess>
#include <QObject>

class CloneProcess : public QProcess
{
  Q_OBJECT
public:
  CloneProcess();
};

