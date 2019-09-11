#include "mainwindow.h"
#include <QApplication>
#include <QDebug>
#include <QTextCodec>


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);
    //QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
    QString pwd = QCoreApplication::applicationDirPath();
    qDebug() << pwd;

    //启动python子进程
    QProcess* m_pyProcess =new QProcess();
    m_pyProcess->setWorkingDirectory(pwd);
    m_pyProcess->setProcessChannelMode(QProcess::MergedChannels);
    QString cmd = QString("python 1%/py/main.py").arg(pwd);
    m_pyProcess->start(cmd);
    qDebug() << m_pyProcess->state();
    qDebug() << m_pyProcess->processId();

    MainWindow w(nullptr, m_pyProcess);
    w.showMaximized();
    //w.show();

    return a.exec();
}
