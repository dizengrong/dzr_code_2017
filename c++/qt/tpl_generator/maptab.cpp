#include "maptab.h"
#include "setting.h"
#include "ui_maptab.h"
#include "mainwindow.h"

#include <QFile>
#include <QJsonObject>
#include <QJsonParseError>
#include <QMessageBox>
#include <QDebug>
#include <QJsonArray>
#include <QFileDialog>

MapTab::MapTab(QWidget *parent) :
    QWidget(parent),
    ui(new Ui::MapTab),
    m_mainWindow(dynamic_cast<MainWindow*>(parent))
{
    ui->setupUi(this);

    QStringList header;
    header.append("ID");
    header.append(tr("map_header_obj_mask"));
    header.append(tr("map_header_erl"));
    header.append(tr("map_heder_c"));
    ui->m_table->setColumnCount(header.size());

    ui->m_table->setHorizontalHeaderLabels(header);
    ui->m_table->horizontalHeader()->setSectionResizeMode(QHeaderView::Stretch);

    ui->m_table->setSelectionBehavior(QAbstractItemView::SelectItems);
    ui->m_table->setEditTriggers(QAbstractItemView::NoEditTriggers);
    ui->m_table->setSortingEnabled(false);
    connect(ui->m_table, &QTableWidget::cellDoubleClicked, this, &MapTab::onCellDoubleClicked);

    // other init
    ui->m_edit_erlmap_dir->setText(Setting::getInstatnce().getErlMapDir());
    ui->m_edit_cmap_dir->setText(Setting::getInstatnce().getCMapDir());
}

MapTab::~MapTab()
{
    delete ui;
    //qDebug() << "delete MapTab";
}

bool MapTab::loadConfigJson(const QString &jsonFile)
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
    auto it = rootObj.begin();
    while (it != rootObj.end()) {
        m_map.insert(it.value().toInt(), it.key().toLower());
        ++it;
    }

    showWith(m_map);
    return true;
}

void MapTab::showWith(const QMap<int, QString> &datas)
{
    ui->m_table->setRowCount(datas.size() + 1);

    auto it = datas.begin();
    int count = 0;
    QString mapId;
    while (it != datas.end()) {
        mapId = QString::number(it.key());
        ui->m_table->setItem(count, 0, new QTableWidgetItem(mapId));
        ui->m_table->setItem(count, 1, new QTableWidgetItem(it.value() + ".obj"));
        ui->m_table->setItem(count, 2, new QTableWidgetItem(it.value() + ".erl"));
        ui->m_table->setItem(count, 3, new QTableWidgetItem("data_map_" + mapId + ".c"));

        ui->m_table->item(count, 0)->setTextAlignment(Qt::AlignHCenter|Qt::AlignVCenter);
        ui->m_table->item(count, 1)->setTextAlignment(Qt::AlignHCenter|Qt::AlignVCenter);
        ui->m_table->item(count, 2)->setTextAlignment(Qt::AlignHCenter|Qt::AlignVCenter);
        ui->m_table->item(count, 3)->setTextAlignment(Qt::AlignHCenter|Qt::AlignVCenter);
        ++it;
        ++count;
    }
}

void MapTab::onCellDoubleClicked(int row, int column)
{
    QTableWidgetItem *item = ui->m_table->item(row, column);
    QTableWidgetItem *obj = ui->m_table->item(row, 1);
    switch (column) {
    case 2:
        if(Setting::getInstatnce().getErlMapDir().isEmpty()){
            QMessageBox::information(this, "tips", "please set erl map export dir first!");
            return;
        }
        m_mainWindow->exportErlMap(Setting::getInstatnce().getErlMapDir(), obj->text(), item->text());
        break;
    case 3:
        if(Setting::getInstatnce().getCMapDir().isEmpty()){
            QMessageBox::information(this, "tips", "please set c map export dir first!");
            return;
        }
        m_mainWindow->exportCMap(Setting::getInstatnce().getCMapDir(), obj->text(), item->text());
        break;
    default:
        break;
    }
}



void MapTab::on_m_btn_erlmap_dir_clicked()
{
    QString curPath=QDir::currentPath();//获取系统当前目录
    QString dlgTitle="选择目录"; //对话框标题
    QString dir = QFileDialog::getExistingDirectory(m_mainWindow, dlgTitle, curPath, QFileDialog::ShowDirsOnly);
    if(!dir.isEmpty()){
        Setting::getInstatnce().setErlMapDir(dir);
        ui->m_edit_erlmap_dir->setText(dir);
    }
}

void MapTab::on_m_btn_cmap_dir_clicked()
{
    QString curPath=QDir::currentPath();//获取系统当前目录
    QString dlgTitle="选择目录"; //对话框标题
    QString dir = QFileDialog::getExistingDirectory(m_mainWindow, dlgTitle, curPath, QFileDialog::ShowDirsOnly);
    if(!dir.isEmpty()){
        Setting::getInstatnce().setCMapDir(dir);
        ui->m_edit_cmap_dir->setText(dir);
    }
}
