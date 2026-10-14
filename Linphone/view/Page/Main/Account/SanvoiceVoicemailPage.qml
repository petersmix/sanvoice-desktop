import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Control
import Linphone
import UtilsCpp
import 'qrc:/qt/qml/Linphone/view/Control/Tool/Helper/utils.js' as Utils

// Voicemail tab: shows how many messages are waiting and calls the mailbox.
Rectangle {
	id: mainItem
	color: DefaultStyle.main2_100

	property var account: null
	readonly property int count: account && account.core ? account.core.voicemailCount : 0
	readonly property bool known: account && account.core ? account.core.showMwi : false
	readonly property string mailbox: account && account.core ? account.core.voicemailAddress : ""

	ColumnLayout {
		anchors.centerIn: parent
		width: Math.min(parent.width - Utils.getSizeWithScreenRatio(60), Utils.getSizeWithScreenRatio(460))
		spacing: Utils.getSizeWithScreenRatio(16)

		Rectangle {
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: Utils.getSizeWithScreenRatio(120)
			Layout.preferredHeight: width
			radius: width / 2
			color: DefaultStyle.main1_100
			EffectImage {
				anchors.centerIn: parent
				width: Utils.getSizeWithScreenRatio(54)
				height: width
				imageSource: AppIcons.voicemail
				colorizationColor: DefaultStyle.main1_700
				fillMode: Image.PreserveAspectFit
			}
		}
		Text {
			Layout.alignment: Qt.AlignHCenter
			text: qsTr("Voicemail")
			color: DefaultStyle.main2_900
			font.pixelSize: Utils.getSizeWithScreenRatio(26)
			font.weight: Font.DemiBold
		}
		Text {
			Layout.fillWidth: true
			horizontalAlignment: Text.AlignHCenter
			wrapMode: Text.WordWrap
			color: mainItem.count > 0 ? DefaultStyle.main1_600 : DefaultStyle.main2_600
			font.pixelSize: Utils.getSizeWithScreenRatio(17)
			text: !mainItem.known
				? qsTr("Call your mailbox to hear your messages.")
				: mainItem.count === 0
					? qsTr("No new messages.")
					: mainItem.count === 1
						? qsTr("You have 1 new message.")
						: qsTr("You have %1 new messages.").arg(mainItem.count)
		}
		Control.Button {
			id: callButton
			Layout.alignment: Qt.AlignHCenter
			Layout.preferredWidth: Utils.getSizeWithScreenRatio(260)
			Layout.preferredHeight: Utils.getSizeWithScreenRatio(48)
			enabled: mainItem.mailbox.length > 0
			background: Rectangle {
				radius: Utils.getSizeWithScreenRatio(8)
				color: !callButton.enabled ? DefaultStyle.main2_300
					: callButton.pressed ? DefaultStyle.success_700
					: DefaultStyle.success_500_main
			}
			contentItem: Text {
				text: qsTr("Call voicemail")
				color: DefaultStyle.grey_0
				font.pixelSize: Utils.getSizeWithScreenRatio(17)
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
			}
			onClicked: UtilsCpp.createCall(mainItem.mailbox)
		}
	}
}
