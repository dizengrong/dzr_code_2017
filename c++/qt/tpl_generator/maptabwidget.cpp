#include "maptabwidget.h"
#include "ui_maptabwidget.h"

MapTabWidget::MapTabWidget(QWidget *parent) :
    QTabWidget(parent),
    ui(new Ui::MapTabWidget)
{
    ui->setupUi(this);
}

MapTabWidget::~MapTabWidget()
{
    delete ui;
}
