import QtQuick 1.1

/*ParamDouble2D containts two input field*/

Item {
    id: containerParamDouble2D
    implicitWidth: 300
    implicitHeight: 30

    property variant paramObject: model.object

    /*Container of the two input field*/
     Row {
        id: paramDouble2DInputContainer
        spacing : 10

        // Title of the paramDouble
        Text {
            id: paramDouble2DTitle
            text: paramObject.text + " : "
            color: "white"
        }

        /* First input */
        Rectangle {
            height: 20
            width: 40
            color: "#343434"
            border.width: 1
            border.color: "#444"
            radius: 3
            TextInput {
                id: paramDouble2Dinput1
                text: paramObject.value1
                width: parent.width - 2
                anchors.left: parent.left
                anchors.leftMargin: 2
                anchors.rightMargin: 2
                anchors.verticalCenter: parent.verticalCenter
                color: activeFocus ? "white" : "grey"
                selectByMouse : true
                onAccepted: {
                    if(acceptableInput){
                        paramObject.value1 = paramDouble2Dinput1.text
                    }
                }
                onActiveFocusChanged: {
                    if(acceptableInput){
                        paramObject.value1 = paramDouble2Dinput1.text
                    }
                }
                validator: DoubleValidator {
                    bottom: paramObject.minimum1
                    top:  paramObject.maximum1
                }

                KeyNavigation.backtab: paramDouble2Dinput2
                KeyNavigation.tab: paramDouble2Dinput2
            }
        }

        /* Second input */
        Rectangle {
            height: 20
            width: 40
            color: "#343434"
            border.width: 1
            border.color: "#444"
            radius: 3
            TextInput {
                id: paramDouble2Dinput2
                text: paramObject.value2
                width: parent.width - 2
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                anchors.leftMargin: 2
                anchors.rightMargin: 2
                color: activeFocus ? "white" : "grey"
                selectByMouse : true
                onAccepted: {
                    if(acceptableInput) {
                        paramObject.value2 = paramDouble2Dinput2.text
                    }
                }
                onActiveFocusChanged: {
                    if(acceptableInput) {
                        paramObject.value2 = paramDouble2Dinput2.text
                    }
                }
                validator: DoubleValidator {
                    bottom: paramObject.minimum2
                    top: paramObject.maximum2
                }

                KeyNavigation.backtab: paramDouble2Dinput1
                KeyNavigation.tab: paramDouble2Dinput1
            }
        }
    }
}
