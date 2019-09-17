#include "mainwindow.h"
#include <QApplication>
#include <QDateTime>
#include <QDebug>
#include <QFile>
#include <QMutex>
#include <QTextCodec>
#include <QTranslator>

void outputMessage(QtMsgType type, const QMessageLogContext &context, const QString &msg)
{

    static QMutex mutex;
    mutex.lock();
    QString text;
    switch(type)
    {

    case QtDebugMsg:
        text = QString("Debug:");
        break;
    case QtWarningMsg:
        text = QString("Warning:");
        break;
    case QtCriticalMsg:
        text = QString("Critical:");
        break;
    case QtFatalMsg:
        text = QString("Fatal:");
    }
    QString context_info = QString("File:(%1) Line:(%2)").arg(QString(context.file)).arg(context.line);
    QString current_date_time = QDateTime::currentDateTime().toString("yyyy-MM-dd hh:mm:ss");
    QString current_date = QString("%1").arg(current_date_time);
    QString message = QString("%1 %2 %3 %4").arg(current_date).arg(text).arg(context_info).arg(msg);

    QFile file("log.txt");
    file.open(QIODevice::WriteOnly | QIODevice::Append);
    QTextStream text_stream(&file);
    text_stream << message << "\r\n";
    file.flush();
    file.close();
    mutex.unlock();
}


int main(int argc, char *argv[])
{
    QApplication a(argc, argv);

    qInstallMessageHandler(outputMessage);

    //QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
    QString pwd = QCoreApplication::applicationDirPath();
    qDebug() << pwd;

    QTranslator translator; //新建翻译类
    bool ret = translator.load("lang_Chinses", pwd); //导入生成的文件
    qDebug() << ret;
    a.installTranslator(&translator); //装入

    //启动python子进程
    QProcess* m_pyProcess =new QProcess();
    m_pyProcess->setWorkingDirectory(pwd);
    m_pyProcess->setProcessChannelMode(QProcess::MergedChannels);
    #ifdef QT_NO_DEBUG
    QString cmd = QString("main.exe");
    #else
    //QString cmd = QString("main.exe");
    QString cmd = "python D:/Documents/GitHub/dzr_code_2017/c++/qt/tpl_generator/py/main.py";
    //QString cmd = "python C:/my_github/dzr_code_2017/c++/qt/tpl_generator/py/main.py";
    #endif
    qDebug() << cmd;
    m_pyProcess->start(cmd);
    qDebug() << m_pyProcess->state();
    qDebug() << m_pyProcess->processId();

    MainWindow w(nullptr, m_pyProcess);
    w.showMaximized();
    //w.show();

    return a.exec();
}
