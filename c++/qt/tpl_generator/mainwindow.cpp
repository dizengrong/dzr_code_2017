#include "mainwindow.h"
#include "modtab.h"
#include <QFile>
#include <QMenuBar> //前向声明需要
#include <QtWidgets/QHBoxLayout>
#include <QCoreApplication>
#include <QDir>
#include <QMessageBox>
#include <QDebug>

void MainWindow::onExportAllErlModAction()
{

}

void MainWindow::onExportAllLuaModAction()
{

}

void MainWindow::onExportAllCsModAction()
{

}

void MainWindow::loadStyleSheet(const QString &styleSheetFile)
{
    QFile file(styleSheetFile);
        file.open(QFile::ReadOnly);
        if (file.isOpen())
        {
            QString styleSheet = this->styleSheet();
            styleSheet += QLatin1String(file.readAll());//读取样式表文件
            this->setStyleSheet(styleSheet);//把文件内容传参
            file.close();
        }
        else
        {
            QMessageBox::information(this,"tip","cannot find qss file");
        }
}

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent)
{
    loadStyleSheet(":/qss/my_style_sheet.qss");
    createActions();
    createMenus();

    QWidget *centralWidget = new QWidget(this);
    centralWidget->setObjectName(QStringLiteral("centralWidget"));
    setCentralWidget(centralWidget);

    initTabs(centralWidget);

    QHBoxLayout *horizontalLayout = new QHBoxLayout(centralWidget);
    horizontalLayout->setMargin(0);

    horizontalLayout->addWidget(m_tabWidget);
    centralWidget->setLayout(horizontalLayout);

    //启动python子进程
    QProcess* m_pyProcess =new QProcess();
    m_pyProcess->setWorkingDirectory(QCoreApplication::applicationDirPath());
    m_pyProcess->setProcessChannelMode(QProcess::MergedChannels);
    m_pyProcess->start("python D:/Documents/GitHub/dzr_code_2017/c++/qt/tpl_generator/py/main.py");
}

MainWindow::~MainWindow()
{

}

void MainWindow::exportOneFile(const QString &save_dir, const QString &tpl_file)
{
    QString cmd = "export_one_file|" + save_dir + "|" + tpl_file;
    m_pyProcess->write(cmd.toStdString().data());
    qDebug() << m_pyProcess->readAll();
}

void MainWindow::createMenus()
{
    QMenu *menu = menuBar()->addMenu(tr("工具"));
    menu->addAction(m_export_all_erl_act);
    menu->addAction(m_export_all_lua_act);
    menu->addAction(m_export_all_cs_act);
}

void MainWindow::createActions()
{
    m_export_all_erl_act = new QAction(tr("导出所有Erl功能配置"), this);
    connect(m_export_all_erl_act, &QAction::triggered, this, &MainWindow::onExportAllErlModAction);

    m_export_all_lua_act = new QAction(tr("导出所有Lua功能配置"), this);
    connect(m_export_all_lua_act, &QAction::triggered, this, &MainWindow::onExportAllLuaModAction);

    m_export_all_cs_act = new QAction(tr("导出所有C#功能配置"), this);
    connect(m_export_all_cs_act, &QAction::triggered, this, &MainWindow::onExportAllCsModAction);
}

void MainWindow::initTabs(QWidget* centralWidget)
{
    m_tabWidget = new QTabWidget(centralWidget);
    ModTab* m_mod_tab = new ModTab(this);
    m_tabWidget->addTab(m_mod_tab, QString(tr("游戏功能配置")));

    QDir dir(QCoreApplication::applicationDirPath());
    QString jsonFile = dir.absoluteFilePath("cfg_game_config.json");
    if (! m_mod_tab->loadConfigJson(jsonFile))
        exit(0);

}
