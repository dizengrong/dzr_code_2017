#include "modtab.h"
#include "ui_modtab.h"
#include "setting.h"
#include "mainwindow.h"
#include <QtWidgets/QPushButton>
#include <QFile>
#include <QJsonObject>
#include <QJsonParseError>
#include <QMessageBox>
#include <QDebug>
#include <QJsonArray>
#include <QProcess>
#include <QMenu>
#include <QContextMenuEvent>
#include <QTimer>
#include <QFileDialog>


QPushButton* makeBtn(QWidget* parent, const QString &btnLable)
{
    QPushButton *btn = new QPushButton(parent);
    btn->setText(btnLable);
    btn->setFlat(true);
    btn->setStyleSheet(QLatin1String("color: rgb(51, 153, 255);"));
    btn->setCursor(QCursor(Qt::PointingHandCursor));
    return btn;
}

ModTab::ModTab(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::ModTab),
    m_mainWindow(dynamic_cast<MainWindow*>(parent))
{
    ui->setupUi(this);

    m_timer = new QTimer(this);
    m_timer->setSingleShot(true);
    connect(m_timer, &QTimer::timeout, this, &ModTab::onSearchShowEvent);

    QStringList header;
    header.append("Excel文件(点击打开)");
    header.append("Sheet名称");
    header.append("erl配置(点击导出)");
    header.append("lua配置(点击导出)");
    header.append("c#配置(点击导出)");
    header.append("操作");
    ui->m_table->setColumnCount(header.size());

    ui->m_table->setHorizontalHeaderLabels(header);
    ui->m_table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

    //ui->m_table->horizontalHeader()->setSectionResizeMode(0, QHeaderView::ResizeToContents);
    //ui->m_table->horizontalHeader()->setSectionResizeMode(3, QHeaderView::ResizeToContents);
    //ui->m_table->horizontalHeader()->setSectionResizeMode(5, QHeaderView::ResizeToContents);
    ui->m_table->setSelectionBehavior(QAbstractItemView::SelectItems);
    ui->m_table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ui->m_table->setSortingEnabled(false);
    connect(ui->m_table, &QTableWidget::cellDoubleClicked, this, &ModTab::onCellDoubleClicked);

    m_context_menu = new QMenu();
    m_openDirAct = new QAction(this);
    m_openDirAct->setText("open file directory");
    m_context_menu->addAction(m_openDirAct);
    connect(m_openDirAct, &QAction::triggered, this, &ModTab::openDirectory); //右键动作槽

    connect(ui->m_search, &QLineEdit::textChanged, this, &ModTab::onSearchEvent);

    // other init
    ui->m_edit_erl_dir->setText(Setting::getInstatnce().getErlDir());
    ui->m_edit_lua_dir->setText(Setting::getInstatnce().getLuaDir());
}

ModTab::~ModTab()
{
    delete ui;
}

bool ModTab::loadConfigJson(const QString &jsonFile)
{
    QFile loadFile(jsonFile);

    if(!loadFile.open(QIODevice::ReadOnly))
    {
        QMessageBox::critical(this,"error","cannot find file:" + jsonFile);
        return false;
    }

    QByteArray allData = loadFile.readAll();
    loadFile.close();

    QJsonParseError json_error;
    QJsonDocument jsonDoc(QJsonDocument::fromJson(allData, &json_error));

    if(json_error.error != QJsonParseError::NoError)
    {
        QMessageBox::critical(this,"error","parse json error:" + json_error.errorString());
        return false;
    }

    QJsonObject rootObj = jsonDoc.object();
    QJsonArray  filesObjs = rootObj.value("files").toArray();

    for(int i = 0; i < filesObjs.size(); i++)
    {
        qDebug() << "key" << i << " is:" << filesObjs.at(i).toObject();
        m_exports.push_back(ExportItem(filesObjs.at(i).toObject()));
    }

    showWith(m_exports);
    return true;
}

void ModTab::showWith(const QList<ExportItem> &datas)
{
    int totalNum = 0;
    for (int i = 0; i < datas.size(); ++i) {
        totalNum += datas[i].m_sheets.size();
    }
    ui->m_table->setRowCount(totalNum + 1);

    int count = 0, addSize;
    qDebug() << "table size:" << datas.size();
    for (int i = 0; i < datas.size(); ++i) {
        const ExportItem* data = &datas.at(i);
        addSize = data->m_sheets.size();

        QMap<QString, QMap<QString, QString>*>::const_iterator it = data->m_sheets.constBegin();
        int j = count;
        while (it != data->m_sheets.constEnd()) {
          //ui->m_table->insertRow(j);
          if (j == count){
              QPushButton *btn = makeBtn(ui->m_table, data->m_excel_file);
              ui->m_table->setCellWidget(j, 0, btn);
              //ui->m_table->setItem(j, 0, new QTableWidgetItem(data->m_excel_file));
          }
          ui->m_table->setItem(j, 1, new QTableWidgetItem(it.key()));
          ui->m_table->setItem(j, 2, new QTableWidgetItem(it.value()->value("export_erl")));
          ui->m_table->setItem(j, 3, new QTableWidgetItem(it.value()->value("export_lua")));
          //if(!it.value()->value("export_erl").isEmpty())
          //  ui->m_table->setCellWidget(j, 2, makeBtn(ui->m_table, it.value()->value("export_erl")));
          //if(!it.value()->value("export_lua").isEmpty())
          //  ui->m_table->setCellWidget(j, 3, makeBtn(ui->m_table, it.value()->value("export_lua")));
          QPushButton* btn = makeBtn(ui->m_table, "导出该行配置");
          btn->setProperty("excle", data->m_excel_file);
          btn->setProperty("row_num", j);
          connect(btn, &QPushButton::clicked, this, &ModTab::onExportBySheet);
          ui->m_table->setCellWidget(j, 5, btn);
          ++j;
          ++it;
        }
        if (addSize > 1){
            ui->m_table->setSpan(count, 0, addSize, 1);
        }
        count += addSize;
    }
}

void ModTab::contextMenuEvent(QContextMenuEvent *event)
{
    qDebug() << "contextMenuEvent here";

    QPoint point = event->pos(); //得到窗口坐标
    // ui->m_table->viewport()->mapFromGlobal(point)

    QTableWidgetItem *item = ui->m_table->itemAt(ui->m_table->viewport()->mapFrom(this, point));

    if(item != NULL)
    {
        m_openDirAct->setData("F:\\p18\\p18_cehua_tool\\fbird_config_tool\\resources\\app\\config\\" + item->text() + ".tpl");
        qDebug() << "row:" << item->row() << ", col:" << item->column(); //当前行

        //菜单出现的位置为当前鼠标的位置
        m_context_menu->exec(QCursor::pos());
        event->accept();
    } else {
         qDebug() << "no item at pos:" << point;
    }
}

void ModTab::openDirectory()
{
    QAction* action = qobject_cast<QAction*> (sender());
    if (action == 0) return;

    QString file = action->data().toString();	//get previous data saved by us
    qDebug() << file;
    file.replace("/", "\\"); // 只能识别 "\"

    //do sth relative with the action
    QProcess proc;
    QString cmd = QString("explorer.exe /select,\"%1\"").arg(file);
    proc.startDetached(cmd);
}

void ModTab::onCellDoubleClicked(int row, int column)
{
    qDebug() << "row:" << row << ", col:" << column; //当前行
    QTableWidgetItem *item = ui->m_table->item(row, column);
    switch (column) {
    case 2:
        if(Setting::getInstatnce().getErlDir().isEmpty()){
            QMessageBox::information(this, "tips", "please set erl export dir first!");
            return;
        }
        m_mainWindow->exportOneFile(Setting::getInstatnce().getErlDir(), item->text());
        break;
    case 3:
        if(Setting::getInstatnce().getLuaDir().isEmpty()){
            QMessageBox::information(this, "tips", "please set lua export dir first!");
            return;
        }
        m_mainWindow->exportOneFile(Setting::getInstatnce().getLuaDir(), item->text());
        break;
    default:
        break;
    }


}

void ModTab::onSearchEvent(const QString &text)
{
    if (!m_timer->isActive())
        m_timer->start(300);
}

void ModTab::onSearchShowEvent()
{
    QString text = ui->m_search->text();
    QList<ExportItem> matched;
    for(int i = 0; i < m_exports.size(); ++i){
        if(m_exports[i].isMatched(text)){
            matched.push_back(m_exports[i]);
        }
    }
    //ui->m_table->clearContents();
    int j = ui->m_table->rowCount();
    while (j >= 0) {
        ui->m_table->removeRow(j);
        --j;
    }
    showWith(matched);
}

void ModTab::on_m_btn_erl_dir_clicked()
{
    QString curPath=QDir::currentPath();//获取系统当前目录
    QString dlgTitle="选择目录"; //对话框标题
    QString dir = QFileDialog::getExistingDirectory(m_mainWindow, dlgTitle, curPath, QFileDialog::ShowDirsOnly);
    if(!dir.isEmpty()){
        Setting::getInstatnce().setErlDir(dir);
        ui->m_edit_erl_dir->setText(dir);
    }
}

void ModTab::on_m_btn_lua_dir_clicked()
{
    QString curPath=QDir::currentPath();//获取系统当前目录
    QString dlgTitle="选择目录"; //对话框标题
    QString dir = QFileDialog::getExistingDirectory(m_mainWindow, dlgTitle, curPath, QFileDialog::ShowDirsOnly);
    if(!dir.isEmpty()){
        Setting::getInstatnce().setLuaDir(dir);
        ui->m_edit_lua_dir->setText(dir);
    }
}

void ModTab::onExportBySheet()
{
    QPushButton* btn = qobject_cast<QPushButton*> (sender());
    qDebug() << btn->property("row_num").toInt();
    QString excel = btn->property("excle").toString();
    qDebug() << excel;
    QString sheet = ui->m_table->item(btn->property("row_num").toInt(), 1)->text();
    qDebug() << sheet;
    m_mainWindow->exportBySheet(excel + "#" + sheet);
}
