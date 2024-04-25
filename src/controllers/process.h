#ifndef PROCESS_H
#define PROCESS_H

#include <QObject>

class Process : public QObject
{
  Q_OBJECT
public:
  explicit Process(QObject *parent = nullptr);

};

#endif // PROCESS_H
