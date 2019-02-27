import QtQuick 2.0
import QtLocation 5.9
import QtPositioning 5.8
import "MarkerGenerator.js" as MarkerGenerator
import "distanceCalculator.js" as DistanceCalculator
import "ShowErrors.js" as ShowErrors
import QtCharts 2.0

Item {
    id: root
    property int numberOfPoint : 0  //get from JS function
    property real distanceToNextPoint: DistanceCalculator.distanceCalculate(); //get from JS function
    property real longitude : planePosition.longitude //get from backend
    property real latitude: planePosition.latitude  //get from backend
    property string serverAdress : "LOCALHOST" //get from settings (database) or RequestDialog
    property bool connected: false
    property real transmitterDistance : 2.2515 //get from backend
    property real groundSpeed : Math.sqrt((adapter.Vx)^2+(adapter.Vy)^2) //get from backend
    property real altitude : 254.5465 //get from backend
    property var planePosition: QtPositioning.coordinate(adapter.Lat,adapter.Lon)
    property bool mapFollow: followSwitch.status
    property real xVelocity: adapter.Vx
    property real yVelocity: adapter.Vy
    property string fontFamily: standardFont.name
    property bool notify: false
    property string realPortS: "8080"
    property int numberOfError: 2 //get from backend
    property int numberOfWarning: 3 //get from backend
    property int numberOfInformation: 6 //get from backend
    property var jsonWarning: []
    property int errorIterator: 1
    property int informationIterator: 1
    property var errors: []
    property var informations: []



    onNumberOfErrorChanged: {
        if(!(numberOfError||numberOfWarning)){
            errorIcon.source="qrc:/assetsMenu/okIcon.png"
            errorTXT.text = "Everything works correctly"
            errorTXT.color = "#38865B"
        }
        else {
            ShowErrors.showErrors();
        }

    }
    Connections {
        target: request
        onSetAdress:{
            serverAdress = adressS
            realPortS = portS
        }

    }

    Component.onCompleted: {
        if(!(numberOfError||numberOfWarning)){
            errorIcon.source="qrc:/assetsMenu/okIcon.png"
            errorTXT.text = "Everything works correctly"
            errorTXT.color = "#38865B"
        }
        else {
            ShowErrors.showErrors();
        }
        if(!numberOfInformation){
            informationTXT.text = "Nothing to say"
        }
        else {
            ShowErrors.showInformation();
        }
    }
    onNumberOfInformationChanged: {
        if(!numberOfInformation){
            informationTXT.text = "Nothing to say"
        }
        else {
            ShowErrors.showInformation();
        }
    }

    onNumberOfWarningChanged: {
        if(!(numberOfError||numberOfWarning)){
            errorIcon.source="qrc:/assetsMenu/okIcon.png"
            errorTXT.text = "Everything works correctly"
            errorTXT.color = "#38865B"
        }
        else {
            ShowErrors.showErrors();
        }
    }
    RequestDialog{
        id:request
    }

    Timer {
        interval: 3000; running: true; repeat: true
        onTriggered: {
                if(errorIterator<(numberOfError+numberOfWarning)){
                errorIterator++;
                }
                else {errorIterator = 1;}
                if(informationIterator<numberOfInformation){
                informationIterator++;
                }
                else {informationIterator = 1;}
            if(!(numberOfError||numberOfWarning)){
                errorIcon.source="qrc:/assetsMenu/okIcon.png"
                errorTXT.text = "Everything works correctly"
                errorTXT.color = "#38865B"
            }
            else {
               ShowErrors.showErrors();
            }
            if(!numberOfInformation){
                informationTXT.text = "Nothing to say"
            }
            else {
                ShowErrors.showInformation();
            }
        }
    }

    FontLoader {
        id: standardFont
        source: "qrc:/assetsMenu/agency_fb.ttf"
    }



    anchors.fill: parent
    onPlanePositionChanged: {
        if(mapFollow==true){
            map.center = planePosition
        }
    }
    onMapFollowChanged: {
        if(mapFollow==true){
            map.center = planePosition

        }
    }

    onNumberOfPointChanged: {
       distanceToNextPoint = DistanceCalculator.distanceCalculate();
                      }

    onConnectedChanged: {

        if(connected == true )
        {
                controller.doUpdates(true)
                transmitterTXT.color = "#38865B" //green
                portTXT.color = "#38865B"
                portTXT.text = "Correctly Connected"
                port.color = "#38865B"
                realPort.color = "#38865B"
                realPort.text = "Port: " + realPortS
                port.text = serverAdress.toUpperCase()
                transmitterTXT.text = transmitterDistance.toFixed(1).toString() + "m"
        }
            else
            {
                 controller.doUpdates(false)
                 transmitterTXT.color = "#DB3D40"
                 portTXT.color = "#DB3D40"//red
                 portTXT.text = "Not Connected"
                 port.color = "#DB3D40"
                 port.text =  "---"
                 realPort.text = "---"
                 realPort.color = "#DB3D40"
                 transmitterTXT.text = "---"
            }

    }
    Rectangle {
        id: mainPage
        anchors.fill: parent
        color: "#292B38"
        border {
            width: 1
            color: "#333644"
        }

        onHeightChanged: {
            if(mapWidget.state == "windowed") {
                mapWidget.height = parent.height*0.5
            }
            else if(mapWidget.state == "fullPage") {
                mapWidget.height = parent.height
            }
        }
        onWidthChanged: {
            if(mapWidget.state == "windowed") {
                mapWidget.width = parent.width*0.5
            }
            else if(mapWidget.state == "fullPage") {
                mapWidget.width = parent.width
            }
        }


                }//for tests

    Item {
        id: weatherWidget
        width: 0.35*parent.width
        height: 0.28*parent.height
        anchors {
            top: parent.top
            topMargin: parent.height*0.35
            right: parent.right
            rightMargin: parent.width*0.05
        }

        Rectangle {
            id: weatherBackground
            anchors.fill:parent
            color: "#2F3243"

        }

    }
    Item {
        id: transmitterWidget
        width: 0.16*parent.width
        height: 0.3*parent.height
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height*0.05
            left: alertsWidget.left
        }
        Rectangle {
            id: transmitterBackground
            anchors.fill:parent
            color: "#2F3243"
            Image {
                anchors.fill:parent
                source: "qrc:/assetsMenu/TRANSMITTER DISTANCE.png"
            }
            Text {
                id: transmitterTXT
                color: "#DB3D40"
                font.pointSize: (parent.width*0.12).toFixed(0)
                font.family: fontFamily
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: parent.width*0.15
                    verticalCenterOffset: parent.height*0.1
                }

                text: "---"

            }


        }
    }
    Item {
        id: alertsWidget
        width: 0.35*parent.width
        height: 0.28*parent.height
        anchors {
            top: parent.top
            topMargin: parent.height*0.05
            right: parent.right
            rightMargin: parent.width*0.05
        }
        Rectangle {
            id: alertsBackground
            anchors.fill:parent
            color: "#2F3243"
            radius: height*0.02
            Rectangle { //tob bar
                id: alertsTopBar
                height: parent.height
                width: parent.width
                radius: parent.height*0.02
                color: "#313646"
                anchors {
                    top:parent.top
                    horizontalCenter: parent.horizontalCenter

                }
                Image { //properties squares
                    height: parent.height*0.15
                    width: parent.width*0.01
                    source: "qrc:/assetsMenu/PROPERTIES SQUARES.png"
                    anchors {
                        top: parent.top
                        topMargin: parent.height*0.12
                        right: parent.right
                        rightMargin: 0.03*parent.width
                    }
                }
                Image { //alert icon
                    height: parent.height*0.2
                    width: parent.width*0.08
                    source: "qrc:/assetsMenu/NotificationIcon.png"
                    anchors {
                        top: parent.top
                        topMargin: parent.height*0.07
                        left: parent.left
                        leftMargin: 0.03*parent.width
                    }
                    Text {
                        font.pointSize: (parent.height*0.8).toFixed(0)
                        font.family: fontFamily
                        text: "Alerts"
                        color: "#999AA3"
                        anchors {
                            verticalCenter: parent.verticalCenter
                            horizontalCenter: parent.horizontalCenter
                            horizontalCenterOffset: parent.width*2.2
                        }
                        Image {
                            source: "qrc:/assetsMenu/exampleAlertIcon2.png"
                            height: parent.height*0.6
                            width: parent.height*0.6
                            anchors{
                                left: parent.right
                                leftMargin: parent.height
                                verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: numberOfError
                                font.pointSize: 0.7*parent.height.toFixed(0);
                                color: "White"
                                anchors{
                                    verticalCenter: parent.verticalCenter
                                    left: parent.right
                                    leftMargin: 0.2*parent.width
                                }
                            }
                            Image {
                                source: "qrc:/assetsMenu/warningIcon.png"
                                height: parent.height
                                width: parent.width
                                anchors{
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 1.2*parent.width
                                }
                                Text {
                                    text: numberOfWarning
                                    font.pointSize: 0.7*parent.height.toFixed(0);
                                    color: "White"
                                    anchors{
                                        verticalCenter: parent.verticalCenter
                                        left: parent.right
                                        leftMargin: 0.1*parent.width
                                    }
                                }
                            }
                            Image {
                                source: "qrc:/assetsMenu/exampleAlertIcon.png"
                                height: parent.height
                                width: parent.width
                                anchors{
                                    left: parent.right
                                    verticalCenter: parent.verticalCenter
                                    leftMargin: 3.6*parent.width
                                }
                                Text {
                                    text: numberOfInformation
                                    font.pointSize: 0.7*parent.height.toFixed(0);
                                    color: "White"
                                    anchors{
                                        verticalCenter: parent.verticalCenter
                                        left: parent.right
                                        leftMargin: 0.2*parent.width
                                    }
                                }
                            }
                        }

                    }

                }
                Rectangle { //bottom alert
                    radius: parent.radius
                    color: "#424D5C"
                    height: parent.height*0.6
                    width: parent.width
                    anchors{
                        bottom: parent.bottom
                        horizontalCenter: parent.horizontalCenter

                    }
                    Image {
                        height: parent.height*0.25
                        width: parent.height*0.25
                        source: "qrc:/assetsMenu/exampleAlertIcon.png"
                        anchors {
                            left: parent.left
                            leftMargin: 0.03*parent.width
                            bottom: parent.bottom
                            bottomMargin: parent.height*0.1
                        }
                            Text {
                                id: informationTXT
                                font.family: fontFamily
                                font.pointSize: (parent.height*0.5).toFixed(0)
                                text: "Test text" //add text
                                color: "#2281D1"
                                anchors {
                                    verticalCenter: parent.verticalCenter
                                    left: parent.right
                                    leftMargin: parent.width
                                }

                        }
                    }
                }
                Rectangle{ //spacer
                    id: alertSpacer
                    width: parent.width
                    height: parent.height*0.005
                    color: "#707070"
                    anchors {
                        verticalCenter: parent.verticalCenter
                        verticalCenterOffset: parent.height*0.2
                    }

                }
                Rectangle { //middle bar
                color: "#424D5C"
                height: parent.height*0.35
                width: parent.width
                anchors{
                    bottom: alertSpacer.top
                    horizontalCenter: parent.horizontalCenter

                }
                Image {
                    id: errorIcon
                    height: parent.height*0.45
                    width: parent.height*0.45
                    anchors{
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: parent.width*0.03
                    }

                    source: "qrc:/assetsMenu/exampleAlertIcon2.png"
                Text {
                    id: errorTXT
                    font.pointSize: (parent.height*0.5).toFixed(0)
                    text: "Test text"  //add text
                    font.family: fontFamily
                    color: "#DB3D40"
                    anchors {
                        verticalCenter: errorIcon.verticalCenter
                        left: errorIcon.right
                        leftMargin: errorIcon.width
                    }


                }
                }


            }
            }

        }
    }
    Item {
        id: graphWidget
        width: 0.32*parent.width
        height: 0.36*parent.height
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height*0.05
            left: mapWidget.left
        }
        Rectangle {
            id: graphBackground
            anchors.fill: parent
            color: "#292B38"
            Rectangle {
                id: chartBar
                anchors {
                    top: parent.top
                    bottom: chartRect.top
                    left: parent.left
                    right: parent.right
                }
                color: "#313646"
                radius: parent.width * 0.02
                Image {
                    id: speedHeightBar
                    source: "qrc:/assetsMenu/speed_height_bar.png"
                    anchors.fill: parent
                    width: parent.width
                    height: parent.height
                }
//                Rectangle {
//                    id: chartsIcon
//                    anchors {
//                        left: parent.left
//                        top: parent.top
//                        leftMargin: 10
//                        topMargin: 5
//                    }
//                    Image {
//                        id: chartsIconImage
//                        source: "qrc:/assetsMenu/chartsIcon.png"
////                        width: parent.width
////                        height: parent.height
//                    }
//                }
                Image {
                    id: chartsIcon
                    source: "qrc:/assetsMenu/chartsIcon.png"
                    anchors {
                        left: parent.left
                        top: parent.top
                        leftMargin: parent.width * 0.02
                        topMargin: parent.height * 0.1
                    }
                    width: parent.width * 0.08
                    height: parent.height * 0.7
                }
//                Rectangle {
//                    id: chartsTextRect
//                    anchors {
//                        left: chartsIcon.right
//                        top: parent.top
//                        leftMargin: 40
//                        bottom: chartsIcon.bottom
//                    }
//                    Text {
//                        id: chartsText
//                        text: qsTr("Speed/Height chart")
//                        color: "#999AA3"
//                        font {
//                            pointSize: parent.height * 4.5
//                            family: fontFamily
//                        }
//                    }
//                }
                Text {
                    id: chartText
                    text: qsTr("Speed/Height chart")
                    color: "#999AA3"
                    font {
                        pointSize: parent.width * 0.045
                        family: fontFamily
                    }
                    anchors {
                        left: chartsIcon.right
                        leftMargin: parent.width * 0.02
//                        top: parent.top
//                        topMargin: parent.height * 0.04
                        bottom: parent.bottom
//                        bottomMargin: parent.height * 0.01
                    }
                    width: parent.width * 0.6
                    height: parent.height * 0.8
                }
            }
            Rectangle {
                id: chartRect
//                anchors.fill: parent
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                height: parent.height * 0.8
//                color: parent.color
                color: "#25263B"
                ChartView {
                    anchors.fill: parent
                    margins.bottom: 0
                    margins.top: 0
                    margins.left: 0
                    margins.right: 0
                    antialiasing: true
                    backgroundColor: "#25263B"
                    legend.visible: false
                    // Define x-axis to be used with the series instead of default one
//                    ValueAxis {
//                        min: 20
//                        max: 31
//                        tickCount: 12
//                        labelFormat: "%.0f"
//                        gridVisible: false
//                        color: "#2F3243"
//                    }
                    DateTimeAxis {
                        id: xAxis
                        gridVisible: false
                        color: "#2F3243"
                        format: "hh:mm:ss"
                        tickCount: 5
                    }

                    ValueAxis {
                        id: yAxis1
                        min: 0
                        max: 1.5
                        tickCount: 1
                        gridVisible: true
                        gridLineColor: "#2F3243"
                        color: "#2F3243"
                        titleText: "Velocity [kph]"
                    }
                    ValueAxis {
                        id: yAxis2
                        min: 0
                        max: 1.5
                        tickCount: 1
                        gridVisible: true
                        gridLineColor: "#2F3243"
                        color: "#2F3243"
                        titleText: "Altitude [masl]"
                    }

                    AreaSeries {
                        axisX: xAxis
                        axisY: yAxis1
                        color: "#4dfef5"
                        opacity: 0.25
                        //pointLabelsVisible: false
                        borderColor: "#4bddf7"
                        borderWidth: 5.0
                        upperSeries: LineSeries {
                            id: y1
//                            XYPoint { x: 20; y: 4 }
//                            XYPoint { x: 21; y: 5 }
//                            XYPoint { x: 22; y: 6 }
//                            XYPoint { x: 23; y: 8 }
//                            XYPoint { x: 24; y: 7 }
//                            XYPoint { x: 25; y: 6 }
//                            XYPoint { x: 26; y: 4 }
//                            XYPoint { x: 27; y: 6 }
//                            XYPoint { x: 28; y: 4 }
//                            XYPoint { x: 29; y: 5 }
//                            XYPoint { x: 30; y: 6 }
//                            XYPoint { x: 31; y: 7 }
                        }
                    }
                    AreaSeries {
                        axisX: xAxis
                        axisYRight: yAxis2
                        color: "#9b5ed4"
                        opacity: 0.3
                        //pointLabelsVisible: false
                        borderColor: "#bd78f2"
                        borderWidth: 5.0
                        upperSeries: LineSeries {
                            id: y2
//                            XYPoint { x: 20; y: 2 }
//                            XYPoint { x: 21; y: 3 }
//                            XYPoint { x: 22; y: 2 }
//                            XYPoint { x: 23; y: 2 }
//                            XYPoint { x: 24; y: 3 }
//                            XYPoint { x: 25; y: 3 }
//                            XYPoint { x: 26; y: 2 }
//                            XYPoint { x: 27; y: 3 }
//                            XYPoint { x: 28; y: 2 }
//                            XYPoint { x: 29; y: 2 }
//                            XYPoint { x: 30; y: 3 }
//                            XYPoint { x: 31; y: 1 }
                        }
                    }
                    Timer {
                        interval: 100
                        running: true
                        triggeredOnStart: true
                        repeat: true
                        onTriggered: {
                            xAxis.min = new Date(Date.now() - 100);
                            xAxis.max = new Date(Date.now() + 100);
                        }
                    }
                    Timer {
                        interval: 100
                        running: true
                        triggeredOnStart: true
                        repeat: true
                        onTriggered: {
//                            y1.remove(0);
//                            y2.remove(0);
                            y1.append(new Date(Date.now()), Math.random());
                            y2.append(new Date(Date.now()), Math.random());
                        }
                    }
                }
            }
        }
    }

    Item {
        id: portWidget
        width: 0.16*parent.width
        height: 0.3*parent.height
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height*0.05
            right: alertsWidget.right
        }
        Rectangle {
            id: portBackground
            anchors.fill:parent
            color: "#2F3243"
            Image {
                anchors.fill:parent
                source: "qrc:/assetsMenu/REQUEST STATUS.png"
            }
            MouseArea{
                anchors{
                    top: parent.top
                    topMargin: parent.height*0.1
                    right: parent.right
                    rightMargin: parent.width*0.1
                }
                enabled: true
                hoverEnabled: true
                width: parent.width*0.1
                height: parent.height*0.2
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    request.visible = true;

                }

            }

            Text {
                id: portTXT
                font.family: fontFamily
                color: "#DB3D40" //red
                font.pointSize: (parent.height*0.05).toFixed(0)
                anchors {
                    bottom: parent.bottom
                    bottomMargin: 0.01*parent.height
                    horizontalCenter: parent.horizontalCenter
                }
                text:"Not Connected"


            }
            Text {
                id: port
                font.family: fontFamily
                color: "#DB3D40" //red
                font.pointSize: (parent.height*0.1).toFixed(0)
                anchors {
                    verticalCenter: parent.verticalCenter
                    horizontalCenter: parent.horizontalCenter
                    horizontalCenterOffset: parent.width*0.1
                    verticalCenterOffset: parent.height*0.1
                }

                text: "---"

            }
            Text {
                id: realPort
                font.family: fontFamily
                color: "#DB3D40" //red
                font.pointSize: (parent.height*0.1).toFixed(0)
                anchors{
                    verticalCenter: port.verticalCenter
                    horizontalCenter: port.horizontalCenter
                    verticalCenterOffset: parent.height*0.15
                }
                text: "---"
            }

        }
    }
    Item {
        id: parametersWidget
        width: 0.18*parent.width
        height: 0.36*parent.height
        anchors {
            bottom: parent.bottom
            bottomMargin: parent.height*0.05
            left: parent.left
            leftMargin: parent.width*0.37
        }
        Rectangle
        {
            id: parametersBackground
            anchors.fill:parent
            color: "#292B38"
              Rectangle { //Ground speed
                  width: parent.width*0.5
                  height: parent.height*0.5
                  anchors.top: parent.top
                  anchors.left:parent.left
                  anchors.leftMargin: 0.08*width
                  color: "transparent"
                  Image {
                      width: parent.width*0.98
                      height: parent.height*0.98
                      anchors.centerIn: parent
                      source: "qrc:/assetsMenu/SpeedParametr.png"

                  }
                  Text {
                      color: "#F5F0F0"
                      font.family: fontFamily
                      anchors {
                       verticalCenter: parent.verticalCenter
                       verticalCenterOffset: -parent.height*0.06
                       horizontalCenter: parent.horizontalCenter
                       horizontalCenterOffset: -parent.width*0.052
                      }
                      font.pointSize: (parent.height*0.11).toFixed(0)
                      text: groundSpeed.toFixed(0).toString() + "km/h"
                  }
              }
              Rectangle { //Heigth
                  width: parent.width*0.5
                  height: parent.height*0.5
                  anchors.top: parent.top
                  anchors.right: parent.right
                  anchors.rightMargin: -0.1*width
                  color: "transparent"
                  Image {
                      width: parent.width
                      height: parent.height
                      anchors.centerIn: parent
                      source: "qrc:/assetsMenu/Height.png"

                  }
                  Text {
                      color: "#F5F0F0"
                      font.family: fontFamily
                      anchors {
                       verticalCenter: parent.verticalCenter
                       verticalCenterOffset: -parent.height*0.06
                       horizontalCenter: parent.horizontalCenter
                       horizontalCenterOffset: -parent.width*0.052
                      }
                      font.pointSize: (parent.height*0.12).toFixed(0)
                      text: altitude.toFixed(0).toString() + "m"
                  }
              }
              Rectangle { //connectionPower
                  width: parent.width*0.5
                  height: parent.height*0.5
                  anchors.bottom: parent.bottom
                  anchors.left:parent.left
                  anchors.leftMargin: 0.08*width
                  color: "transparent"
                  Image {
                      width: parent.width*0.98
                      height: parent.height*0.98
                      anchors.centerIn: parent
                      source: "qrc:/assetsMenu/connectionPower.png"

                  }
                  Text {
                      color: "#F5F0F0"
                      font.family: fontFamily
                      anchors {
                       verticalCenter: parent.verticalCenter
                       verticalCenterOffset: -parent.height*0.06
                       horizontalCenter: parent.horizontalCenter
                       horizontalCenterOffset: -parent.width*0.052
                      }
                      font.pointSize: (parent.height*0.11).toFixed(0)
                  }
              }
              Rectangle { //Distance
                  width: parent.width*0.5
                  height: parent.height*0.5
                  anchors.bottom: parent.bottom
                  anchors.right: parent.right
                  anchors.rightMargin: -0.1*width
                  color: "transparent"
                  Image {
                      width: parent.width
                      height: parent.height
                      anchors.centerIn: parent
                      source: "qrc:/assetsMenu/Distance.png"

                  }
                  Text {
                      color: "#F5F0F0"
                      font.family: fontFamily
                      anchors {
                       verticalCenter: parent.verticalCenter
                       verticalCenterOffset: -parent.height*0.06
                       horizontalCenter: parent.horizontalCenter
                       horizontalCenterOffset: -parent.width*0.052
                      }
                      font.pointSize: (parent.height*0.12).toFixed(0)
                      text: distanceToNextPoint.toFixed(2).toString() + "km"
                  }
              }

        }
    }
    Item {
        id: mapWidget
        height: parent.height*0.5
        width: parent.width*0.5
        state: "started"
        anchors {
            top: parent.top
            topMargin: parent.height*0.05
            left: parent.left
            leftMargin: parent.width*0.05

        }
        Behavior on width { SmoothedAnimation {id:anim1
                velocity: Number.POSITIVE_INFINITY
            } }
        Behavior on height { SmoothedAnimation {id:anim2
                velocity: Number.POSITIVE_INFINITY
            } }
        Behavior on anchors.topMargin  { SmoothedAnimation {id:anim3
                velocity: Number.POSITIVE_INFINITY } }
        Behavior on anchors.leftMargin { SmoothedAnimation {id:anim4
                velocity: Number.POSITIVE_INFINITY } }
        states: [
        State {
                name: "windowed"

            },
        State {
                name: "fullPage"
            }

        ]


    onStateChanged: {
        if(mapWidget.state === "fullPage") {
            anim1.velocity = 1450
            anim2.velocity = 750
            anim3.velocity = 70
            anim4.velocity = 120
            mapWidget.anchors.topMargin = 0
            mapWidget.anchors.leftMargin = 0
            mapWidget.width = parent.width
            mapWidget.height = parent.height
        }
        else if(mapWidget.state === "windowed") {
            mapWidget.anchors.topMargin = 0.05*parent.height
            mapWidget.anchors.leftMargin = 0.05*parent.width
            mapWidget.width = parent.width*0.5
            mapWidget.height = parent.height*0.5

        }
    }




        Rectangle {
            anchors.fill: parent
            color : "#2F3243"
            //radius: parent.height*0.02

            Map { //map
               id: map
               anchors.fill: parent

                anchors {
                    bottom: parent.bottom
                    left: parent.left
                }
                onCenterChanged: {
                    if(mapFollow==true){
                        center = planePosition
                    }
                }
                plugin: Plugin{
                    name: "mapbox"
                    PluginParameter{
                        name: "mapbox.access_token"
                        value: "***"  //add your own acces token
                    }
                    PluginParameter{
                        name: "mapbox.mapping.map_id"
                        value: "mapbox.dark"
                    }
                }
                DropArea {
                    anchors.fill: parent
                    onDropped: {
                        var coord = map.toCoordinate(Qt.point((drop.x-10), (drop.y+9)));
                        MarkerGenerator.createMarkerObjects(coord);
                        anim.running = true;

                    }
                }
                PlaneMarker {
                    id: planePositionMarker
                    coordinate: planePosition
                    planeAzimut: Math.atan2(xVelocity,yVelocity)*180/Math.PI //The azimuth = arctan((x2 –x1)/(y2 –y1))
                }

            }

            Rectangle { //bottomBar
                id: bottomBar
                color: parent.color
                width: parent.width
                height: parent.parent.parent.height*0.1*0.5
                opacity: 0.85
                anchors {
                    bottom: parent.bottom
                    left: parent.left

                }
                Rectangle {
                width: parent.height*0.95
                height: parent.height*0.95
                color: "transparent"
                opacity: 1
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                Image {
                    id : fullPageIcon
                    width: parent.width*0.6
                    height: parent.height*0.6
                    anchors.centerIn: parent
                    source: "qrc:/assetsMenu/mapFullScreen.png"

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                         if(mapWidget.state == "windowed"||mapWidget.state =="started") {mapWidget.state = "fullPage"}
                         else {mapWidget.state = "windowed"}
                    }
                }
                }
                Rectangle {
                width: parent.height*0.95
                height: parent.height*0.95
                color: "transparent"
                opacity: 1
                anchors.left: parent.left
                anchors.leftMargin: parent.height*0.5
                anchors.verticalCenter: parent.verticalCenter
                SliderSwitch {
                    id: followSwitch
                    anchors.fill: parent
                    size: parent.width*0.8
                    onstatecolor: "#009688"
                    offstatecolor: "#424D5C"
                    state: "on"
                }
                Text{
                    text: "Follow"
                    font.family: fontFamily
                    font.pointSize: (parent.height*0.3).toFixed(0)
                    anchors.left: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: parent.width*0.2
                    color: "#707070"



            }
                }

            }



            Rectangle { //topBar
                color: parent.color
                width: parent.width
                height: parent.parent.parent.height*0.2*0.5
                opacity: 0.85
                anchors {
                    top: parent.top

                }
                Rectangle { //redspacer
                    id: redspacer
                    color: "#F21E41"
                    height: parent.height*0.6
                    width: parent.width*0.002
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: root.width*0.015
                    }
                    Text {
                        id: numberOfPointsTXT
                        text: numberOfPoint.toString()
                        font.family: fontFamily
                        color: "#F5F0F0"
                        font.pointSize: (root.width*0.016).toFixed(0)
                        anchors {
                            left: parent.right
                            leftMargin: parent.width*2
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -parent.height*0.2
                        }

                        }
                    Text {
                        id: numberOfPointsTXTstatic
                        text: "Number of Points"
                        font.family: fontFamily
                        font.pointSize: (numberOfPointsTXT.font.pointSize*0.4).toFixed(0)
                        color: "#707070"
                        anchors {
                            left: parent.left
                            leftMargin: parent.width*3
                            bottom: parent.bottom
                        }
                    }
                }
                Rectangle { //2-nd spacer
                    color: "#1E90F2"
                    height: parent.height*0.6
                    width: parent.width*0.002
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: numberOfPointsTXTstatic.width*1.8
                    }
                    Text {
                        id: distanceToNextPointTXT
                        text: distanceToNextPoint.toFixed(2).toString()+" km"
                        font.family: fontFamily
                        color: "#F5F0F0"
                        font.pointSize: (root.width*0.016).toFixed(0)
                        anchors {
                            left: parent.right
                            leftMargin: parent.width*2
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -parent.height*0.2
                        }

                        }
                    Text {
                        text: "Distance To Next Point"
                        font.family: fontFamily
                        font.pointSize: (numberOfPointsTXT.font.pointSize*0.4).toFixed(0)
                        color: "#707070"
                        anchors {
                            left: parent.left
                            leftMargin: parent.width*3
                            bottom: parent.bottom
                }
            }

        }
                Rectangle { //3-nd spacer
                    color: "#1E90F2"
                    height: parent.height*0.6
                    width: parent.width*0.002
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: numberOfPointsTXTstatic.width*3.5
                    }
                    Text {
                        id: longitudeTXT
                        font.family: fontFamily
                        text: longitude.toFixed(5).toString()
                        color: "#F5F0F0"
                        font.pointSize: (root.width*0.016).toFixed(0)
                        anchors {
                            left: parent.right
                            leftMargin: parent.width*2
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -parent.height*0.2
                        }

                        }
                    Text {
                        text: "Longitude"
                        font.family: fontFamily
                        font.pointSize: (longitudeTXT.font.pointSize*0.4).toFixed(0)
                        color: "#707070"
                        anchors {
                            left: parent.left
                            leftMargin: parent.width*3
                            bottom: parent.bottom
                }
            }

        }
                Rectangle { //4-nd spacer
                    color: "#E4D013"
                    height: parent.height*0.6
                    width: parent.width*0.002
                    anchors {
                        verticalCenter: parent.verticalCenter
                        left: parent.left
                        leftMargin: numberOfPointsTXTstatic.width*5.5
                    }
                    Text {
                        id: latitudeTXT
                        font.family: fontFamily
                        text: latitude.toFixed(5).toString()
                        color: "#F5F0F0"
                        font.pointSize: (root.width*0.016).toFixed(0)
                        anchors {
                            left: parent.right
                            leftMargin: parent.width*2
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -parent.height*0.2
                        }

                        }
                    Text {
                        text: "Latitude"
                        font.family: fontFamily
                        font.pointSize: (longitudeTXT.font.pointSize*0.4).toFixed(0)
                        color: "#707070"
                        anchors {
                            left: parent.left
                            leftMargin: parent.width*3
                            bottom: parent.bottom
                }
            }

        }

    }
            Image {
                id: dragAndDropIcon
                source: "qrc:/assetsMenu/markerIcon.png"
                width: bottomBar.height*0.55
                height: bottomBar.height*0.8
                x: mapWidget.width*0.95
                y: root.height*0.03
                Drag.active: markerDragAndDropMouseArea.drag.active
                Drag.hotSpot.x: 20
                Drag.hotSpot.y: 20
                SequentialAnimation {
                    id: anim
                    running: false
                    NumberAnimation { target: dragAndDropIcon; property: "opacity"; to: 0; duration: 500 }
                    PropertyAction { target: dragAndDropIcon; property: "x"; value: mapWidget.width*0.95 }
                    PropertyAction { target: dragAndDropIcon; property: "y"; value: root.height*0.03 }
                    NumberAnimation { target: dragAndDropIcon; property: "opacity"; to: 1; duration: 500 }
                }
                MouseArea {
                    id: markerDragAndDropMouseArea
                    anchors.fill: parent
                    drag.target: dragAndDropIcon
                    propagateComposedEvents: true
                    onReleased: {
                        dragAndDropIcon.Drag.drop()
                    }
                }

            }
    }

    }

}
