#ifndef GITPROCESS_H
#define GITPROCESS_H

#include <QProcess>
#include <QObject>

class GitProcess : public QProcess
{
  Q_OBJECT
public:
  GitProcess();
};

#endif // GITPROCESS_H
