#include "erltabwidget.h"
#include "ui_erltabwidget.h"

ErlTabWidget::ErlTabWidget(QWidget *parent) :
    QTabWidget(parent),
    ui(new Ui::ErlTabWidget)
{
    ui->setupUi(this);
}

ErlTabWidget::~ErlTabWidget()
{
    delete ui;
}
