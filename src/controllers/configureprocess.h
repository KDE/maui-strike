#ifndef CONFIGUREPROCESS_H
#define CONFIGUREPROCESS_H

#include <QObject>

class ConfigureProcess : public QObject
{
  Q_OBJECT
public:
  explicit ConfigureProcess(QObject *parent = nullptr);

signals:

};

#endif // CONFIGUREPROCESS_H
