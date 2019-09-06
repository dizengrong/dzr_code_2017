#ifndef MAPTABWIDGET_H
#define MAPTABWIDGET_H

#include <QTabWidget>

namespace Ui {
class MapTabWidget;
}

class MapTabWidget : public QTabWidget
{
    Q_OBJECT

public:
    explicit MapTabWidget(QWidget *parent = 0);
    ~MapTabWidget();

private:
    Ui::MapTabWidget *ui;
};

#endif // MAPTABWIDGET_H
