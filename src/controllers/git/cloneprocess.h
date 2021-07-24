#ifndef CLONEPROCESS_H
#define CLONEPROCESS_H

#include <QProcess>
#include <QObject>

class CloneProcess : public QProcess
{
  Q_OBJECT
public:
  CloneProcess();
};

#endif // CLONEPROCESS_H
