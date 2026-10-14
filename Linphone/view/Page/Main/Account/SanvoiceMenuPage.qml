import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import SettingsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

// Menu page, laid out like the Ringotel desktop app: profile on the left, welcome pane on the right.
Rectangle {
	id: mainItem
	color: DefaultStyle.main2_100

	property var account: null
	signal openAccountRequested()
	signal openSettingsRequested()
	signal openHelpRequested()

	readonly property string identity: account && account.core ? account.core.identityAddress : ""
	readonly property string extensionNumber: identity.length > 0 ? UtilsCpp.getUsername(identity) : ""
	readonly property string domainName: identity.indexOf("@") >= 0 ? identity.split("@")[1] : ""
	readonly property string shownName: account && account.core && account.core.displayName.length > 0
		? account.core.displayName : extensionNumber

	component MenuRow: Rectangle {
		id: row
		property string label
		property string iconSource
		signal triggered()
		Layout.fillWidth: true
		Layout.preferredHeight: Utils.getSizeWithScreenRatio(44)
		color: rowMouse.containsMouse ? DefaultStyle.main1_100 : "transparent"
		radius: Utils.getSizeWithScreenRatio(8)
		RowLayout {
			anchors.fill: parent
			anchors.leftMargin: Utils.getSizeWithScreenRatio(40)
			spacing: Utils.getSizeWithScreenRatio(22)
			EffectImage {
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(22)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(22)
				imageSource: row.iconSource
				colorizationColor: DefaultStyle.main2_500_main
				fillMode: Image.PreserveAspectFit
			}
			Text {
				Layout.fillWidth: true
				text: row.label
				color: DefaultStyle.main2_800
				font.pixelSize: Utils.getSizeWithScreenRatio(17)
			}
		}
		MouseArea {
			id: rowMouse
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onClicked: row.triggered()
		}
	}

	RowLayout {
		anchors.fill: parent
		spacing: 0

		// Profile and menu.
		ColumnLayout {
			Layout.preferredWidth: Utils.getSizeWithScreenRatio(420)
			Layout.fillHeight: true
			Layout.topMargin: Utils.getSizeWithScreenRatio(36)
			spacing: Utils.getSizeWithScreenRatio(8)

			Rectangle {
				Layout.alignment: Qt.AlignHCenter
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(150)
				Layout.preferredHeight: width
				radius: width / 2
				color: DefaultStyle.main1_100
				Text {
					anchors.centerIn: parent
					text: mainItem.extensionNumber
					color: DefaultStyle.main1_700
					font.pixelSize: Utils.getSizeWithScreenRatio(mainItem.extensionNumber.length > 4 ? 30 : 44)
				}
			}
			Item { Layout.preferredHeight: Utils.getSizeWithScreenRatio(14) }
			Text {
				Layout.alignment: Qt.AlignHCenter
				text: mainItem.shownName
				color: DefaultStyle.main2_900
				font.pixelSize: Utils.getSizeWithScreenRatio(20)
				font.weight: Font.DemiBold
			}
			Control.ComboBox {
				id: statusBox
				Layout.alignment: Qt.AlignHCenter
				Layout.preferredWidth: Utils.getSizeWithScreenRatio(280)
				Layout.preferredHeight: Utils.getSizeWithScreenRatio(40)
				model: [qsTr("Available"), qsTr("Do not disturb")]
				currentIndex: SettingsCpp.dnd ? 1 : 0
				onActivated: index => SettingsCpp.dnd = (index === 1)
				font.pixelSize: Utils.getSizeWithScreenRatio(16)
				background: Rectangle {
					radius: Utils.getSizeWithScreenRatio(8)
					color: DefaultStyle.grey_0
					border.width: 1
					border.color: DefaultStyle.main2_200
				}
				contentItem: RowLayout {
					spacing: Utils.getSizeWithScreenRatio(10)
					Item { Layout.preferredWidth: Utils.getSizeWithScreenRatio(4) }
					Rectangle {
						Layout.preferredWidth: Utils.getSizeWithScreenRatio(10)
						Layout.preferredHeight: width
						radius: width / 2
						color: SettingsCpp.dnd ? DefaultStyle.danger_500_main : DefaultStyle.success_500_main
					}
					Text {
						Layout.fillWidth: true
						text: statusBox.displayText
						color: DefaultStyle.main2_800
						font: statusBox.font
					}
				}
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				Layout.topMargin: Utils.getSizeWithScreenRatio(10)
				text: qsTr("Extension")
				color: DefaultStyle.main2_600
				font.pixelSize: Utils.getSizeWithScreenRatio(16)
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				text: mainItem.extensionNumber
				color: DefaultStyle.main2_900
				font.pixelSize: Utils.getSizeWithScreenRatio(18)
				font.weight: Font.DemiBold
			}
			Text {
				Layout.alignment: Qt.AlignHCenter
				text: mainItem.domainName + "  ·  v" + AppCpp.shortApplicationVersion
				color: DefaultStyle.main2_500_main
				font.pixelSize: Utils.getSizeWithScreenRatio(12)
			}
			Rectangle {
				Layout.fillWidth: true
				Layout.leftMargin: Utils.getSizeWithScreenRatio(40)
				Layout.rightMargin: Utils.getSizeWithScreenRatio(40)
				Layout.topMargin: Utils.getSizeWithScreenRatio(12)
				Layout.bottomMargin: Utils.getSizeWithScreenRatio(8)
				Layout.preferredHeight: 1
				color: DefaultStyle.main2_300
			}
			MenuRow {
				label: qsTr("My info")
				iconSource: AppIcons.profile
				onTriggered: mainItem.openAccountRequested()
			}
			MenuRow {
				label: qsTr("Settings")
				iconSource: AppIcons.settings
				onTriggered: mainItem.openSettingsRequested()
			}
			MenuRow {
				label: qsTr("About")
				iconSource: AppIcons.info
				onTriggered: mainItem.openHelpRequested()
			}
			MenuRow {
				label: qsTr("Log out")
				iconSource: AppIcons.power
				onTriggered: {
					UtilsCpp.getMainWindow().showConfirmationLambdaPopup("",
						qsTr("This computer will stop receiving calls for this extension. Log out?"), "",
						function (confirmed) {
							if (confirmed && mainItem.account && mainItem.account.core) mainItem.account.core.removeAccount()
						})
				}
			}
			Item { Layout.fillHeight: true }
		}

		// Welcome pane.
		Item {
			Layout.fillWidth: true
			Layout.fillHeight: true
			ColumnLayout {
				anchors.centerIn: parent
				width: Math.min(parent.width - Utils.getSizeWithScreenRatio(60), Utils.getSizeWithScreenRatio(520))
				spacing: Utils.getSizeWithScreenRatio(14)
				Image {
					Layout.alignment: Qt.AlignHCenter
					Layout.preferredWidth: Utils.getSizeWithScreenRatio(150)
					Layout.preferredHeight: Utils.getSizeWithScreenRatio(150)
					source: AppIcons.splashscreenLogo
					sourceSize.width: Utils.getSizeWithScreenRatio(300)
					sourceSize.height: Utils.getSizeWithScreenRatio(300)
					fillMode: Image.PreserveAspectFit
				}
				Text {
					Layout.alignment: Qt.AlignHCenter
					text: qsTr("Welcome to SANVOICE")
					color: DefaultStyle.main2_600
					font.pixelSize: Utils.getSizeWithScreenRatio(30)
				}
				Text {
					Layout.fillWidth: true
					text: qsTr("To make a call, open Calls, type a name or number in the search field, and press Enter. Calls to your extension ring here and on your other devices.")
					color: DefaultStyle.main2_500_main
					wrapMode: Text.WordWrap
					horizontalAlignment: Text.AlignHCenter
					font.pixelSize: Utils.getSizeWithScreenRatio(16)
				}
			}
		}
	}
}
